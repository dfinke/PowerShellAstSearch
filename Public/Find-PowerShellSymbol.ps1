function Find-PowerShellSymbol {
    <#
.SYNOPSIS
    Search PowerShell files for function, parameter, and variable definitions/usages using AST.
.DESCRIPTION
    Accepts file paths (with wildcards/recursion) or pipeline input (from dir/Get-ChildItem),
    searches for a (partial) symbol name, and returns an array of PSObjects with file, line number, type, name, and line content.
.PARAMETER SymbolName
    The (partial) symbol name to search for (case-insensitive).
.PARAMETER Path
    One or more file paths (wildcards/recursion supported).
.PARAMETER FunctionsOnly
    Search only for functions (definitions and usages).
.PARAMETER VarsOnly
    Search only for variables (usages).
.PARAMETER ParamsOnly
    Search only for parameters (definitions/usages).
.PARAMETER ArgumentsOnly
    Search only for command arguments (e.g., -Name in Get-Process -Name 'foo').
.EXAMPLE
    Find-PowerShellSymbol -SymbolName 'Get-Data' -Path .\*.ps1 -FunctionsOnly
    Find-PowerShellSymbol -SymbolName 'foo' -Path .\*.ps1 -VarsOnly
    dir .\src -Recurse -Filter *.ps1 | Find-PowerShellSymbol -SymbolName 'bar' -ParamsOnly
    Find-PowerShellSymbol -SymbolName 'id' -Path .\*.ps1 -ArgumentsOnly  # Finds usages like Get-Data -id 3
#>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$SymbolName,

        [Parameter(Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [string[]]$Path,

        [Parameter()]
        [switch]$FunctionsOnly,

        [Parameter()]
        [switch]$VarsOnly,

        [Parameter()]
        [switch]$ParamsOnly,

        [Parameter()]
        [switch]$ArgumentsOnly,

        [Parameter()]
        [string]$DataType
    )

    begin {
        $results = @()
        $symbolPattern = if ($SymbolName) { [regex]::Escape($SymbolName) } else { ".*" }
        # Determine which types of symbols to search for
        if ($FunctionsOnly -or $VarsOnly -or $ParamsOnly -or $ArgumentsOnly) {
            $searchFunctions = $FunctionsOnly
            $searchVars = $VarsOnly
            $searchParams = $ParamsOnly
            $searchArguments = $ArgumentsOnly
        }
        else {
            # If no specific type is requested, search all
            $searchFunctions = $true
            $searchVars = $true
            $searchParams = $true
            $searchArguments = $true
        }
    }

    process {
        $files = @()
        if ($Path) {
            foreach ($p in $Path) {
                if (Test-Path $p -PathType Leaf) {
                    $files += $p
                }
                elseif (Test-Path $p -PathType Container) {
                    $files += Get-ChildItem -Path $p -Recurse -Filter *.ps1 -File | ForEach-Object { $_.FullName }
                }
                else {
                    # Path doesn't exist - warn user but continue
                    Write-Warning "Path '$p' does not exist. Skipping this path and continuing with other paths."
                    $files += Get-ChildItem -Path $p -Recurse -Filter *.ps1 -File -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }
                }
            }
        }
        elseif ($PSItem -and $PSItem.PSIsContainer -eq $false -and $PSItem.FullName) {
            $files += $PSItem.FullName
        }
        $files = $files | Sort-Object -Unique

        foreach ($file in $files) {
            if (-not ($file -match '\.ps1$')) { continue }
            if (-not (Test-Path $file)) { 
                Write-Warning "File '$file' does not exist or is not accessible. Skipping this file and continuing."
                continue 
            }
            try {
                $content = Get-Content $file -Raw -ErrorAction Stop
            }
            catch { continue }
            $lines = $content -split "`r?`n"
            $ast = [System.Management.Automation.Language.Parser]::ParseInput($content, [ref]$null, [ref]$null)

            # Get all command invocations for searching functions and arguments
            $calls = $ast.FindAll({
                    param($node)
                    $node -is [System.Management.Automation.Language.CommandAst] -and
                    $node.CommandElements.Count -gt 0
                }, $true)

            if ($searchFunctions) {
                # Function Definitions
                $defs = $ast.FindAll({
                        param($node)
                        $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
                        ($null -eq $SymbolName -or $node.Name -match $symbolPattern)
                    }, $true)
                foreach ($def in $defs) {
                    $lineNum = $def.Extent.StartLineNumber
                    $line = $lines[$lineNum - 1]
                    $results += [PSCustomObject][ordered]@{
                        LineNumber = $lineNum
                        Type       = 'FunctionDefinition'
                        Name       = $def.Name
                        Line       = $line
                        File       = $file
                    }
                }

                # Function Usages
                foreach ($call in $calls) {
                    if ($null -eq $SymbolName -or $call.CommandElements[0].Value -match $symbolPattern) {
                        $lineNum = $call.Extent.StartLineNumber
                        $line = $lines[$lineNum - 1]
                        $results += [PSCustomObject][Ordered]@{
                            LineNumber = $lineNum
                            Type       = 'FunctionUsage'
                            Name       = $call.CommandElements[0].Value
                            Line       = $line
                            File       = $file
                        }                    
                    }
                }
            }

            # Search for arguments in commands
            if ($searchArguments) {
                foreach ($call in $calls) {
                    $line = $lines[$call.Extent.StartLineNumber - 1]
                    for ($i = 1; $i -lt $call.CommandElements.Count; $i++) {
                        $element = $call.CommandElements[$i]
                        if ($element -is [System.Management.Automation.Language.CommandParameterAst] -and
                            ($null -eq $SymbolName -or $element.ParameterName -match $symbolPattern)) {
                            $results += [PSCustomObject][Ordered]@{
                                LineNumber = $element.Extent.StartLineNumber
                                Type       = 'ArgumentUsage'
                                Name       = $element.ParameterName
                                Line       = $line
                                File       = $file
                                Command    = $call.CommandElements[0].Value
                            }
                        }
                    }
                }
            }

            if ($searchParams) {
                # Parameter Definitions/Usages
                $params = $ast.FindAll({
                        param($node)
                        $node -is [System.Management.Automation.Language.ParameterAst] -and
                        ($null -eq $SymbolName -or $node.Name.VariablePath.UserPath -match $symbolPattern)
                    }, $true)
                foreach ($param in $params) {
                    $typeName = $null
                    if ($param.StaticType -and $param.StaticType.Name) {
                        $typeName = $param.StaticType.Name
                    }
                    elseif ($param.Attributes) {
                        $typeAttr = $param.Attributes | Where-Object { $_.TypeName -and $_.TypeName.Name }
                        if ($typeAttr) { $typeName = $typeAttr[0].TypeName.Name }
                    }
                    if ($DataType -and $typeName) {
                        if ($typeName -notlike "*$DataType*") { continue }
                    }
                    elseif ($DataType) {
                        continue
                    }
                    $lineNum = $param.Extent.StartLineNumber
                    $line = $lines[$lineNum - 1]
                    $results += [PSCustomObject][Ordered]@{
                        LineNumber = $lineNum
                        Type       = 'Parameter'
                        Name       = $param.Name.VariablePath.UserPath
                        DataType   = $typeName
                        Line       = $line
                        File       = $file
                    }
                }
            }

            if ($searchVars) {
                # Variable Usages
                $vars = $ast.FindAll({
                        param($node)
                        $node -is [System.Management.Automation.Language.VariableExpressionAst] -and
                        ($null -eq $SymbolName -or $node.VariablePath.UserPath -match $symbolPattern)
                    }, $true)
                foreach ($var in $vars) {
                    $typeName = $null
                    if ($var.StaticType -and $var.StaticType.Name) {
                        $typeName = $var.StaticType.Name
                    }
                    if ($DataType -and $typeName) {
                        if ($typeName -notlike "*$DataType*") { continue }
                    }
                    elseif ($DataType) {
                        continue
                    }
                    $lineNum = $var.Extent.StartLineNumber
                    $line = $lines[$lineNum - 1]
                    $results += [PSCustomObject][Ordered]@{
                        LineNumber = $lineNum
                        Type       = 'Variable'
                        Name       = $var.VariablePath.UserPath
                        DataType   = $typeName
                        Line       = $line
                        File       = $file
                    }
                }
            }
        }
    }

    end {
        $results
    }
}
