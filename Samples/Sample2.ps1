function Set-Data {
    param($id, $value)
    Write-Output "Setting data for $id to $value"
}

Get-Data -id 99
Set-Data -id 99 -value 'bar'
