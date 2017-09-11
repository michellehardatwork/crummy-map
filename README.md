
# Crummy
![alt text](https://github.com/michellehardatwork/crummy-map/raw/master/CrummyMap/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5%402x.png "Crummy Logo")

This Swift application uses [OpenCage Forward Geocoder API](https://geocoder.opencagedata.com) for finding locations based on the user's input.  The resulting latitude and longitude are used to pin the selected location onto [OpenStreetMap](http://openstreetmap.org) tile overlays.  The overlays are placed on a [MKMapView](https://developer.apple.com/documentation/mapkit/mkmapview).

## Run
1. `git clone https://github.com/michellehardatwork/crummy-map.git`
2.  Add a Keys.plist file to the `crummy-map/CrummyMap` directory.  
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>OPEN_CAGE_API_TOKEN</key>
	<string>xxxx_YOUR_TOKEN_HERE_xxxx</string>
</dict>
</plist>
```
2.  Open `CrummyMap.xcodeproj` using XCode 8.3.3
3.  Build/Run using XCode

## Optional Dependencies
The project uses [SwiftLint](https://github.com/realm/SwiftLint) to validate formatting.  A warning will display while building if you don't have this installed.  

> SwiftLint not installed, download from https://github.com/realm/SwiftLint

Although optional, to install run
```
brew install swiftlint
```


