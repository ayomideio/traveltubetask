import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'dart:async';

import 'package:device_region/device_region.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:shake_gesture/shake_gesture.dart';

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import 'package:maplibre_gl/maplibre_gl.dart';
// import 'package:shake_gesture_test_helper/shake_gesture_test_helper.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapController _mapController = MapController();
  int _shakeCount = 0;
  MaplibreMapController? mapController;
  var isLight = true;

  _onMapCreated(MaplibreMapController controller) {
    mapController = controller;
  }

  _onStyleLoadedCallback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Style loaded :)"),
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _makeEmergencyCall() async {
    try {
      final userCountryCode = await DeviceRegion.getSIMCountryCode();
      // Read the JSON file
      // final File file = File('emergency_contacts.json');
      String jsonString =
          await rootBundle.loadString('emergency_contacts.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> emergencyContacts = data['data'];

      String? emergencyNumber;
      for (var contact in emergencyContacts) {
        if (contact['country_code'] == userCountryCode) {
          emergencyNumber = 'tel:${contact['call_code']}';
          print('emergency number $emergencyNumber');
          break;
        }
      }

      if (emergencyNumber != null) {
        if (await launchUrl(Uri.parse(emergencyNumber))) {
          await launchUrl(Uri.parse(emergencyNumber));
        } else {
          // throw 'Could not launch $emergencyNumber';
        }
      } else {
        throw 'Emergency number not found for call code: $userCountryCode';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }

// Future<void> _makeEmergencyCall(String userCountryCode) async {

//   final String apiUrl = 'https://demoauth.travtubes.com/api/client/v2/location/country/get-all-emergency-contacts';

//   try {
//     final response = await http.get(Uri.parse(apiUrl));
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       final List<dynamic> emergencyContacts = data['data'];

//       String? emergencyNumber;
//       for (var contact in emergencyContacts) {
//         if (contact['country_code'] == userCountryCode) {
//           emergencyNumber = 'tel:${contact['call_code']}';
//           break;
//         }
//       }

//       if (emergencyNumber != null) {
//         if (await launchUrl(Uri.parse(emergencyNumber))) {
//           await launchUrl(Uri.parse(emergencyNumber));
//         } else {
//           throw 'Could not launch $emergencyNumber';
//         }
//       } else {
//         throw 'Emergency number not found for call code: $userCountryCode';
//       }
//     } else {
//       throw 'Failed to retrieve emergency contacts. Status code: ${response.statusCode}';
//     }
//   } catch (e) {
//     throw 'Error: $e';
//   }
// }

// Future<void> _makeEmergencyCall() async {
//     // Make sure to handle permission requests and platform-specific dialing code.
//     const String emergencyNumber = 'tel:911';
//     if (await launchUrl(Uri.parse(emergencyNumber))) {
//       await launchUrl(Uri.parse(emergencyNumber));
//     } else {
//       throw 'Could not launch $emergencyNumber';
//     }
//   }

  // void _getCurrentLocation() async {
  //   Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  //   setState(() {
  //     _initialPosition = LatLng(position.latitude, position.longitude);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: GestureDetector(
              onTap: () {
                _makeEmergencyCall();
              },
              child: Text('Task')),
        ),
        body: ShakeGesture(
            onShake: () {
              setState(() {
                _shakeCount++;
                if (_shakeCount >= 5) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Calling')),
                  );
                  _makeEmergencyCall();
                  _shakeCount = 0; // Reset the shake count after dialing
                }
              });
            },
            child: MaplibreMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition:
                  const CameraPosition(target: LatLng(0.0, 0.0)),
              onStyleLoadedCallback: _onStyleLoadedCallback,
            )

            // FlutterMap(
            //   options: MapOptions(
            //     initialCenter: const LatLng(51.5, -0.09),
            //     initialZoom: 5,
            //     cameraConstraint: CameraConstraint.contain(
            //       bounds: LatLngBounds(
            //         const LatLng(-90, -180),
            //         const LatLng(90, 180),
            //       ),
            //     ),
            //   ),
            //   children: [
            //     openStreetMapTileLayer,
            //     RichAttributionWidget(
            //       popupInitialDisplayDuration: const Duration(seconds: 5),
            //       animationConfig: const ScaleRAWA(),
            //       showFlutterMapAttribution: false,
            //       attributions: [
            //         TextSourceAttribution(
            //           'OpenStreetMap contributors',
            //           onTap: () async => launchUrl(
            //             Uri.parse('https://openstreetmap.org/copyright'),
            //           ),
            //         ),
            //         const TextSourceAttribution(
            //           'This attribution is the same throughout this app, except '
            //           'where otherwise specified',
            //           prependCopyright: false,
            //         ),
            //       ],
            //     ),
            //   ],
            // ),

            ));
  }
}
