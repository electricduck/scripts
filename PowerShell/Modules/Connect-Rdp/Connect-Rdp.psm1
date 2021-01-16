. $PSScriptRoot/../../Common/Argument.ps1
. $PSScriptRoot/../../Common/RdpConnection.ps1

enum Client {
    NotSet
    Unknown
    mstsc
    FreeRDP
}

$FreeRDPCommand = "xfreerdp"
$MstscCommand = "mstsc"

function Assert-RdpClient {
    $Client = [Client]::UnknownClient

    $HasFreeRDP = Get-Command $FreeRDPCommand -ErrorAction SilentlyContinue
    $HasMstsc = Get-Command $MstscCommand -ErrorAction SilentlyContinue

    if ($HasMstsc) { $Client = [Client]::mstsc }
    if ($HasFreeRDP) { $Client = [Client]::FreeRDP }

    return $Client
}

function Build-Argument {
    param(
        [Parameter(Mandatory = $true)][string]$Key,
        [string]$Value,
        [bool]$If = $true,
        [switch]$Switch
    )

    [Argument]$argument = [Argument]::new()
    $argument.If = $If
    $argument.Key = $Key
    $argument.Separator = ":"
    $argument.Switch = $Switch
    $argument.Value = $Value

    return $argument.BuildArgument()
}

function Build-MstscCompatibleArguments {
    param(
        [Parameter(Mandatory = $true)][RdpConnection]$Connection
    )

    if(![String]::IsNullOrEmpty($Connection.File)) {
        $arguments += "$($Connection.File) "
    }
    
    $arguments += Build-Argument -Key "/admin" -Switch -If $Connection.AdminSession
    $arguments += Build-Argument -Key "/control" -Switch -If ($Connection.ShadowControl -and $Connection.Shadow -gt 0)
    $arguments += Build-Argument -Key "/g" -Value $Connection.Gateway
    $arguments += Build-Argument -Key "/f" -Switch -If $Connection.Fullscreen
    $arguments += Build-Argument -Key "/h" -Value $Connection.Height -If ($Connection.Height -gt 0)
    $arguments += Build-Argument -Key "/multimon" -Switch -If $Connection.MultipleMonitors
    $arguments += Build-Argument -Key "/noConsentPrompt" -Switch -If ($Connection.ShadowNoConsent -and $Connection.Shadow -gt 0)
    $arguments += Build-Argument -Key "/prompt" -Switch -If $Connection.Prompt
    $arguments += Build-Argument -Key "/public" -Switch -If $Connection.Public
    $arguments += Build-Argument -Key "/remoteGuard" -Switch -If $Connection.RemoteGuard
    $arguments += Build-Argument -Key "/restrictedAdmin" -Switch -If $Connection.RestrictedAdmin
    $arguments += Build-Argument -Key "/shadow" -Value $Connection.Shadow -If ($Connection.Shadow -gt 0)
    $arguments += Build-Argument -key "/span" -Switch -If $Connection.Span
    $arguments += Build-Argument -Key "/v" -Value $Connection.Server
    $arguments += Build-Argument -Key "/w" -Value $Connection.Width -If ($Connection.Width -gt 0)

    return $arguments
}

function Invoke-FreeRDP {
    param(
        [Parameter(Mandatory = $true)][RdpConnection]$Connection,
        [string]$ExtraArguments
    )

    $arguments += Build-MstscCompatibleArguments -Connection $Connection
    $arguments += Build-Argument -Key "+aero" -If $Connection.Aero
    $arguments += Build-Argument -Key "/dynamic-resolution" -Switch -If $DynamicResolution
    $arguments += Build-Argument -Key "/restricted-admin" -Switch -If $Connection.RestrictedAdmin
    $arguments += Build-Argument -Key "/u" -Value $Connection.Username

    Invoke-Expression "$FreeRDPCommand $arguments$ExtraArguments"
}

function Invoke-Mstsc {
    param(
        [Parameter(Mandatory = $true)][RdpConnection]$Connection
    )

    $arguments = Build-MstscCompatibleArguments -Connection $Connection
    return "$MstscCommand $arguments"
}

function Connect-Rdp {
    param(
        [string]$File,
        [string]$Server,

        [bool]$AdminSession,
        [bool]$Aero,
        [bool]$DynamicResolution,
        [bool]$Fullscreen,
        [int]$Height,
        [bool]$MultipleMonitors,
        [int]$Port,
        [bool]$Prompt,
        [bool]$Public,
        [bool]$RemoteGuard,
        [bool]$RestrictedAdmin,
        [int]$Shadow,
        [bool]$ShadowControl,
        [bool]$ShadowNoConsent,
        [bool]$Span,
        [int]$Width,
        [string]$Username,
        
        [Client]$Client = [Client]::NotSet,
        [string]$ExtraArguments
    )

    [RdpConnection]$connection = [RdpConnection]::new()
    $connection.SetFromParameters($PSBoundParameters)

    if ($Client -eq [Client]::NotSet) {
        $Client = Assert-RdpClient
    }

    if($Port -gt 0 -and $connection.Server -ne "") {
        $connection.Server = "$($connection.Server):$Port"
    }

    switch ($Client) {
        FreeRDP { Invoke-FreeRDP -Connection $connection -ExtraArguments $ExtraArguments }
        mstsc { Invoke-Mstsc -Connection $connection }
        default { "?" }
    }
}

Export-ModuleMember -Function Connect-Rdp