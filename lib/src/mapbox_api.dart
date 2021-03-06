import 'dart:convert';

import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';

/// draft of an implementation of the MapBox directions API
///
/// Initialize by running `MapBoxApi.init("YOUR_API_KEY");` in the main() function.
///
/// Access later by using `MapBoxApi.instance`.
class MapBoxApi {
  static late MapBoxApi _current;

  /// initializes the [MapBoxApi] with the given API key
  static void init(String apiKey) {
    _current = MapBoxApi._(apiKey);
  }

  /// returns the currently initialized [MapBoxApi] or throws an error if unavailable
  static MapBoxApi get instance {
    try {
      return _current;
    } catch (e) {
      throw "MapBoxApi not initialized yet.\nRun `MapBoxApi.init(\"YOUR_API_KEY\");` in the main() function.";
    }
  }

  /// the API key used for remote API calls
  final String apiKey;

  MapBoxApi._(this.apiKey);

  /// returns [MBDirections] of the given list of waypoints
  /// https://docs.mapbox.com/api/navigation/directions/
  Future<MBDirections> directions(List<LatLng> points) async {
    final String waypoints = points
        .map((e) => e.longitude.toString() + ',' + e.latitude.toString())
        .join(';');
    final response = await get(Uri.parse(
        'https://api.mapbox.com/directions/v5/mapbox/walking/$waypoints?alternatives=false&geometries=geojson&steps=false&overview=full&access_token=$apiKey'));
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
