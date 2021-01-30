import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:user_location/user_location.dart';

import 'mapbox_api.dart';

typedef void MapTapCallback(LatLng coordinates);
typedef void MBDirectionsCallback(MBDirections directions);

/// Displays a map, allows editing of POIs and displays user's location
class MapView extends StatefulWidget {
  /// the [MapViewController] for external control of the [MapView]
  final MapViewController controller;

  /// the initial waypoints displayed on the map. Can be modified by the controller later
  final List<Marker> waypoints;

  /// a [MapTapCallback] handling any **single tap** on the map which is not a waypoint yet
  final MapTapCallback onTap;

  /// a [MapTapCallback] handling any **long press** on the map which is not a waypoint yet
  final MapTapCallback onLongPress;

  /// a [MBDirectionsCallback] providing the updated [MBDirections] to the parenting [Widget}
  final MBDirectionsCallback onDirectionsUpdate;

  const MapView(
      {Key key,
      this.waypoints = const [],
      this.onTap,
      this.onLongPress,
      this.onDirectionsUpdate,
      this.controller})
      : super(key: key);
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> with KeepAliveParentDataMixin {
  MapController mapController = MapController();
  UserLocationOptions userLocationOptions;
  List<Marker> locationMarkers = [];
  List<Marker> _waypoints;

  // initially, no directions available, so no display
  bool displayDirections = false;
  MBDirections directions;

  @override
  void initState() {
    // important: connects the current state to the controller
    if (widget.controller != null) widget.controller._key = this;
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

/// The [MapViewController] takes care of the communication with the [MapView]
class MapViewController {
  _MapViewState _globalKey;

  /// sets the waypoints of the *memory path* on the map **and** recalculates the route in between
  set waypoints(List<Marker> waypoints) => _globalKey.setWaypoints(waypoints);

  /// fetches the current waypoints displayed on the map
  List<Marker> get waypoints => _globalKey._waypoints;

  /// called once by the [_MapViewState] we connect to
  set _key(_MapViewState key) => _globalKey = key;

  /// zooms to a certain [LatLng] at a given [double] zoom level
  void zoomTo(LatLng location, double zoom) {
    _globalKey.zoomTo(location, zoom);
  }

  /// checks whether directions are shown currently
  bool get displayDirections => _globalKey.displayDirections;

  /// enables or disables display of directions
  set displayDirections(bool display) => _globalKey.displayDirections = display;

  /// fetches the current directions in between the waypoints
  MBDirections get directions => _globalKey.directions;
}
