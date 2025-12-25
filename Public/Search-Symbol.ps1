function Search-Symbol {
    <#
    .SYNOPSIS
    AI-friendly wrapper for Find-PowerShellSymbol
    
    .PARAMETER Name
    The symbol name to find. If not specified, searches all symbols of the specified types.
    
    .PARAMETER SearchTypes
    Array of types to search. Can include: Function, Variable, Parameter, Argument
    If empty or not specified, searches all types.
    
    .EXAMPLE
    Search-Symbol -Name "myVar" -SearchTypes @('Variable')
    
    .EXAMPLE
    Search-Symbol -Name "id" -SearchTypes @('Variable', 'Parameter')
    
    .EXAMPLE
    Search-Symbol -Name "Get-Foo" -SearchTypes @('Function')
    
    .EXAMPLE
    Search-Symbol -Name "something" -SearchPath "C:\Code"
    Searches all types when SearchTypes is omitted
    
    .EXAMPLE
    Search-Symbol -SearchTypes @('Function')
    Shows all functions defined
    #>
    param(
        [string]$Name,
        
        [ValidateSet('Function', 'Variable', 'Parameter', 'Argument')]
        [string[]]$SearchTypes,
        
        [string]$SearchPath = '.',
        
        [string]$DataType
    )
    
    $findParams = @{
        Path = $SearchPath
    }
    
    if ($Name) {
        $findParams.SymbolName = $Name
    }
    
    if ($DataType) { 
        $findParams.DataType = $DataType 
    }
    
    # If SearchTypes specified, map to switches
    if ($SearchTypes) {
        if ($SearchTypes -contains 'Function') { $findParams.FunctionsOnly = $true }
        if ($SearchTypes -contains 'Variable') { $findParams.VarsOnly = $true }
        if ($SearchTypes -contains 'Parameter') { $findParams.ParamsOnly = $true }
        if ($SearchTypes -contains 'Argument') { $findParams.ArgumentsOnly = $true }
    }
    # If not specified, no switches = search all types
    
    Find-PowerShellSymbol @findParams
}