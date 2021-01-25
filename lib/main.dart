import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:map_api_demo/mapbox_api_key.dart';
import 'package:map_api_demo/src/map_widget.dart';
import 'package:map_api_demo/src/mapbox_api.dart';
import 'package:map_markers/map_markers.dart';

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
                  waypoints: [
                    Marker(
                      point: LatLng(50.773333333333, 9.0233333333333),
                      width: 50,
                      height: 50,
                      builder: (c) => IconButton(
                        icon: Icon(
                          Icons.location_on,
                          size: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                        tooltip: 'Dannenrod',
                        onPressed: () {},
                      ),
                    ),
                    Marker(
                        point: LatLng(50.7279033, 8.9955088),
                        width: 50,
                        height: 50,
                        builder: (c) => ElevatedButton(child: Text('Homberg'))),
                    Marker(
                        point: LatLng(50.8308912, 8.9544324),
                        width: 50,
                        height: 50,
                        builder: (c) =>
                            ElevatedButton(child: Text('Stadtallendorf'))),
                  ],
                ),
                height: 500,
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
