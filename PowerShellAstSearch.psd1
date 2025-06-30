@{
    # Script module or binary module file associated with this manifest.
    RootModule        = 'PowerShellAstSearch.psm1'

    # Version number of this module.
    ModuleVersion     = '0.1.0'

    # ID used to uniquely identify this module
    GUID              = 'b1e2e2e2-0000-4000-8000-000000000001'

    # Author of this module
    Author            = 'Doug Finke'

    # Company or vendor of this module
    CompanyName       = 'Doug Finke'

    # Description of the functionality provided by this module
    Description       = 'Search PowerShell files for function definitions and usages using AST.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module
    FunctionsToExport = @(
        'Find-PowerShellSymbol'
    )

    # Cmdlets to export from this module
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport   = @()

    # Private data to pass to the module specified in RootModule
    PrivateData       = @{}
}
