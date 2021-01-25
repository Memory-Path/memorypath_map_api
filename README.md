# map_api_demo

Demonstration of Flutter's map capabilities.

## Getting Started

Add the following to AndroidManifest.xml

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

Add the following to the Info.plist
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location when open.</string>
```

Register for the MapBox API, copy `mapbox_api_key.dart.example` to `mapbox_api_key.dart` and fill in your API key.