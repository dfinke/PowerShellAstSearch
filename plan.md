
# PowerShell AST Symbol Search Plan

## 1. Requirements & Scope
- Input: One or more PowerShell files (support wildcards/recursion), or files piped in via the pipeline (e.g., from dir/Get-ChildItem).
- Input: Symbol name (partial or full, case-insensitive). Symbol types include functions, parameters, and variables.
- Output: Array of PSObjects, each with:
  - File
  - LineNumber
  - Type (FunctionDefinition/FunctionUsage/Parameter/Variable)
  - Name (symbol name)
  - Line (line content)
- Find:
  - Where the symbol is defined (function, parameter, variable).
  - Where the symbol is used (function call, variable usage, parameter reference).
- Add switches to control search scope:
  -FunctionsOnly, -VarsOnly, -ParamsOnly, etc., to improve performance and usability.

## 2. Script Structure
- Parameter handling for symbol name, file paths, and search scope switches (supporting both direct arguments and pipeline input).
- File discovery (handle wildcards, directories, recursion, and pipeline input which may already be resolved file objects).
- For each file:
  - Parse file content into AST.
  - Search AST for:
    - Function definitions and usages matching the name (if -FunctionsOnly or no filter).
    - Parameter definitions/usages matching the name (if -ParamsOnly or no filter).
    - Variable usages matching the name (if -VarsOnly or no filter).
  - For each match, extract line number and line content.
  - Create a PSObject for each match and add to an array.

- Add robust error handling (e.g., skip unreadable files, ignore non-PS1 files).
- Symbol name matching should be case-insensitive by default.

## 3. Output
- Return the array of PSObjects (no formatting, table, or CSV).

## 4. Testing & Iteration
- Test on sample scripts with various symbol names and usages.
- Refine matching (case sensitivity, partial matches, etc.).
- Optimize performance for large file sets.


## 5. Follow-on Phases
- Add support for additional symbol types (aliases, classes, enums, etc.).
- Add options to search for just definitions or just usages.
- Add support for searching by data type (e.g., functions/variables of a specific type).
- Add output formatting options (table, CSV, etc.) if needed.
