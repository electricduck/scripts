$OutFolderDefault = "./"
$TagDefault = "wm"
$WatermarkFilenameDefault = "watermark.jpg"
$WatermarkGeometryDefault = "+0+0"
$WatermarkGravityDefault = "SouthWest"
$WatermarkScaleDefault = 3

function Invoke-WatermarkImage {
    param(
        [Parameter(Mandatory)][string]$Filename,
        [string]$OutFolder = $OutFolderDefault,
        [string]$Tag = $TagDefault,
        [string]$WatermarkFilename = $WatermarkFilenameDefault,
        [string]$WatermarkGeometry = $WatermarkGeometryDefault,
        [ValidateSet("NorthWest", "North", "NorthEast", "East", "SouthEast", "South", "SouthWest", "West")]
        $WatermarkGravity = $WatermarkGravityDefault,
        [int]$WatermarkScale = $WatermarkScaleDefault
    )

    $File = $null
    $WatermarkFile = $null

    if (Test-Path $Filename) {
        $File = Get-Item $Filename
    }

    if (Test-Path $WatermarkFilename) {
        $WatermarkFile = Get-Item $WatermarkFilename
    }

    if (!(Test-Path $OutFolder)) {
        New-Item -Type Directory $OutFolder
    }

    $NewFilename = "$($File.BaseName)_$Tag$($File.Extension)"
    $NewLocation = "$((Get-Item $OutFolder).FullName)/$NewFilename"
    $ResizedWatermarkFilename = "$($WatermarkFile.Name)_resized"

    $ImageWidth = [System.Convert]::ToInt32("$(identify -ping -format '%w' $($File.FullName))".Trim())
    $WatermarkWidth = $ImageWidth / $WatermarkScale

    convert $WatermarkFile -resize $WatermarkWidth $ResizedWatermarkFilename
    composite -gravity $WatermarkGravity -geometry $WatermarkGeometry $ResizedWatermarkFilename $File.FullName $NewFilename

    Move-Item $NewFilename $NewLocation -Force
    Remove-Item $ResizedWatermarkFilename
}

function Invoke-WatermarkImageFolder {
    param(
        [Parameter(Mandatory)][string]$Folder,
        [string]$OutFolder = $OutFolderDefault,
        [string]$Tag = $TagDefault,
        [string]$WatermarkFilename = $WatermarkFilenameDefault,
        [string]$WatermarkGeometry = $WatermarkGeometryDefault,
        [ValidateSet("NorthWest", "North", "NorthEast", "East", "SouthEast", "South", "SouthWest", "West")]
        $WatermarkGravity = $WatermarkGravityDefault,
        [int]$WatermarkScale = $WatermarkScaleDefault
    )

    $AllImageFiles = Get-ChildItem -Path $Folder | Where-Object { $_.Extension.ToLower() -in ".jpg", ".jpeg", ".png" }

    foreach ($File in $AllImageFiles) {
        Invoke-WatermarkImage -Filename $File.FullName -OutFolder $OutFolder -Tag $Tag -WatermarkFilename $WatermarkFilename -WatermarkGeometry $WatermarkGeometry -WatermarkGravity $WatermarkGravity -WatermarkScale $WatermarkScale
    }
}

Export-ModuleMember -Function Invoke-WatermarkImage,Invoke-WatermarkImageFolder