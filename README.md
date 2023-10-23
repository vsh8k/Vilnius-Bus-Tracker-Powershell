# Vilnius Bus Tracker - PowerShell
## Overview
The Vilnius Bus Tracker is a PowerShell script that provides real-time information about public transport buses in Vilnius. 

## Features
- Display the count of buses on selected routes.
- Show detailed information about each bus, including coordinates, direction, speed, and a unique vehicle ID.
- Optional conversion of coordinates into street names for improved readability.

## Usage

```pwsh
Get-BusLocation -Bus <routes> -Trolleybus <routes> -ShowStreet
```

#### Arguments

- Bus: Allows you to specify one or more bus numbers to retrieve location information.
- Trolleybus: Enables you to select one or more trolleybus numbers for location information retrieval.
- ShowStreet: A switch parameter that, when enabled, displays street names instead of raw coordinates.

## Example

![An example of the script](https://i.ibb.co/N9tYJq1/image.png)

## How it Works
#### This script operates by utilizing two key APIs:

- Bus Data API: The script fetches real-time bus data from [stops.lt](stops.lt/vilnius/gps_full.txt), allowing it to access up-to-date information about bus locations and speeds.

- Geocoding API: To convert GPS coordinates into human-readable street names, the script makes use of the [Geocoding API](geocode.maps.co/reverse).

#### Brief explanation on how the code works:

- Data Retrieval: The function begins by attempting to fetch real-time bus data from the stops.lt API. If successful, it converts the data into a structured format using the ```ConvertFrom-Csv``` cmdlet.

- Filter Routes: The script filters out routes that are not specified, ensuring that only the desired data is displayed.

- Display: For each bus, the script presents a set of information, providing the bus's location and other relevant details. If needed, contacts the geocoding API, and displays the street name.

## Important Note
>Please be aware that the geocoding API used for converting coordinates into street names is free, but it has limitations on request rates. Consequently, it is recommended not to use this feature when there are a substantial number of buses (e.g., 10 or more) being tracked simultaneously to avoid exceeding the API's rate limits.
