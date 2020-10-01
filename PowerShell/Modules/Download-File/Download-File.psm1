function Download-File {
    param(
        [Parameter(Mandatory=$true)][string]$Uri,
        [bool]$IncludeDomain = $false
    )

    $UriSegments = $Uri.Split("/")

    $Domain = $UriSegments[2]
    $Filename = $UriSegments[-1]

    if($IncludeDomain) {
        $Filename = "$Domain~$Filename"
    }

    Invoke-WebRequest -Uri $Uri -OutFile $Filename
}

Export-ModuleMember -Function Download-File