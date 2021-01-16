class Argument {
    [bool]$If = $true
    [string]$Key
    [string]$Separator = " "
    [bool]$Switch = $false
    [string]$Value

    [string]BuildArgument(){
        if($this.If) {
            if($this.Key -ne "" -and $this.Switch -eq $true) {
                return "$($this.Key) "
            } elseif ($this.Key -ne "" -and $this.Value -ne "") {
                return "$($this.Key)$($this.Separator)$($this.Value) "
            }
        }

        return ""
    }
}