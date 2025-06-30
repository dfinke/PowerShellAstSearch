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
.EXAMPLE
    Find-PowerShellSymbol -SymbolName 'Get-Data' -Path .\*.ps1 -FunctionsOnly
    Find-PowerShellSymbol -SymbolName 'foo' -Path .\*.ps1 -VarsOnly
    dir .\src -Recurse -Filter *.ps1 | Find-PowerShellSymbol -SymbolName 'bar' -ParamsOnly
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
        [string]$DataType
    )

    begin {
        $results = @()
        $symbolPattern = if ($SymbolName) { [regex]::Escape($SymbolName) } else { ".*" }
        $searchFunctions = -not $VarsOnly -and -not $ParamsOnly -or $FunctionsOnly
        $searchVars = -not $FunctionsOnly -and -not $ParamsOnly -or $VarsOnly
        $searchParams = -not $FunctionsOnly -and -not $VarsOnly -or $ParamsOnly
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
            if (-not (Test-Path $file)) { continue }
            try {
                $content = Get-Content $file -Raw -ErrorAction Stop
            }
            catch { continue }
            $lines = $content -split "`r?`n"
            $ast = [System.Management.Automation.Language.Parser]::ParseInput($content, [ref]$null, [ref]$null)

            if ($searchFunctions) {
                # Function Definitions
                $defs = $ast.FindAll({
                        param($node)
                        $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
                        ($SymbolName -eq $null -or $node.Name -match $symbolPattern)
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
                $calls = $ast.FindAll({
                        param($node)
                        $node -is [System.Management.Automation.Language.CommandAst] -and
                        $node.CommandElements.Count -gt 0 -and
                        ($SymbolName -eq $null -or $node.CommandElements[0].Value -match $symbolPattern)
                    }, $true)
                foreach ($call in $calls) {
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

            if ($searchParams) {
                # Parameter Definitions/Usages
                $params = $ast.FindAll({
                        param($node)
                        $node -is [System.Management.Automation.Language.ParameterAst] -and
                        ($SymbolName -eq $null -or $node.Name.VariablePath.UserPath -match $symbolPattern)
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
                        ($SymbolName -eq $null -or $node.VariablePath.UserPath -match $symbolPattern)
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
