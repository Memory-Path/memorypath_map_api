import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:map_api_demo/src/mapbox_api.dart';
import 'package:user_location/user_location.dart';

typedef void MapTapCallback(LatLng coordinates);
typedef void MBDirectionsCallback(MBDirections directions);

/// Displays a map, allows editing of POIs and displays user's location
class MapBox extends StatefulWidget {
  final List<Marker> waypoints;
  final MapTapCallback onTap;
  final MapTapCallback onLongPress;
  final MBDirectionsCallback onDirectionsUpdate;

  const MapBox(
      {Key key,
      this.waypoints = const [],
      this.onTap,
      this.onLongPress,
      this.onDirectionsUpdate})
      : super(key: key);
  @override
  MapBoxState createState() => MapBoxState();
}

class MapBoxState extends State<MapBox> with KeepAliveParentDataMixin {
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
      zoomToCurrentLocationOnLoad: false,
    );
    _waypoints = widget.waypoints;
    if (_waypoints.isNotEmpty) calculateRoute();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final LatLngBounds bounds = computeBounds();
    return FlutterMap(
      options: MapOptions(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        bounds: bounds,
        boundsOptions: FitBoundsOptions(padding: EdgeInsets.all(32)),
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
    if (widget.onDirectionsUpdate != null)
      widget.onDirectionsUpdate(directions);
  }

  void zoomTo(LatLng location, double zoom) {
    mapController.move(location, zoom);
  }

/*  @override
  void didUpdateWidget(covariant MapBox oldWidget) {
    if (oldWidget.waypoints != widget.waypoints) setWaypoints(widget.waypoints);
    super.didUpdateWidget(oldWidget);
  }*/

  @override
  void detach() {
    // TODO: implement detach
  }

  @override
  bool get keptAlive => true;

  LatLngBounds computeBounds() {
    double lowestLatitude = _waypoints[0].point.latitude;
    double lowestLongitude = _waypoints[0].point.longitude;
    double highestLatitude = _waypoints[0].point.latitude;
    double highestLongitude = _waypoints[0].point.longitude;
    _waypoints.forEach((element) {
      final location = element.point;
      if (location.latitude < lowestLatitude)
        lowestLatitude = location.latitude;
      if (location.latitude > highestLatitude)
        highestLatitude = location.latitude;
      if (location.longitude < lowestLongitude)
        lowestLongitude = location.longitude;
      if (location.longitude > highestLongitude)
        highestLongitude = location.longitude;
    });
    final a = LatLng(lowestLatitude, lowestLongitude);
    final b = LatLng(highestLatitude, highestLongitude);
    return LatLngBounds(a, b);
  }
}
