import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';
import 'package:map_api_demo/mapbox_api_key.dart';
import 'package:map_api_demo/src/map_widget.dart';
import 'package:map_api_demo/src/mapbox_api.dart';

void main() {
  /// please copy `mapbox_api_key.dart.example` to `mapbox_api_key.dart` and fill in your API key.
  MapBoxApi.init(MAPBOX_API_KEY);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Map API',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Map API Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MBDirections directions;

  List<POI> _waypoints;

  TextEditingController _newPOIController = TextEditingController();

  GlobalKey<MapBoxState> mapKey = GlobalKey();

  @override
  void initState() {
    _waypoints = [
      POI(
        label: 'Dannenrod',
        location: LatLng(50.773333333333, 9.0233333333333),
      ),
      POI(
        label: 'Homberg',
        location: LatLng(50.7279033, 8.9955088),
      ),
      POI(
        label: 'Stadtallendorf',
        location: LatLng(50.8308912, 8.9544324),
      )
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        //shrinkWrap: true,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Display Directions',
                style: Theme.of(context).textTheme.headline5,
              ),
              Container(
                child: MapBox(
                  key: mapKey,
                  onDirectionsUpdate: (newDirections) =>
                      setState(() => directions = newDirections),
                  onTap: (location) {
                    showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Center(
                              child: Container(
                                  constraints: BoxConstraints(maxWidth: 512),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16)),
                                    color: Theme.of(context).cardColor,
                                  ),
                                  child: ListView(
                                    children: [
                                      ListTile(
                                        title: Text(
                                            'Location ${location.round(decimals: 4).latitude}° ${location.round(decimals: 4).longitude}°'),
                                      ),
                                      ListTile(
                                        title: Text('Create new way point...'),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                    title: Text(
                                                        'Add new way point'),
                                                    content: TextField(
                                                      controller:
                                                          _newPOIController,
                                                      decoration: InputDecoration(
                                                          border:
                                                              OutlineInputBorder(),
                                                          labelText:
                                                              'Way point name'),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                          onPressed:
                                                              Navigator.of(
                                                                      context)
                                                                  .pop,
                                                          child:
                                                              Text('Cancel')),
                                                      TextButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              _waypoints
                                                                  .add(POI(
                                                                label:
                                                                    _newPOIController
                                                                        .text,
                                                                location:
                                                                    location,
                                                              ));
                                                              _newPOIController
                                                                  .text = '';
                                                              mapKey
                                                                  .currentState
                                                                  .setWaypoints(_waypoints
                                                                      .map((e) =>
                                                                          e.toMarker(
                                                                              context: context))
                                                                      .toList());
                                                            });
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Text('Save'))
                                                    ],
                                                  ));
                                        },
                                      ),
                                    ],
                                  )),
                            ));
                  },
                  waypoints: _waypoints
                      .map((e) => e.toMarker(context: context))
                      .toList(),
                ),
                height: 500,
              ),
              if (directions != null)
                ListTile(
                  leading: Icon(Icons.directions),
                  title:
                      Text('Distance: ${directions.distance.round()} metres'),
                ),
              if (directions != null)
                ListTile(
                  leading: Icon(Icons.access_time),
                  title: Text(
                      'Duration: ${directions.duration.inMinutes} minutes'),
                ),
              ButtonBar(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Whatever'),
                  )
                ],
              )
            ],
          ),
        ]
            .map((e) => Card(
                  margin: EdgeInsets.all(8),
                  elevation: 8,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: e,
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class POI {
  final String label;
  final LatLng location;
  final Function onTap;

  POI({this.label, this.location, this.onTap});

  Marker toMarker({@required BuildContext context}) => Marker(
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
