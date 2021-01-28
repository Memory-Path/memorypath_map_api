import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class POI {
  final String label;
  final LatLng location;
  final Function onTap;

  POI({this.label, this.location, this.onTap});

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
