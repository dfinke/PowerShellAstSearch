function Get-Customer {
    Get-Content "cust.json" | ConvertFrom-Json
}

function Get-Order {
    Get-Product
}

function Get-Product {
    Get-Content "data.json"
}

function Get-Shipping {
    Get-Customer
    Get-Order
    
}