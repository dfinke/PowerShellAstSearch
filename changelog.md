# PowerShell AST Search - Changelog

## [0.1.1] - Previous Release

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

## [0.1.1] - Previous Release
- Initial stable release with function, parameter, and variable search capabilities