function Convert-PowerShellCallGraphToMermaid {
    <#
.SYNOPSIS
    Converts a PowerShell call graph to Mermaid flowchart syntax.
.DESCRIPTION
    Takes the output from New-PowerShellCallGraph and generates Mermaid flowchart syntax.
    Allows filtering of functions to include or exclude specific function names.
    Optionally saves the diagram to a markdown file.
.PARAMETER Graph
    The PSObject returned by New-PowerShellCallGraph with Nodes and Edges.
.PARAMETER ExcludeFunctions
    Array of function names to exclude from the graph.
.PARAMETER IncludeOnly
    Array of function names to include in the graph (excludes all others).
.PARAMETER Outfile
    Path to the output markdown file. If specified, the diagram will be saved to this file.
.EXAMPLE
    $results = Find-PowerShellSymbol -Path .\*.ps1
    $graph = New-PowerShellCallGraph -Results $results
    $graph | Convert-PowerShellCallGraphToMermaid
.EXAMPLE
    $results = Find-PowerShellSymbol -Path .\*.ps1
    $graph = New-PowerShellCallGraph -Results $results
    $graph | Convert-PowerShellCallGraphToMermaid -ExcludeFunctions 'funcA', 'funcB'
.EXAMPLE
    $results = Find-PowerShellSymbol -Path .\*.ps1
    $graph = New-PowerShellCallGraph -Results $results
    $graph | Convert-PowerShellCallGraphToMermaid -Outfile 'graph.md'
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSObject]$Graph,
        [Parameter()]
        [string[]]$ExcludeFunctions,
        [Parameter()]
        [string[]]$IncludeOnly,
        [Parameter()]
        [string]$Outfile
    )

    begin {
        $collectedNodes = @()
        $collectedEdges = @()
    }

    process {
        $collectedNodes += $Graph.Nodes
        $collectedEdges += $Graph.Edges
    }

    end {
        $nodes = $collectedNodes | Select-Object -Unique
        $edges = $collectedEdges | Select-Object -Unique Caller, Callee

        # Filter nodes and edges
        if ($ExcludeFunctions) {
            $nodes = $nodes | Where-Object { $_ -notin $ExcludeFunctions }
            $edges = $edges | Where-Object { $_.Caller -notin $ExcludeFunctions -and $_.Callee -notin $ExcludeFunctions }
        }

        if ($IncludeOnly) {
            $nodes = $nodes | Where-Object { $_ -in $IncludeOnly }
            $edges = $edges | Where-Object { $_.Caller -in $IncludeOnly -and $_.Callee -in $IncludeOnly }
        }

        $globalCalls = $edges | Where-Object { $_.Caller -eq '<Global>' }

        # Determine flowchart direction based on number of edges
        $edgeCount = $edges.Count
        $direction = "TD"
        if ($edgeCount -gt 10) {
            $direction = "LR"
        }

        # Generate Mermaid syntax
        $mermaid = "flowchart $direction`n"
        foreach ($node in $nodes) {
            $id = $node
            $mermaid += "    $id[$node]`n"
        }

        if ($globalCalls) {
            $mermaid += "    <Global>['<Global>']`n"
        }

        foreach ($edge in $edges) {
            $callerId = if ($edge.Caller -eq '<Global>') { '<Global>' } else { $edge.Caller }
            $calleeId = $edge.Callee
            $mermaid += "    $callerId --> $calleeId`n"
        }

        if ($Outfile) {
            $markdown = @'
```mermaid
{0}
```
'@ -f $mermaid
            $markdown | Out-File -FilePath $Outfile -Encoding UTF8
        }
        else {
            $mermaid
        }
    }
}