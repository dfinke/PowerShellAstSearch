function FunctionA {
    Write-Host "In FunctionA"
    FunctionB
}

function FunctionB {
    Write-Host "In FunctionB"
    FunctionC
    FunctionD
}

function FunctionC {
    Write-Host "In FunctionC"
    FunctionA  # Creates a cycle back to FunctionA
}

function FunctionD {
    Write-Host "In FunctionD"
    FunctionE
}

function FunctionE {
    Write-Host "In FunctionE"
    # FunctionE doesn't call any other functions
}

# Start the call chain
FunctionA


