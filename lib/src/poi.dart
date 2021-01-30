import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

/// A [POI] is a point of interest to be displayed on a map
class POI {
  /// the label to be used in its tooltip
  final String label;

  /// the [LatLng] of its position
  final LatLng location;

  /// a handler for user interaction
  final Function onTap;

  POI({this.label, this.location, this.onTap});

  /// renders the POI as [Marker] for use on a map
  Marker toMarker({BuildContext context}) => Marker(
        point: location,
        width: 32,
        height: 32,
        anchorPos: AnchorPos.exactly(Anchor(8, 0)),
        builder: (c) {
          //final color = Theme.of(context).primaryColor;
          return IconButton(
            icon: Icon(
              Icons.location_on,
              size: 32,
              //color: color,
            ),
            tooltip: label,
            onPressed: onTap ?? () {}, // preventing grayed button
          );
        },
      );
}
