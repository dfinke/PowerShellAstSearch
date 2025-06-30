function Remove-Data {
    param($id)
    $msg = "Removing data for $id"
    Write-Output $msg
}

function Add-Data {
    param(
        [int]$id,
        $value
    )
    $result = $id + 1
    Write-Output "Added data: $result, $value"
}

function Update-Data {
    param(
        [string]$name,
        [Parameter(Mandatory)]
        $info
    )
    $upper = $name.ToUpper()
    $summary = "$upper - $info"
    Write-Output $summary
}

# Call samples
Remove-Data -id 123
Add-Data -id 42 -value 'foo'
Update-Data -name 'bar' -info 99
Get-Data -id 123
