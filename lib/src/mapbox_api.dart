import 'dart:convert';

import 'package:http/http.dart';
import 'package:latlong/latlong.dart';

/// draft of an implementation of the MapBox directions API
///
/// Initialize by running `MapBoxApi.init(\"YOUR_API_KEY\");` in the main() function.
///
/// Access later by using `MapBoxApi.instance`.
class MapBoxApi {
  static MapBoxApi _current;

  static void init(String apiKey) {
    _current = MapBoxApi(apiKey);
  }

  static MapBoxApi get instance {
    if (_current == null)
      throw "MapBoxApi not initialized yet.\nRun `MapBoxApi.init(\"YOUR_API_KEY\");` in the main() function.";
    return _current;
  }

  final String apiKey;

  MapBoxApi(this.apiKey);

  /// returns [MBDirections] of the given list of waypoints
  /// https://docs.mapbox.com/api/navigation/directions/
  Future<MBDirections> directions(List<LatLng> points) async {
    final String waypoints = points
        .map((e) => e.longitude.toString() + ',' + e.latitude.toString())
        .join(';');
    final response = await get(
        'https://api.mapbox.com/directions/v5/mapbox/walking/$waypoints?alternatives=false&geometries=geojson&steps=false&overview=full&access_token=$apiKey');
    final json = jsonDecode(response.body);
    if (json['code'] != "Ok")
      throw "Error in MapBox API response:\n${response.body}";
    final Duration duration =
        Duration(seconds: json['routes'][0]['duration'].toInt());
    final double distance = json['routes'][0]['distance'];
    final List rawPoints = json['routes'][0]['geometry']['coordinates'];
    List<LatLng> coordinates = [];
    rawPoints.forEach((element) {
      coordinates.add(LatLng(element[1], element[0]));
    });
    return MBDirections(coordinates, duration, distance);
  }
}

/// directions returned from the [MapBoxApi]
class MBDirections {
  /// the [LatLng] to be walked threw on the route
  final List<LatLng> points;

  /// the estimated [Duration] of the walk
  final Duration duration;

  /// the distance in metres
  final double distance;

  MBDirections(this.points, this.duration, this.distance);
}
