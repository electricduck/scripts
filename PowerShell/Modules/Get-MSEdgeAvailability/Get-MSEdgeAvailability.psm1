function Get-MSEdgeAvailability {
    Param(
        [Parameter(Mandatory)]
        [ValidateSet("linux", "macos", "win7", "win8dot1", "win10", "win2012", "win2016")]
        $Platform
    )

    $MSEdgeAvailableReturn = New-Object -TypeName PSObject

    $Url = "https://www.microsoftedgeinsider.com/en-us/download/?platform=$Platform"
    $Available = $false
    
    $DisabledButtons = ((Invoke-WebRequest $Url).Content -Split "dl-button-group button disabled").Count - 1
    if ($DisabledButtons -lt 3) {
        $Available = $true
    }
    else {
        $Available = $false
    }

    $MSEdgeAvailableReturn | Add-Member -MemberType NoteProperty -Name Available -Value $Available
    $MSEdgeAvailableReturn | Add-Member -MemberType NoteProperty -Name Url -Value $Url

    $MSEdgeAvailableReturn
}

Export-ModuleMember -Function Get-MSEdgeAvailability