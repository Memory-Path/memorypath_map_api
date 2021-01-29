# map_api_demo

- [x] Display predefined POIs (points of interest) and act on taps
- [x] Add/remove POIs
- [x] Fetch and render directions between the POIs
- [x] Handle actions (e.g. tap, long press)
- [ ] Move existing POIs

Demonstration of Flutter's map capabilities.

![Demo Implementation](demo.gif)

## API references

```shell
dartdoc
xdg-open doc/api/index.html
```

An example can be found in [`example/lib/main.dart`](example/lib/main.dart).

## Getting Started

***Please note:** currently, this branch is only capable to run on Flutter's `dev` or `master` branch due to recent API changes. Please run `flutter channel dev; flutter upgrade` in order to fix issues in building the example app.*

Add the following to AndroidManifest.xml

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

Add the following to the Info.plist
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location when open.</string>
```

Register for the MapBox API, copy `example/lib/mapbox_api_key.dart.example` to `yourproject/lib/mapbox_api_key.dart` and fill in your API key.