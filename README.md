
# PowerShellAstSearch: Instantly Find Functions, Parameters, and Variables in Your Scripts

Supercharge your PowerShell workflow! Quickly locate, audit, and analyze all your functions, parameters, and variables—by name or data type—across any number of scripts. Perfect for code navigation, refactoring, and automation.

# Installation

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

### 1. Passing in a file (search for a symbol by name)
```powershell
Find-PowerShellSymbol -SymbolName 'Get-Data' -Path .\Samples\Sample3.ps1
```

### 2. Piping in files (search all .ps1 files in a folder)
```powershell
dir .\Samples\ | Find-PowerShellSymbol -SymbolName 'Get-Data'
```

### 3. Search for all symbols (no name filter)
```powershell
Find-PowerShellSymbol -Path .\Samples\Sample3.ps1
```

### 4. Functions only
```powershell
Find-PowerShellSymbol -SymbolName 'Get-Data' -Path .\Samples\Sample3.ps1 -FunctionsOnly
```

### 5. Parameters only
```powershell
Find-PowerShellSymbol -SymbolName 'id' -Path .\Samples\Sample3.ps1 -ParamsOnly
```

### 6. Variables only
```powershell
Find-PowerShellSymbol -SymbolName 'result' -Path .\Samples\Sample3.ps1 -VarsOnly
```

### 7. By data type (parameters and variables)
```powershell
Find-PowerShellSymbol -DataType string -Path .\Samples\Sample3.ps1
```

### 8. Parameters only by data type
```powershell
Find-PowerShellSymbol -DataType int -ParamsOnly -Path .\Samples\Sample3.ps1
```

### 9. Variables only by data type
```powershell
Find-PowerShellSymbol -DataType object -VarsOnly -Path .\Samples\Sample3.ps1
```

### 10. Only by data type (all parameters and variables of a type, no name filter)
```powershell
Find-PowerShellSymbol -DataType string -Path .\Samples\Sample3.ps1
```

### 11. Piping in files and searching by data type
```powershell
dir .\Samples\ | Find-PowerShellSymbol -DataType object
```

## Output
Returns an array of PSObjects with:
- `File`: File path
- `LineNumber`: Line number in the file
- `Type`: Symbol type (FunctionDefinition, FunctionUsage, Parameter, Variable)
- `Name`: Symbol name
- `DataType`: Data type (if available)
- `Line`: The line content

## Requirements
- PowerShell 5.1 or later

## Notes
- Symbol name matching is case-insensitive and supports partial matches.
- Data type matching is substring-based (e.g., `string` matches `[string]`, `System.String`, etc).
- Supports wildcards, recursion, and pipeline input for files.
