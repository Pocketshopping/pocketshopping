import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart' as geoloc;
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';
import 'package:pocketshopping/src/ui/shared/direction/package_direction.dart';
import 'package:pocketshopping/src/utility/utility.dart';

//const double CAMERA_ZOOM = 13;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 20;

class ErrandDirection extends StatefulWidget {
  ErrandDirection(
      {@required this.source,
        @required this.destination,
        this.destAddress,
        this.destName,
        this.destPhoto,
        this.sourceName,
        this.sourcePhoto,
        this.sourceAddress,
        this.zoom,
      });

  final LatLng source;
  final LatLng destination;
  final String destName;
  final String destAddress;
  final String destPhoto;
  final String sourceName;
  final String sourcePhoto;
  final String sourceAddress;
  final double zoom;

  @override
  State<StatefulWidget> createState() => ErrandDirectionState();
}

class ErrandDirectionState extends State<ErrandDirection> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  GoogleMapPolyline polylinePoints;
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  LocationData currentLocation;
  LocationData destinationLocation;
  Location location;
  double pinPillPosition = -100;
  PinInformation currentlySelectedPin = PinInformation(
      pinPath: '',
      avatarPath: '',
      location: '',
      locationName: '',
      labelColor: Colors.grey);
  PinInformation sourcePinInfo;
  PinInformation destinationPinInfo;
  FirebaseUser currentUser;
  StreamSubscription<LocationData> locStream;
  RouteMode routeMode;
  String distance;
  double zoom;
  LatLng centroid;

  @override
  void initState() {

    location = new Location();
    distance = '';
    zoom = widget.zoom;
    location.changeSettings(accuracy: LocationAccuracy.navigation, interval: 1000);
    polylinePoints = GoogleMapPolyline(apiKey: googleAPIKey);
    routeMode = RouteMode.driving;
    //locStream = location.onLocationChanged.listen((LocationData cLoc) {currentLocation = cLoc;updatePinOnMap();if (mounted) setState(() {});});
    setSourceAndDestinationIcons();
    setInitialLocation();
    centroid  = Utility.computeCentroid([widget.source,widget.destination])??widget.destination;
    super.initState();
  }

  awayFrom(List<LatLng> polylineCoordinates) async {
    print(polylineCoordinates[0]);
    double dist = 0.0;

    for (int i = 0; i < polylineCoordinates.length; i++) {
      if (polylineCoordinates[i] == polylineCoordinates.last) {
        dist += await geoloc.Geolocator().distanceBetween(
            polylineCoordinates[i - 1].latitude,
            polylineCoordinates[i - 1].longitude,
            polylineCoordinates[i].latitude,
            polylineCoordinates[i].longitude);
      } else {
        dist += await geoloc.Geolocator().distanceBetween(
            polylineCoordinates[i].latitude,
            polylineCoordinates[i].longitude,
            polylineCoordinates[i + 1].latitude,
            polylineCoordinates[i + 1].longitude);
      }
    }
    if (dist < 1000) {
      distance = '${dist.round()} meter(s) away';
      zoom = Utility.zoomer(dist.round());
      setState(() {});
    } else {
      distance = '${(dist / 1000).round()} kilometer(s) away';
      zoom = Utility.zoomer((dist / 1000).round());
      setState(() {});
    }
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/markerS.png');

    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/markerD.png');
  }

  void setInitialLocation() async {
    currentLocation = LocationData.fromMap({
      "latitude": widget.source.latitude,
      "longitude": widget.source.longitude
    });
    //await location.getLocation();
    destinationLocation = LocationData.fromMap({
      "latitude": widget.destination.latitude,
      "longitude": widget.destination.longitude
    });
  }

  @override
  void dispose() {
    locStream.cancel();
    location = null;
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
        zoom: zoom,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: centroid);
    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
          target: centroid,
          zoom: zoom,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING);
    }
    return Scaffold(
        backgroundColor: Colors.white,
        body: currentLocation != null
            ? Stack(
          children: <Widget>[
            GoogleMap(
                myLocationEnabled: true,
                compassEnabled: true,
                tiltGesturesEnabled: false,
                markers: _markers,
                polylines: _polylines,
                mapType: MapType.normal,
                initialCameraPosition: initialCameraPosition,
                onTap: (LatLng loc) {
                  pinPillPosition = -100;
                },
                onMapCreated: (GoogleMapController controller) {
                 // controller.setMapStyle(Utility.mapStyles);
                  _controller.complete(controller);
                  // my map has completed being created;
                  // i'm ready to show the pins on the map
                  showPinsOnMap();
                }),
            MapPinPillComponent(
                pinPillPosition: pinPillPosition,
                currentlySelectedPin: currentlySelectedPin)
          ],
        )
            : Center(
          child: CircularProgressIndicator(),
        ), //store btn

        floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
        floatingActionButton: currentLocation != null
            ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FloatingActionButton.extended(
                onPressed: () {},
                label: Text(
                  distance,
                  style: TextStyle(color: Colors.black54),
                ),
                icon: routeMode == RouteMode.driving
                    ? IconButton(
                  icon: Icon(
                    Icons.drive_eta,
                    color: Colors.black54,
                  ), onPressed: () {  },
                )
                    : IconButton(
                  icon: Icon(
                    Icons.directions_walk,
                    color: Colors.black54,
                  ), onPressed: () {  },
                ),
                backgroundColor: Colors.grey,
              ),
            ],
          ),
        )
            : Container());
  }

  void showPinsOnMap() {
    // get a LatLng for the source location
    // from the LocationData currentLocation object
    var pinPosition =
    LatLng(currentLocation.latitude, currentLocation.longitude);
    // get a LatLng out of the LocationData object
    var destPosition =
    LatLng(destinationLocation.latitude, destinationLocation.longitude);

    sourcePinInfo = PinInformation(
        locationName: widget.sourceName ?? "Source",
        location: widget.sourceAddress ?? "",
        pinPath: "assets/images/markerS.png",
        avatarPath: widget.destPhoto != null
            ? widget.destPhoto.isNotEmpty
            ? widget.destPhoto
            : PocketShoppingDefaultAvatar
            : PocketShoppingDefaultAvatar,
        labelColor: Colors.blueAccent);

    destinationPinInfo = PinInformation(
        locationName: widget.destName ?? "Destination",
        location: widget.destAddress ?? "",
        pinPath: "assets/images/markerD.png",
        avatarPath: widget.destPhoto != null
            ? widget.destPhoto.isNotEmpty
            ? widget.destPhoto
            : PocketShoppingDefaultCover
            : PocketShoppingDefaultCover,
        labelColor: Colors.purple);

    // add the initial source location pin
    _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: pinPosition,
        onTap: () {
          if (mounted) {
            setState(() {
              currentlySelectedPin = sourcePinInfo;
              pinPillPosition = 0;
            });
          }
        },
        icon: sourceIcon));
    // destination pin
    _markers.add(Marker(
        markerId: MarkerId('destPin'),
        position: destPosition,
        onTap: () {
          if (mounted) {
            setState(() {
              currentlySelectedPin = destinationPinInfo;
              pinPillPosition = 0;
            });
          }
        },
        icon: destinationIcon));
    // set the route lines on the map from source to destination
    // for more info follow this tutorial
    setPolylines();
  }

  void setPolylines() async {
    List<LatLng> result = await polylinePoints.getCoordinatesWithLocation(
        origin: LatLng(currentLocation.latitude, currentLocation.longitude),
        destination: LatLng(destinationLocation.latitude, destinationLocation.longitude,),
        mode: routeMode);

    if (result.isNotEmpty) {
      result.forEach((LatLng point) {
        polylineCoordinates.add(point);
      });
      await awayFrom(polylineCoordinates);
      if (mounted) {
        setState(() {
          _polylines.add(Polyline(
              width: 5, // set the width of the polylines
              polylineId: PolylineId("poly"),
              color: Color.fromARGB(255, 40, 122, 198),
              points: polylineCoordinates));
        });
      }
    }
  }

  void updatePinOnMap() async {
    CameraPosition cPosition = CameraPosition(
      zoom: zoom,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );
    if (mounted) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    }
    if (mounted) {
      setState(() {
        var pinPosition =
        LatLng(currentLocation.latitude, currentLocation.longitude);
        _markers.removeWhere((m) => m.markerId.value == 'sourcePin');
        _markers.add(Marker(
            markerId: MarkerId('sourcePin'),
            onTap: () {
              setState(() {
                currentlySelectedPin = sourcePinInfo;
                pinPillPosition = 0;
              });
            },
            position: pinPosition, // updated position
            icon: sourceIcon));
      });
    }
  }
}

class Utils {

}
