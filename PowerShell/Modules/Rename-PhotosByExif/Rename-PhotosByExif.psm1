. $PSScriptRoot/../../Common/CameraModel.ps1
. $PSScriptRoot/../../Common/ExifData.ps1

enum MediaType {
    Unknown
    Audio
    Photo
    Video
}

function Rename-PhotosByExifData {
    param (
        [Parameter(Mandatory=$true)][string]$Path,
        [bool]$DryRun = $true,
        [string]$PhotoPrefix = "photo",
        [string]$VideoPrefix = "video",
        [switch]$NoCorrectDate,
        [switch]$NoOriginalName,
        [switch]$KeepOriginal,
        [switch]$ForceRename # TODO: Implement
    )

    function Parse-CameraModel {
        param (
            [Parameter(Mandatory=$true)][string]$CameraModel,
            [Parameter(Mandatory=$false)][string]$CameraMake
        )

        $cameras = @{
            "iPhone4" = ([CameraModel]::new()).Get("Apple", "iPhone 4");
            "iPhoneX" = ([CameraModel]::new()).Get("Apple", "iPhone X");
            "CanonEOS70D" = ([CameraModel]::new()).Get("Canon", "EOS 70D");
            "CanonEOS400DDIGITAL" = ([CameraModel]::new()).Get("Canon", "EOS 400D");
            "CanonPowerShotA1100IS" = ([CameraModel]::new()).Get("Canon", "PowerShot A1100 IS");
            "HTCOne" = ([CameraModel]::new()).Get("HTC", "One M7");
            "HTCOne_M8" = ([CameraModel]::new()).Get("HTC", "One M8");
            "HDC751E" = ([CameraModel]::new()).Get("Hitachi", "HDC751E");
            "LYA-L09" = ([CameraModel]::new()).Get("Huawei", "Mate 20 Pro", "LYA-L09");
            "ANE-LX1" = ([CameraModel]::new()).Get("Huawei", "P20 Lite", "ANE-LX1");
            "moto g(7) power" = ([CameraModel]::new()).Get("Motorola", "Moto G7 Power");
            "NIKOND80" = ([CameraModel]::new()).Get("Nikon", "D80");
            "NIKOND5100" = ([CameraModel]::new()).Get("Nikon", "D5100");
            "5228" = ([CameraModel]::new()).Get("Nokia", "5228");
            "Lumia530" = ([CameraModel]::new()).Get("Nokia", "Lumia 530");
            "Lumia930" = ([CameraModel]::new()).Get("Nokia", "Lumia 930");
            "Lumia1320" = ([CameraModel]::new()).Get("Nokia", "Lumia 1320");
            "AC2003" = ([CameraModel]::new()).Get("OnePlus", "Nord", "AC2003");
            "SM-A705FN" = ([CameraModel]::new()).Get("Samsung", "Galaxy A70", "SM-A705FN");
            "SM-G960F" = ([CameraModel]::new()).Get("Samsung", "Galaxy S9", "SM-G960F");
            "W580i" = ([CameraModel]::new()).Get("Sony Ericsson", "W580i");
            "MiA2" = ([CameraModel]::new()).Get("Xiaomi", "Mi A2");
            "MiA3" = ([CameraModel]::new()).Get("Xiaomi", "Mi A3");
            "MiMax" = ([CameraModel]::new()).Get("Xiaomi", "Mi Max");
            "Redmi5A" = ([CameraModel]::new()).Get("Xiaomi", "Redmi 5A");
        }

        $foundCamera = $cameras.Item($CameraModel.Replace(" ", ""))

        if($foundCamera) {
            $foundCamera
        } else {
            ([CameraModel]::new()).Get(
                $CameraMake,
                $CameraModel.Replace($CameraMake, "").Trim()
            )
        }
    }

    function Get-ExifData {
        param (
            [Parameter(Mandatory=$true)][string]$Path
        )
    
        $exiftoolOutput = Invoke-Expression "exiftool `"$Path`""
    
        function Get-ExiftoolValue {
            param (
                [string]$Property
            )
    
            $output = ($exiftoolOutput | Select-String $Property)

            if(($output.Length -gt 0)) {
                $output = $output[0].ToString()

                if($output.StartsWith($Property)) {
                    $output = $output.Replace($Property, "").Replace(": ", "").Trim()
                } else {
                    $output = ""
                }
            } else {
                $output = ""
            }

            $output
        }

        function Parse-ExifDateTime {
            param (
                [string]$DateTimeString
            )

            $piece = $DateTimeString.Split(" ").Split(":")
            [DateTime]::Parse("$($piece[0])-$($piece[1])-$($piece[2]) $($piece[3]):$($piece[4]):$($piece[5])")
        }
    
        [ExifData]$exifData = [ExifData]::new()

        $exifCameraModelName = Get-ExiftoolValue -Property "Camera Model Name"
        $exifCreateDate = Get-ExiftoolValue -Property "Create Date"
        $exifDateTimeOriginal = Get-ExiftoolValue -Property "Date/Time Original"
        $exifMake = Get-ExiftoolValue -Property "Make"
        $exifMediaCreateDate = Get-ExiftoolValue -Property "Media Create Date"
        $exifModifyDate = Get-ExiftoolValue -Property "Modify Date"

        if(!([String]::IsNullOrEmpty($exifMediaCreateDate))) {
            $exifData.DateTaken = (Parse-ExifDatetime -DateTimeString $exifMediaCreateDate)
        } elseif(!([String]::IsNullOrEmpty($exifCreateDate))) {
            $exifData.DateTaken = (Parse-ExifDatetime -DateTimeString $exifCreateDate)
        } elseif(!([String]::IsNullOrEmpty($exifDateTimeOriginal))) {
            $exifData.DateTaken = (Parse-ExifDatetime -DateTimeString $exifDateTimeOriginal)
        } elseif(!([String]::IsNullOrEmpty($exifModifyDate))) {
            $exifData.DateTaken = (Parse-ExifDatetime -DateTimeString $exifModifyDate)
        }

        if(!([String]::IsNullOrEmpty($exifModifyDate))) {
            $exifData.DateModified = (Parse-ExifDatetime -DateTimeString $exifModifyDate)
        }

        if(!([String]::IsNullOrEmpty($exifCameraModelName))) {
            $exifData.Device = (Parse-CameraModel -CameraModel $exifCameraModelName -CameraMake $exifMake).Model
        }
    
        $exifData.MimeType = Get-ExiftoolValue -Property "MIME Type"
        $exifData.Path = $Path

        $exifData
    }
    
    function Get-Md5Hash {
        param (
            [Parameter(Mandatory=$true)][string]$Path,
            [int]$HashLength = 32
        )
    
        (Get-FileHash -Path $Path -Algorithm Md5).Hash.ToLower().Substring(0, $HashLength)
    }

    $allFiles = Get-ChildItem -Path $Path | Where-Object {$_.Extension.ToLower() -in ".3gp",".avi",".jpg",".mp4",".mov"}

    foreach($file in $allFiles) {
        $name = ""
        $exifData = Get-ExifData -Path $file
        $mediaType = [MediaType]::Unknown
        $prefix = "file"

        if($exifData.MimeType.Contains("image/")) {
            $mediaType = [MediaType]::Photo
            $prefix = $PhotoPrefix

            if($DryRun -eq $false -and !($NoCorrectDate)) {
                $correctedExifDate = $exifData.DateTaken.ToString("yyyy:MM:dd HH:mm:ss")
                $dummy = exiftool -CreateDate="$correctedExifDate" -DateTimeOriginal="$correctedExifDate" -ModifyDate="$correctedExifDate" -overwrite_original `"$file`"
            }
        } elseif ($exifData.MimeType.Contains("video/")) {
            $mediaType = [MediaType]::Video
            $prefix = $VideoPrefix
        }

        if(!($file.Name.StartsWith($prefix))) {
            $name = "$($prefix)_"
            $name += "$($exifData.DateTaken.ToString("yyyyMMddHHmmss"))"

            if($mediaType -eq [MediaType]::Photo) {
                $device = $exifData.Device.Replace(" ", "")
                $name += ".$device"
            }

            if(
                !($NoOriginalName) -and
                !($file.Name.Contains(" ")) -and # Plex backups
                !($file.Name.StartsWith("PSX_")) # Photoshop Express
            ) {
                $name += ".$($file.BaseName)"
            }

            $name += "-$((Get-Date).Ticks)"
            $name += $file.Extension.ToLower().Replace("jpeg", "jpg")

            $fullName = $file.DirectoryName + "/" + $name

            if($DryRun -eq $false) {
                if($KeepOriginal) {
                    Copy-Item $file.FullName $fullName
                } else {
                    Move-Item $file.Fullname $fullName
                }
            }

            $file.Name + " → " + $name
        }
    }
}

Export-ModuleMember -Function Rename-PhotosByExifData