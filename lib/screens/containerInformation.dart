import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ContainerInfo {
  String date;
  int containerId;
  int occRate;
  String sensorId;
  String temperature;
  LatLng location;
  ContainerInfo({
    this.containerId,
    this.date = "not entered",
    this.occRate = 0,
    this.sensorId = "not entered",
    this.temperature = "not entered",
    this.location,
  });
  void printContainer() {
    print("----------------container ınfo----------------- ");
    print("Container Id" + this.containerId.toString());
    print("date" + this.date);

    print("occ rate " + this.occRate.toString());
    print("Sensor Id" + this.sensorId);
    print("temperature" + this.temperature);
    print("Location" + this.location.toString());
  }
}

class PageContainerInfo extends StatefulWidget {
  ContainerInfo bin;
  PageContainerInfo({this.bin});

  @override
  _PageContainerInfoState createState() => _PageContainerInfoState();
}

class _PageContainerInfoState extends State<PageContainerInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Container Information"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Image(image: AssetImage('assets/evreka.jpg')),
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.green,
                    ),
                    width: 300,
                    height: 50,
                    alignment: Alignment.center,
                    child: Text(
                        "Container Id: " + widget.bin.containerId.toString()),
                  ), //Container Id
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: 300,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.green,
                    ),
                    child: Text(
                        "Occupuncy Rate: " + widget.bin.occRate.toString()),
                  ), //occupuncy rate
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: 300,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.green,
                    ),
                    child: Text("Temperature: " + widget.bin.temperature),
                  ), // temperature
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: 300,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.green,
                    ),
                    child: Text("Date:" + widget.bin.date),
                  ), //date
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: 300,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.green,
                    ),
                    child: Text("Sensor Id:" + widget.bin.sensorId),
                  ), // sensor Id
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
