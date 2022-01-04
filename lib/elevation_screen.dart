import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ElevationScreen extends StatefulWidget {
  ElevationScreen({Key? key}) : super(key: key);

  @override
  _ElevationScreenState createState() => _ElevationScreenState();
}

class _ElevationScreenState extends State<ElevationScreen> {

  @override
  void initState() {
    super.initState();
    // If has permission - run getElevation right away, otherwise request for it,
    // and if granted - run getElevation
    Geolocator.checkPermission().then((permission) {
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        initGeolocaor();
      } else {
        Geolocator.requestPermission().then((permission) {
          if (permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse) {
            initGeolocaor();
          }
        });
      }
    });
  }

  void initGeolocaor() {
    Geolocator.getPositionStream().listen((position) {
      setState(() {
        long = position.longitude;
        lat = position.latitude;
        alt = position.altitude;
      });
      requestAltitude(position.latitude, position.longitude);
    });
  }

  Future<void> requestAltitude(double lat, double long) async {
    final request =
        "https://api.opentopodata.org/v1/test-dataset?locations=$lat,$long";

    print('Sending request...');
    final response = await Dio(BaseOptions(headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    })).get(request);
    if (response.data != null) {
      print(response.data);
      try {
        final elevation = response.data['results'].first['elevation'] as num;
        setState(() {
          elev = elevation.toDouble();
        });
      } catch (_) {
        // do nothing;
      }
    } else {
      print('Go fuck yourself');
    }
  }

  // Future<void> getElevation() async {
  //   final location = await Geolocator.getCurrentPosition();
  //   // final location = Location();
  //   // Location
  //   // final locationData = await Location.instance.getLocation();
  //   setState(() {
  //     long = location.longitude;
  //     lat = location.latitude;
  //     elev = null;
  //   });
  //   final request =
  //       "https://api.opentopodata.org/v1/test-dataset?locations=$lat,$long";

  //   final body = {
  //     "locations": {
  //       "latitude": lat,
  //       "longitude": long,
  //     }
  //   };
  //   print('Sending request...');
  //   final response = await Dio(BaseOptions(headers: {
  //     'Content-Type': 'application/json',
  //     'Accept': 'application/json',
  //   })).get(request);
  //   if (response.data != null) {
  //     print(response.data);
  //     try {
  //       final elevation = response.data['results'].first['elevation'] as num;
  //       setState(() {
  //         elev = elevation.toDouble();
  //       });
  //     } catch (_) {
  //       // do nothing;
  //     }
  //   } else {
  //     print('Go fuck yourself');
  //   }
  // }

  double? long;
  double? lat;
  double? alt;
  double? elev;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // IconButton(
          //     onPressed: () {
          //       getElevation();
          //     },
          //     icon: Icon(Icons.refresh))
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Elevation: ${elev ?? '...'}",
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            Text(
              'Altitude: $alt',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            Text(
              'Latitude: $lat',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            Text(
              'Longitude: $long',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
