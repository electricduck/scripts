class CameraModel {
    [string]$Make
    [string]$Model
    [string]$Variant

    [CameraModel]Get($Make, $Model) {
        $this.Make = $Make
        $this.Model = $Model

        return $this
    }

    [CameraModel]Get($Make, $Model, $Variant) {
        $this.Make = $Make
        $this.Model = $Model
        $this.Variant = $Variant

        return $this
    }
}