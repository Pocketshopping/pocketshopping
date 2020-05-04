import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pocketshopping/component/MerchantDestination.dart';

class MerchantMap extends StatefulWidget {
  static String tag = 'MerchantMap-page';

  @override
  State<MerchantMap> createState() => _MerchantMapState();
}

class _MerchantMapState extends State<MerchantMap> {
  Completer<GoogleMapController> _controller = Completer();
  BitmapDescriptor pinLocationIcon;
  Set<Marker> _markers = {};
  LatLng pinPosition = LatLng(9.0866644, 7.4592741);

  @override
  void initState() {
    //BitmapDescriptor.fromAssetImage(
    //ImageConfiguration(devicePixelRatio: 2.5),
    //'assets/images/marker.png').then((onValue) {
    pinLocationIcon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    //});
  }

  static final CameraPosition _initial = CameraPosition(
    target: LatLng(9.0866644, 7.4592741),
    tilt: 0.0,
    zoom: 17.1234452,
  );

  static final CameraPosition _direction = CameraPosition(
      //bearing: 192.8334901395799,
      target: LatLng(9.0866644, 7.4592741),
      //tilt: 19.440717697143555,
      zoom: 19);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        markers: _markers,
        initialCameraPosition: _initial,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);

          setState(() {
            _markers.add(Marker(
                markerId: MarkerId('<MARKER_ID>'),
                position: _initial.target,
                icon: pinLocationIcon));
          });
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xff33805D),
        onPressed: _goToTheLake,
        label: Text('Direction'),
        icon: Icon(Icons.directions),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    Navigator.of(context).pushNamed(MerchantDestination.tag);
  }
}
