import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';
 
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
 
  @override
  _HomePageState createState() => _HomePageState();
}
 
class _HomePageState extends State<HomePage> {
  bool _hasPermission = false;
  DateTime? _lastReadAt;
  CompassEvent? _lastRead;
 
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchPermission();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Compass App"),
      ),
      body: Builder(builder: (context) {
        if (_hasPermission) {
          return Column(
            children: [_buildmanualReader(),
            SizedBox(height: 45,),
             _buildCompass()],
          );
        } else {
          return _buildPermissionSheet();
        }
      }),
    );
  }
 
  Widget _buildCompass() {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<CompassEvent>(
            stream: FlutterCompass.events,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("The event has error ");
              }
 
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
 
              double? direction = snapshot.data!.heading;
 
              if (direction == null) {
                Text("Device has no sensors");
              }
 
              return Center(
                child: Card(
                  elevation: 4,
                  shape: CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: Transform.rotate(angle: (direction! *(math.pi/180)),
                  child: Image.asset("assets/images/compass.jpg"),
                  ),
                  // child: Image.asset("assets/images/compass.jpg"),
                ),
              );
            }));
  }
 
  Widget _buildmanualReader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          ElevatedButton(
              onPressed: () async {
                final CompassEvent temp = await FlutterCompass.events!.first;
 
                setState(() {
                  _lastRead = temp;
                  _lastReadAt = DateTime.now();
                });
              },
              child: Text("Refresh")),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text("$_lastRead"),
            SizedBox(height: 10),
            Text("$_lastReadAt"),
          ])
        ],
      ),
    );
  }
 
  Widget _buildPermissionSheet() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Location Permission Required"),
          ElevatedButton(
              onPressed: () {
                Permission.locationWhenInUse.request().then((ignored) {
                  _fetchPermission();
                });
              },
              child: Text("Request Permission"))
        ],
      ),
    );
  }
 
  void _fetchPermission() {
    Permission.locationWhenInUse.status.then((status) {
      setState(() {
        _hasPermission = status == PermissionStatus.granted;
      });
    });
  }
}
 

