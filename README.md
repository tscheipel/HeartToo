# HeartToo

HeartToo is a Garmin Connect IQ data field focused on heartrate display and heartrate zone visualization.

## Features

- Current heartrate display (instant and smoothed modes)
- Average and max heartrate display modes
- User-profile based heartrate zones (cycling profile)
- Optional heartrate zone bars and zone history visualization
- Adjustable visual settings (labels, zone highlight, bar sizing, font size)

## Project Details

- App name: HeartToo
- Type: Connect IQ data field
- Min API level: 3.2.0
- Current version: 2.0.0.1

## Supported Devices

The manifest currently includes:

- edge530
- edge540
- edge830
- edge840
- edge1040
- fenix7xpro
- fr955

## Build

This project is a Monkey C / Connect IQ project.

Typical local build flow:

1. Install Garmin Connect IQ SDK.
2. Configure your SDK path and certificates in your local environment/IDE.
3. Build from VS Code tasks or with the Connect IQ compiler (`monkeyc`) using this project root.


## Repository Structure

- `source/`: Monkey C source files
- `resources/`: layouts, drawables, strings, and properties
- `manifest.xml`: app manifest and product targets
- `monkey.jungle`: project configuration

## License

Licensed under the MIT License. See the LICENSE file for details.

