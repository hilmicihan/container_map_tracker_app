import 'dart:async';
import 'dart:collection';
import 'package:evreka_bin_tracker/screens/pageConnection.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:evreka_bin_tracker/screens/PageLogin.dart';
import 'package:evreka_bin_tracker/screens/containerInformation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Login(), //MyHomePage(title: 'Flutter Demo Home Page'),
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
  CameraPosition _initialPosition =
      CameraPosition(target: LatLng(39.933365, 32.859741), zoom: 12);
  Position position;
  var _locationStatus;
  bool isLocatinAccess = false;
  // refresh screen to check internet connection
  Timer timer;
  bool isConnected = false;
  void CheckConnectivity() async {
    var ConnectionResult = await (Connectivity().checkConnectivity());
    if (ConnectionResult == ConnectivityResult.mobile ||
        ConnectionResult == ConnectivityResult.wifi) {
      setState(() {
        isConnected = true;
      });
    } else {
      isConnected = false;
      setState(() {});
    }
  }

  Future<void> setPermissions() async {
    print("---------------inside set permissions");
    if (await Permission.location.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      isLocatinAccess = true;
    }

// You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
    ].request();
    print(statuses[Permission.location]);
    print("---------------------Location Access" + isLocatinAccess.toString());
    isLocatinAccess = true;
  }

  Future<void> requestPermission() async {
    await Permission.location.request();
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState

    CheckConnectivity();

    requestPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: isConnected == false
          ? PageConnection()
          : MapScreen(initialPosition: _initialPosition, position: position),
    );
  }
}

class MapScreen extends StatefulWidget {
  MapScreen({
    Key key,
    @required CameraPosition initialPosition,
    @required Position position,
  })  : _initialPosition = initialPosition,
        _currentPosition = position,
        super(key: key);

  final CameraPosition _initialPosition;
  Position _currentPosition;
  final Set<Polyline> polyline = {};

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController _controller;
  List<Marker> allMarkers = [];
  List<LatLng> route;
  Map<int, ContainerInfo> allContainers = new HashMap();
  LatLng lastCoordinate;
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyC7ryucW__dqZ8PdDfjmVtnom-H73DP5hA";
  Map<PolylineId, Polyline> polylines = {};
  setMarkers() {
    return allMarkers;
  }

  @override
  Widget build(BuildContext context) {
    return LoadMap();
  }

  Future takeContainerInfo() async {
    ContainerInfo newContainer;
    final GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(title: Text("Add new container"), children: [
            Column(
              children: [
                Form(
                  key: _keyForm,
                  child: Column(
                    children: [
                      TextFormField(
                          keyboardType: TextInputType.number,
                          onSaved: (input) => newContainer.sensorId = input,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          decoration: InputDecoration(
                              labelText: "Container Id",
                              icon: Icon(Icons.access_alarm))),
                      TextFormField(
                        onSaved: (input) => newContainer.temperature = input,
                        decoration: InputDecoration(labelText: "Temperature"),
                        obscureText: true,
                      ),
                      TextFormField(
                        onSaved: (input) => newContainer.date = input,
                        decoration: InputDecoration(labelText: "Date"),
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    _keyForm.currentState.save();
                    print("-----------------" + newContainer.date);
                    //newContainer.printContainer();
                    //return newContainer;
                  },
                  child: Text("OK"),
                )
              ],
            ),
          ]);
        });
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    polylines.clear();
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blueAccent,
      points: polylineCoordinates,
      visible: true,
      width: 4,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    Position currentPosition =
        await getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
    if (lastCoordinate == null) {
      print("there is no endpoint");

      return;
    }
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(currentPosition.latitude, currentPosition.longitude),
      PointLatLng(lastCoordinate.latitude, lastCoordinate.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }

  Widget LoadMap() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("markers").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Text("Loading Maps. Please Wait.");
        allMarkers.clear();
        for (int i = 0; i < snapshot.data.documents.length; i++) {
          int containerId = snapshot.data.documents[i]["containerId"] ?? 0;
          int occrate = snapshot.data.documents[i]["occRate"] ?? 0;
          allContainers[containerId] = new ContainerInfo(
            date: snapshot.data.documents[i]["Date"] ?? "not entered",
            containerId: containerId,
            occRate: occrate,
            sensorId: snapshot.data.documents[i]["sensorId"] ?? 0,
            temperature:
                snapshot.data.documents[i]["temperature"] ?? "not entered",
            location: new LatLng(
                snapshot.data.documents[i]["location"].latitude,
                snapshot.data.documents[i]["location"].longitude),
          );
          allMarkers.add(
            new Marker(
              draggable: true,
              markerId: MarkerId(
                  snapshot.data.documents[i]["containerId"].toString() ??
                      "not entered"),
              position: new LatLng(
                  snapshot.data.documents[i]["location"].latitude,
                  snapshot.data.documents[i]["location"].longitude),
              infoWindow: InfoWindow(
                  title: "Container Id:" + containerId.toString(),
                  snippet: "Occupuncy Rate: " + occrate.toString()),
              onTap: () {
                setState(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PageContainerInfo(
                              bin: allContainers[containerId],
                            )),
                  );
                });
              },
            ),
          );
          print(snapshot.data.documents.length);
        }
        return new Stack(children: [
          GoogleMap(
            initialCameraPosition: widget._initialPosition,
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            polylines: Set<Polyline>.of(polylines.values),
            onMapCreated: (controller) {
              setState(() {
                _controller = controller;
              });
            },
            markers: Set.from(allMarkers),
            onTap: (coordinate) {
              _controller.animateCamera(CameraUpdate.newLatLng(coordinate));
              lastCoordinate = coordinate;
            },
          ),
          Positioned(
              bottom: 20,
              right: 60,
              child: FlatButton(
                  onPressed: _addMarker,
                  color: Colors.green,
                  child: Column(
                    children: [
                      Icon(
                        Icons.plus_one,
                        color: Colors.white,
                      ),
                      Text("Add Container"),
                    ],
                  ))),
          Positioned(
              left: 20,
              bottom: 20,
              child: FlatButton(
                  onPressed: _getPolyline,
                  color: Colors.green,
                  child: Icon(
                    Icons.navigation,
                    color: Colors.white,
                  ))),
          Positioned(
              left: 120,
              bottom: 20,
              child: FlatButton(
                  onPressed: _clearPolyline,
                  color: Colors.green,
                  child: Column(
                    children: [
                      Icon(
                        Icons.exit_to_app,
                        color: Colors.white,
                      ),
                      Text("Exit navigation")
                    ],
                  ))),
        ]);
      },
    );
  }

  void _addMarker() async {
    FirebaseFirestore.instance.collection("markers").add({
      "location":
          new GeoPoint(lastCoordinate.latitude, lastCoordinate.longitude),
      "containerId": allMarkers.length + 1,
      "occRate": 0,
      "sensorId": "not entered",
      "temperature": "not entered",
      "Date": "not entered",
    });
  }

  void _clearPolyline() {
    polylines.clear();
    setState(() {});
  }
}
