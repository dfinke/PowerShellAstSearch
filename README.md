
# PowerShellAstSearch: Instantly Find Functions, Parameters, and Variables in Your Scripts, and Generate Call Graphs

Supercharge your PowerShell workflow! Quickly locate, audit, and analyze all your functions, parameters, and variables—by name or data type—across any number of scripts. Now with call graph generation to visualize function dependencies and relationships. Perfect for code navigation, refactoring, automation, and documentation.

# Installation

## Install from PowerShell Gallery

You can install the latest version directly from the PowerShell Gallery:

```powershell
Install-Module PowerShellAstSearch -Scope CurrentUser
```

> **Note:** You may need to trust the PSGallery repository if prompted.


Clone this repo or copy the module folder to your PowerShell module path. Then import the module:

```powershell
Import-Module ./PowerShellAstSearch.psm1
```

> **Requirements:** PowerShell 5.1 or later. No external dependencies.

# How It Works

This tool uses the PowerShell Abstract Syntax Tree (AST) to parse scripts and discover symbols. It is robust for static analysis, but may not find symbols created dynamically at runtime or via dot-sourcing.

## 🌀 Behind the Code

This module was vibe-coded with AI.  
I guided it, it wrote. Fast. Accurate. Useful.  

If you're still debating prompt engineering vs. programming, this repo probably just outperformed your code review.

# Contributing

Contributions, bug reports, and feature requests are welcome! Please open an issue or submit a pull request.

# License

MIT License. See [LICENSE](LICENSE) for details.

# Changelog

See [CHANGELOG.md](CHANGELOG.md) for release history and updates.

# Known Issues & Limitations

- Does not analyze code generated at runtime (e.g., `Invoke-Expression`).
- May not resolve symbols imported via dot-sourcing or modules.
- Data type detection for variables is limited to statically-typed assignments.
- Only `.ps1` files are processed by default.

# Support

For questions or support, open an issue on GitHub or contact the maintainer.

# PowerShellAstSearch: Find-PowerShellSymbol

## What is this?

`Find-PowerShellSymbol` is a PowerShell function that searches PowerShell script files for symbols—functions, parameters, and variables—using the PowerShell Abstract Syntax Tree (AST). It can find where these symbols are defined or used, and filter by name or data type.

## Why use it?

- **Code navigation:** Quickly locate where functions, parameters, or variables are defined or referenced in your scripts.
- **Refactoring:** Identify all usages of a symbol before renaming or refactoring.
- **Auditing:** Find all variables or parameters of a certain type (e.g., all `[string]` parameters).
- **Automation:** Integrate into CI/CD or code review tools to enforce standards or gather metrics.

## Example Usage

Here are common usage patterns to help you get started. Each example demonstrates a specific search capability of the tool.

### Basic Search Operations

#### 1. Search in a Single File
Find any mention of 'Get-Data' in a specific script:
```powershell
Find-PowerShellSymbol -SymbolName 'Get-Data' -Path .\Samples\Sample3.ps1
```
This searches for functions, variables, parameters, and arguments named 'Get-Data' in the specified file.

#### 2. Search Multiple Files
Search all PowerShell files in a directory for 'Get-Data':
```powershell
dir .\Samples\ | Find-PowerShellSymbol -SymbolName 'Get-Data'
```
Perfect for finding symbols across an entire project or module.

#### 3. List All Symbols
Get a complete inventory of all symbols in a file:
```powershell
Find-PowerShellSymbol -Path .\Samples\Sample3.ps1
```
Useful for code review or understanding script structure.

### Filtered Searches

#### 4. Functions Only
Find function definitions and calls for 'Get-Data':
```powershell
Find-PowerShellSymbol -SymbolName 'Get-Data' -Path .\Samples\Sample3.ps1 -FunctionsOnly
```
Shows where functions are defined and used, great for refactoring.

#### 5. Parameters Only
Locate parameter definitions containing 'id':
```powershell
Find-PowerShellSymbol -SymbolName 'id' -Path .\Samples\Sample3.ps1 -ParamsOnly
```
Helps find parameter definitions in function declarations.

#### 6. Variables Only
Find variable usage of 'result':
```powershell
Find-PowerShellSymbol -SymbolName 'result' -Path .\Samples\Sample3.ps1 -VarsOnly
```
Track where variables are used throughout your code.

#### 7. Command Arguments Only
Find where 'id' is used as a parameter in commands:
```powershell
Find-PowerShellSymbol -SymbolName 'id' -Path .\Samples\Sample3.ps1 -ArgumentsOnly
```
Useful for finding how commands are invoked with specific parameters (e.g., Get-Data -id 3).

### Type-Based Searches

#### 8. All String Types
Find parameters and variables of type string:
```powershell
Find-PowerShellSymbol -DataType string -Path .\Samples\Sample3.ps1
```
Helpful for type-based refactoring or validation.

#### 9. Integer Parameters
Locate all integer parameters:
```powershell
Find-PowerShellSymbol -DataType int -ParamsOnly -Path .\Samples\Sample3.ps1
```
Great for finding numeric parameters that might need validation.

#### 10. Object Variables
Find variables that handle complex objects:
```powershell
Find-PowerShellSymbol -DataType object -VarsOnly -Path .\Samples\Sample3.ps1
```
Useful for tracking object handling in your code.

### Advanced Usage

#### 11. Project-Wide Type Search
Search all files in a project for object-typed symbols:
```powershell
dir .\Samples\ | Find-PowerShellSymbol -DataType object
```
Perfect for large-scale refactoring or code analysis.

## Output
Returns an array of PSObjects with:
- `File`: File path
- `LineNumber`: Line number in the file
- `Type`: Symbol type (FunctionDefinition, FunctionUsage, Parameter, Variable, ArgumentUsage)
- `Name`: Symbol name
- `DataType`: Data type (if available, for parameters and variables)
- `Command`: Command name (for ArgumentUsage type)
- `Line`: The line content

## Requirements
- PowerShell 5.1 or later

## Notes
- Symbol name matching is case-insensitive and supports partial matches.
- Data type matching is substring-based (e.g., `string` matches `[string]`, `System.String`, etc).
- Supports wildcards, recursion, and pipeline input for files.

# PowerShellAstSearch: Call Graph Generation

## What is this?

`New-PowerShellCallGraph` and `Convert-PowerShellCallGraphToMermaid` are PowerShell functions that analyze PowerShell scripts to generate call graphs and convert them to Mermaid flowchart syntax for visualization.

## Why use it?

- **Visualize dependencies:** See how functions call each other in your PowerShell scripts
- **Understand code flow:** Identify the call hierarchy and relationships between functions
- **Documentation:** Generate visual diagrams for code documentation
- **Debugging:** Trace function call paths to identify issues

## Example Usage

### Generate a Call Graph

```powershell
# Find all symbols in your PowerShell files
$results = Find-PowerShellSymbol -Path .\Samples\Multiple-Functions.ps1

# Create the call graph
$graph = $results | New-PowerShellCallGraph

# Convert to Mermaid syntax
$mermaid = $graph | Convert-PowerShellCallGraphToMermaid
$mermaid
```

This generates a Mermaid flowchart like:

```
flowchart TD
    Get-Customer[Get-Customer]
    Get-Order[Get-Order]
    Get-Product[Get-Product]
    Get-Shipping[Get-Shipping]
    Get-Customer --> Get-Content
    Get-Customer --> ConvertFrom-Json
    Get-Order --> Get-Product
    Get-Product --> Get-Content
    Get-Shipping --> Get-Customer
    Get-Shipping --> Get-Order
```

### Filter the Graph

```powershell
# Exclude specific functions
$graph | Convert-PowerShellCallGraphToMermaid -ExcludeFunctions 'Get-Content', 'ConvertFrom-Json'

# Include only specific functions
$graph | Convert-PowerShellCallGraphToMermaid -IncludeOnly 'Get-Customer', 'Get-Order', 'Get-Shipping'
```

## Output

`New-PowerShellCallGraph` returns a PSObject with:
- `Nodes`: Array of unique function names
- `Edges`: Array of PSCustomObjects with Caller, Callee, File, and Line properties

`Convert-PowerShellCallGraphToMermaid` returns a string containing the Mermaid flowchart syntax.
