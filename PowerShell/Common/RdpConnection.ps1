class RdpConnection {
    [bool]$AdminSession
    [bool]$Aero
    [bool]$DynamicResolution
    [int]$Height
    [string]$File
    [bool]$Fullscreen
    [string]$Gateway
    [bool]$MultipleMonitors
    [bool]$Prompt
    [bool]$Public
    [bool]$RemoteGuard
    [bool]$RestrictedAdmin
    [string]$Server
    [int]$Shadow
    [bool]$ShadowControl
    [bool]$ShadowNoConsent
    [bool]$Span
    [string]$Username
    [int]$Width

    [void]SetFromParameters($Parameters) {
        $this.AdminSession = $Parameters.AdminSession
        $this.Aero = $Parameters.Aero
        $this.DynamicResolution = $Parameters.DynamicResolution
        $this.Height = $Parameters.Height
        $this.File = $Parameters.File
        $this.Fullscreen = $Parameters.Fullscreen
        $this.Gateway = $Parameters.Gateway
        $this.MultipleMonitors = $Parameters.MultipleMonitors
        $this.Prompt = $Parameters.Prompt
        $this.Public = $Parameters.Public
        $this.RemoteGuard = $Parameters.RemoteGuard
        $this.RestrictedAdmin = $Parameters.RestrictedAdmin
        $this.Server = $Parameters.Server
        $this.Shadow = $Parameters.Shadow
        $this.ShadowControl = $Parameters.ShadowControl
        $this.ShadowNoConsent = $Parameters.ShadowNoConsent
        $this.Span = $Parameters.Span
        $this.Username = $Parameters.Username
        $this.Width = $Parameters.Width
    }
}