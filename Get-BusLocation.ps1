$busDataLink = 'https://www.stops.lt/vilnius/gps_full.txt'
$geocodingApi = 'https://geocode.maps.co/reverse?lat=LATITUDE&lon=LONGITUDE'

function Get-BusLocation {
    <#
    .SYNOPSIS
    Retrieves the real-time location of buses and trolleybuses based on their numbers.

    .DESCRIPTION
    This function fetches the real-time location information of buses and trolleybuses based on their numbers.

    .PARAMETER Bus
    The bus number for which you want to retrieve location information.

    .PARAMETER Trolleybus
    The trolleybus number for which you want to retrieve location information.

    .PARAMETER ShowStreet
    Use this switch parameter to display street names instead of coordinates.

    .EXAMPLE
    Get-BusLocation -Bus 123
    Retrieves the location information for buses with the number 123.
    Get-BusLocation -Trolleybus 1,2,4,6,12
    Retrieves the location information for trolleybuses with the numbers 1,2,4,6,12.

    .NOTES
    Author: Eimantas Kaušakys
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [string[]]$Bus,

        [Parameter(Mandatory=$false)]
        [string[]]$Trolleybus,

        [Switch]$ShowStreet
    )

    try {
        $rawData = (Invoke-WebRequest $busDataLink).Content
        $csvData = ConvertFrom-Csv $rawData
    } 
    catch {
        Write-Host "Failed to retrieve bus data. Check your internet connection or the data source."
        return
    }

    $buses = @()

    if ($Bus) {
        $buses += $csvData | Where-Object { $Bus -contains $_.Marsrutas -and $_.Transportas -eq "Autobusai" }
    }
    if ($Trolleybus) {
        $buses += $csvData | Where-Object { $Trolleybus -contains $_.Marsrutas -and $_.Transportas -eq "Troleibusai" }
    }

    if ($buses.Count -eq 0) {
        Write-Host "No matching buses or trolleybuses found."
        return
    }

    $buses | ForEach-Object {
        $lat = $_.Platuma.Insert(2, '.')
        $lon = $_.Ilguma.Insert(2, '.')
        $id = $_.MasinosNumeris
        $route = $_.Marsrutas
        $speed = $_.Greitis

        $azimuth = [int]$_.Azimutas
        $direction = Switch ($azimuth) {
            { $_ -ge 0 -and $_ -lt 22.5 } { "North (N)"; break }
            { $_ -ge 22.5 -and $_ -lt 67.5 } { "North-Northeast (NNE)"; break }
            { $_ -ge 67.5 -and $_ -lt 112.5 } { "East (E)"; break }
            { $_ -ge 112.5 -and $_ -lt 157.5 } { "South-Southeast (SSE)"; break }
            { $_ -ge 157.5 -and $_ -lt 202.5 } { "South (S)"; break }
            { $_ -ge 202.5 -and $_ -lt 247.5 } { "South-Southwest (SSW)"; break }
            { $_ -ge 247.5 -and $_ -lt 292.5 } { "West (W)"; break }
            { $_ -ge 292.5 -and $_ -lt 337.5 } { "North-Northwest (NNW)"; break }
            default { "North (N)" }  # Handle out-of-range azimuth angles
        }

        if ($ShowStreet) {
            $apiLink = $geocodingApi -replace 'LATITUDE', $lat -replace 'LONGITUDE', $lon
            try {
                $apiData = ConvertFrom-Json (Invoke-WebRequest $apiLink).Content
            } 
            catch {
                $apiData = $null
            }
            $street = $apiData.address.road
            $location = if ($street) { $street } else { 'Unknown' }
        } 
        else {
            $location = "$lat, $lon"
        }

        $busType = if ($_.Transportas -eq "Autobusai") { "bus" } else { "trolleybus" }
        Write-Output "The $busType $route is at: $location, Heading $direction@$speed km/h. It's vechicle number is: $id"
    }
}
