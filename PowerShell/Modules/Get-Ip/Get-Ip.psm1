function Get-Ip {
    $IpReturn = New-Object -TypeName PSObject

    $WtfIsMyIp = ((Invoke-WebRequest https://wtfismyip.com/json).Content | ConvertFrom-Json)

    $IpReturn | Add-Member -MemberType NoteProperty -Name IpAddress -Value $WtfIsMyIp.YourFuckingIPAddress
    $IpReturn | Add-Member -MemberType NoteProperty -Name Location -Value $WtfIsMyIp.YourFuckingLocation
    $IpReturn | Add-Member -MemberType NoteProperty -Name Hostname -Value $WtfIsMyIp.YourFuckingHostname
    $IpReturn | Add-Member -MemberType NoteProperty -Name ISP -Value $WtfIsMyIp.YourFuckingISP
    $IpReturn | Add-Member -MemberType NoteProperty -Name IsTorExit -Value ([System.Convert]::ToBoolean($WtfIsMyIp.YourFuckingTorExit))
    $IpReturn | Add-Member -MemberType NoteProperty -Name CountryCode -Value $WtfIsMyIp.YourFuckingCountryCode

    return $IpReturn
}

Export-ModuleMember -Function Get-Ip