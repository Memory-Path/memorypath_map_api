import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:map_api_demo/src/mapbox_api.dart';
import 'package:user_location/user_location.dart';

typedef void MapTapCallback(LatLng coordinates);

/// Displays a map, allows editing of POIs and displays user's location
class MapBox extends StatefulWidget {
  final List<Marker> waypoints;
  final MapTapCallback onTap;
  final MapTapCallback onLongPress;

  const MapBox(
      {Key key, this.waypoints = const [], this.onTap, this.onLongPress})
      : super(key: key);
  @override
  _MapBoxState createState() => _MapBoxState();
}

class _MapBoxState extends State<MapBox> {
  MapController mapController = MapController();
  UserLocationOptions userLocationOptions;
  List<Marker> locationMarkers = [];
  List<Marker> _waypoints;

  bool displayDirections = false;
  MBDirections directions;

  @override
  void initState() {
    userLocationOptions = UserLocationOptions(
      context: context,
      mapController: mapController,
      markers: locationMarkers,
      updateMapLocationOnPositionChange: false,
      zoomToCurrentLocationOnLoad: true,
    );
    _waypoints = widget.waypoints;
    if (_waypoints.isNotEmpty) calculateRoute();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        center: LatLng(50.773333333333,
            9.0233333333333), // default location is being overwritten by the detected location signal
        zoom: 15.0,
        plugins: [
          UserLocationPlugin(),
        ],
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        ),
        if (displayDirections)
          PolylineLayerOptions(polylines: [
            Polyline(
                points: directions.points,
                strokeWidth: 4,
                color: Theme.of(context).accentColor)
          ]),
        new MarkerLayerOptions(
          markers: _waypoints,
        ),
        MarkerLayerOptions(markers: locationMarkers),
        userLocationOptions,
      ],
      mapController: mapController,
    );
  }

  void setWaypoints(List<Marker> waypoints) {
    setState(() {
      displayDirections = false;
      _waypoints = waypoints;
    });
    if (_waypoints.isNotEmpty) calculateRoute();
  }

  Future<void> calculateRoute() async {
    final List<LatLng> points = _waypoints.map((e) => e.point).toList();
    directions = await MapBoxApi.instance.directions(points);
    setState(() {
      displayDirections = true;
    });
  }

  void zoomTo(LatLng location, double zoom) {
    mapController.move(location, zoom);
  }
}
