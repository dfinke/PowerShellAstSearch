# PowerShell AST Search - Changelog

## v0.1.4

### Added
- **Search-Symbol Function**: New AI-Optimized wrapper for `Find-PowerShellSymbol` that simplifies symbol searching with a single array parameter for search types.
  - Supports searching by symbol name or listing all symbols of specified types (Function, Variable, Parameter, Argument).
  - Easier API for automation and AI tools compared to multiple boolean switches.
  - Maintains full compatibility with existing `Find-PowerShellSymbol` functionality.

### Enhanced
- **Module Exports**: Updated module manifest to export the new `Search-Symbol` function alongside existing functions.
- **Documentation**: Added comprehensive README section with examples and parameter descriptions for `Search-Symbol`.

## v0.1.3

### Added
- **Call Graph Generation**: New functions `New-PowerShellCallGraph` and `Convert-PowerShellCallGraphToMermaid` to analyze PowerShell scripts and generate visual call graphs using Mermaid syntax.
  - `New-PowerShellCallGraph`: Creates a call graph from `Find-PowerShellSymbol` results, identifying function relationships and dependencies.
  - `Convert-PowerShellCallGraphToMermaid`: Converts call graphs to Mermaid flowchart syntax for visualization, with options to filter included/excluded functions and save to markdown files.
- **Enhanced Visualization**: Support for generating interactive flowcharts showing function call hierarchies, aiding in code documentation, debugging, and refactoring.

### Enhanced
- **Integration with Existing Features**: Call graph functions work seamlessly with `Find-PowerShellSymbol` output, extending symbol search capabilities to dependency analysis.

## v0.1.2

### Added
- **New ArgumentsOnly parameter**: Added `-ArgumentsOnly` switch to search specifically for command arguments (e.g., `-Name` in `Get-Process -Name 'foo'`)
- **Enhanced search logic**: Improved search behavior when specific filters are applied vs. when searching all symbol types
- **Better code organization**: Refactored search logic for better maintainability and performance

### Changed
- **Improved search filtering**: Fixed logic for determining which symbol types to search when multiple filters are specified
- **Enhanced documentation**: Updated README with comprehensive examples demonstrating all search capabilities including the new argument search
- **Better parameter handling**: Improved null comparison patterns throughout the codebase for better PowerShell best practices

### Enhanced
- **Function usage detection**: Optimized function call detection by reusing command AST parsing
- **Output format**: Added `Command` property to ArgumentUsage results to show which command the argument belongs to
- **Documentation**: Expanded examples section with practical use cases for each search type

### Technical Improvements
- Refactored AST parsing logic to be more efficient
- Improved code readability with better variable naming and structure
- Enhanced type checking and null handling patterns