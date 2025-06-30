function Get-Data {
    param($id)
    Write-Output "Getting data for $id"
}

Get-Data -id 42
Set-Data -id 42 -value 'foo'
