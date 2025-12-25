```powershell
Find-PowerShellSymbol id . -VarsOnly -ParamsOnly
Find-PowerShellSymbol id . -FunctionsOnly -VarsOnly -ArgumentsOnly
Find-PowerShellSymbol id .  # All types
```

## AI-Friendly Wrapper v2

```powershell
function Search-Symbol {
    <#
    .SYNOPSIS
    AI-friendly wrapper for Find-PowerShellSymbol
    
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
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        
        [ValidateSet('Function', 'Variable', 'Parameter', 'Argument')]
        [string[]]$SearchTypes,
        
        [string]$SearchPath = '.',
        
        [string]$DataType
    )
    
    $findParams = @{
        SymbolName = $Name
        Path = $SearchPath
    }
    
    if ($DataType) { 
        $findParams.DataType = $DataType 
    }
    
    # If SearchTypes specified, map to switches
    if ($SearchTypes) {
        if ($SearchTypes -contains 'Function')  { $findParams.FunctionsOnly = $true }
        if ($SearchTypes -contains 'Variable')  { $findParams.VarsOnly = $true }
        if ($SearchTypes -contains 'Parameter') { $findParams.ParamsOnly = $true }
        if ($SearchTypes -contains 'Argument')  { $findParams.ArgumentsOnly = $true }
    }
    # If not specified, no switches = search all types
    
    Find-PowerShellSymbol @findParams
}
```

## Key Design Decision

`SearchTypes` as a **string array** with ValidateSet:
- ✅ Model can pass one: `@('Variable')`
- ✅ Model can pass multiple: `@('Variable', 'Parameter')`  
- ✅ Model can omit entirely: searches all types
- ✅ ValidateSet prevents invalid values
- ✅ Arrays are clear in JSON schema

## SKILL.md

```markdown
# Symbol Search Skill

Search PowerShell files for symbol definitions and usages.

## Function: Search-Symbol

### Parameters
- **Name** (required, string): The symbol name to find (e.g., "Get-MyFunction", "myVariable", "ComputerName")
- **SearchTypes** (optional, string[]): Types to search for. Valid values: Function, Variable, Parameter, Argument
  - Can specify one type: `@('Variable')`
  - Can specify multiple: `@('Variable', 'Parameter')`
  - If omitted, searches ALL types
- **SearchPath** (optional, string): Directory to search. Default: current directory
- **DataType** (optional, string): Filter by data type (e.g., "string", "int")

### Examples

Search for any symbol named "id" (all types):
```powershell
Search-Symbol -Name "id"
```

Search for "id" as variable only:
```powershell
Search-Symbol -Name "id" -SearchTypes @('Variable')
```

Search for "ComputerName" as both parameter and variable:
```powershell
Search-Symbol -Name "ComputerName" -SearchTypes @('Parameter', 'Variable')
```

Search in specific directory:
```powershell
Search-Symbol -Name "Get-MyFunc" -SearchTypes @('Function') -SearchPath "C:\Scripts"
```
```

## Why This Works for AI

1. **Single array parameter** instead of 4 boolean flags
2. **Clear semantics**: empty array = all, specified values = filter to those
3. **ValidateSet** helps model understand valid values
4. **Examples show all common patterns**

The model understands arrays much better than it understands "pass switches that are true when present, omit when false."

Does this handle your use case?