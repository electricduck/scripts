
function Guess-VehicleMileage {
    param(
        [Parameter(Mandatory)][string]$DateRegistered,
        [Parameter(Mandatory)][int]$LastMileage,
        [Parameter(Mandatory)][string]$LastMileageDate,
        [string]$DateToCalculateTo,
        [ValidateSet("mi")]$UnitIn = "mi",
        [ValidateSet("mi")]$UnitOut = "mi"
    )

    $CurrentDate = Get-Date

    if(!([String]::IsNullOrEmpty($DateToCalculateTo))) {
        $CurrentDate = ([DateTime]::Parse($DateToCalculateTo))
    }

    [double]$DaysSinceRegistration = ($CurrentDate - ([DateTime]::Parse($DateRegistered))).TotalDays
    [double]$DaysSinceLastMileage = (([DateTime]::Parse($LastMileageDate)) - ([DateTime]::Parse($DateRegistered))).TotalDays

    [double]$ApproxMilesPerDay = $LastMileage / $DaysSinceLastMileage
    [double]$ApproxCurrentMileage = $ApproxMilesPerDay * $DaysSinceRegistration

    [double]$CalculatedMileage = [Math]::Round($ApproxCurrentMileage)
    [string]$CalculatedMileageString = $CalculatedMileage.ToString("N0")

    return "~$CalculatedMileageString $UnitOut"
}