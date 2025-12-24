function New-PowerShellCallGraph {
    <#
.SYNOPSIS
    Creates a call graph from the results of Find-PowerShellSymbol.
.DESCRIPTION
    Takes the output from Find-PowerShellSymbol and builds a call graph by associating function usages with their callers.
    Returns a PSObject with Nodes (unique functions) and Edges (caller-callee relationships).
.PARAMETER Results
    The array of PSObjects returned by Find-PowerShellSymbol.
.EXAMPLE
    $results = Find-PowerShellSymbol -Path .\*.ps1
    $graph = New-PowerShellCallGraph -Results $results
    $graph.Nodes  # List of functions
    $graph.Edges  # List of [PSCustomObject]@{Caller='funcA'; Callee='funcB'}
.EXAMPLE
    $results = Find-PowerShellSymbol -Path .\*.ps1
    $graph = New-PowerShellCallGraph -Results $results
    $graph | Convert-PowerShellCallGraphToMermaid
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSObject[]]$Results
    )

    begin {
        $nodes = @()
        $edges = @()
        $fileCache = @{}  # Cache parsed ASTs per file
    }

    process {
        foreach ($result in $Results) {
            if ($result.Type -eq 'FunctionDefinition') {
                $nodes += $result.Name
            }
            elseif ($result.Type -eq 'FunctionUsage') {
                $caller = Get-CallerFromUsage -Result $result -FileCache $fileCache
                if ($caller -and $result.Name) {
                    $edges += [PSCustomObject]@{
                        Caller = $caller
                        Callee = $result.Name
                        File   = $result.File
                        Line   = $result.LineNumber
                    }
                }
            }
        }
    }

    end {
        $nodes = $nodes | Sort-Object -Unique
        [PSCustomObject]@{
            Nodes = $nodes
            Edges = $edges
        }
    }
}

function Get-CallerFromUsage {
    param(
        [PSObject]$Result,
        [hashtable]$FileCache
    )

    $file = $Result.File
    if (-not $FileCache.ContainsKey($file)) {
        if (-not (Test-Path $file)) { return $null }
        try {
            $content = Get-Content $file -Raw -ErrorAction Stop
            $ast = [System.Management.Automation.Language.Parser]::ParseInput($content, [ref]$null, [ref]$null)
            $FileCache[$file] = $ast
        }
        catch { return $null }
    }

    $ast = $FileCache[$file]
    $lineNum = $Result.LineNumber

    # Find the CommandAst at the line number
    $command = $ast.Find({
            param($node)
            $node -is [System.Management.Automation.Language.CommandAst] -and
            $node.Extent.StartLineNumber -eq $lineNum
        }, $true) | Select-Object -First 1

    if (-not $command) { return $null }

    # Traverse up to find the containing function
    $current = $command
    while ($current) {
        if ($current -is [System.Management.Automation.Language.FunctionDefinitionAst]) {
            return $current.Name
        }
        $current = $current.Parent
    }

    # If no function found, it's a top-level call
    return '<Global>'
}