import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';

class MerchantMap extends StatefulWidget {
  MerchantMap(
      {this.source,
      this.destination,
      this.destAddress,
      this.destName,
      this.destPhoto,
      this.sourceName,
      this.sourcePhoto,
      this.sourceAddress});

  final LatLng source;
  final LatLng destination;
  final String destName;
  final String destAddress;
  final String destPhoto;
  final String sourceName;
  final String sourcePhoto;
  final String sourceAddress;

  @override
  State<MerchantMap> createState() => _MerchantMapState();
}

class _MerchantMapState extends State<MerchantMap> {
  Completer<GoogleMapController> _controller = Completer();
  BitmapDescriptor pinLocationIcon;
  Set<Marker> _markers = {};
  LatLng pinPosition;
  bool showMap = false;
  CameraPosition _initial;
  MarkerId markerId;

  @override
  void initState() {
    pinPosition = widget.destination;
    pinLocationIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    markerId = MarkerId('PS1');
    _initial = CameraPosition(
      target: widget.destination,
      tilt: 0.0,
      zoom: 15.1234452,
    );
    _markers.add(Marker(
        markerId: markerId,
        position: _initial.target,
        icon: pinLocationIcon,
        infoWindow: InfoWindow(title: "${widget.destName}", snippet: '${widget.destAddress}'),
        visible: true

    ));
    delay();
    //_controller.future.then((value) => value.showMarkerInfoWindow(markerId));
    super.initState();
  }

  delay() async {
    await Future.delayed(Duration(seconds: 1));

    if (mounted)
      setState(() {
        showMap = true;
      });
  }

  @override
  Widget build(BuildContext context) {
    return showMap
        ? Scaffold(
            body: GoogleMap(
              zoomGesturesEnabled: true,
              mapType: MapType.normal,
              markers: _markers,
              initialCameraPosition: _initial,
              onMapCreated: (GoogleMapController controller)async {
                controller.showMarkerInfoWindow(markerId);
                _controller.complete(controller);
              },
            ),
           /* floatingActionButton: widget.source != null
                ? FloatingActionButton.extended(
                    backgroundColor: PRIMARYCOLOR,
                    onPressed: _getDirection,
                    label: Text('Direction'),
                    icon: Icon(Icons.directions),
                  )
                : Container(),*/
          )
        : Container(
            color: Color.fromRGBO(239, 238, 236, 1),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }

  Future<void> _getDirection() async {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Direction(
            source: widget.source,
            destination: widget.destination,
            destAddress: widget.destAddress,
            destName: widget.destName,
            destContact: widget.destPhoto,
            sourceName: widget.sourceName,
            sourceAddress: widget.sourceAddress,
            sourceContact: widget.sourcePhoto,
          ),
        ));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    //_controller.complete();
  }
}
