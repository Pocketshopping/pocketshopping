import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geoloc;
import 'package:get/get.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';
import 'package:pocketshopping/src/ui/shared/direction/package_direction.dart';
import 'package:pocketshopping/src/utility/utility.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;

class Direction extends StatefulWidget {
  Direction(
      {@required this.source,
      @required this.destination,
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
  State<StatefulWidget> createState() => DirectionState();
}

class DirectionState extends State<Direction> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  GoogleMapPolyline polylinePoints;
  BitmapDescriptor sourceIcon;
  BitmapDescriptor currentIcon;
  BitmapDescriptor destinationIcon;
  LocationData currentLocation;
  LocationData destinationLocation;
  Location location;
  double pinPillPosition = -100;
  PinInformation currentlySelectedPin = PinInformation(
      pinPath: '',
      avatarPath: PocketShoppingDefaultAvatar,
      location: '',
      locationName: '',
      labelColor: Colors.grey);
  PinInformation sourcePinInfo;
  PinInformation destinationPinInfo;
  PinInformation currentPinInfo;
  FirebaseUser currentUser;
  StreamSubscription<LocationData> locStream;
  RouteMode routeMode;
  String distance;

  @override
  void initState() {
    super.initState();
    location = new Location();
    distance = '';
    location.changeSettings(
        accuracy: LocationAccuracy.navigation, interval: 1000);
    polylinePoints = GoogleMapPolyline(apiKey: googleAPIKey);
    routeMode = RouteMode.driving;
    locStream = location.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
      updatePinOnMap();
      if (mounted) setState(() {});
    });
    setSourceAndDestinationIcons();
    setInitialLocation();
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
      if(mounted)
      setState(() {});
    } else {
      distance = '${(dist / 1000).round()} kilometer(s) away';
      if(mounted)
      setState(() {});
    }
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/markerS.png');

    currentIcon =await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/driving_pin.png');

    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/destination_map_marker.png');
  }

  void setInitialLocation() async {
    currentLocation = await location.getLocation();
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
        zoom: CAMERA_ZOOM,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: widget.source);
    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: CAMERA_ZOOM,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING);
    }
    return Scaffold(
        backgroundColor: Colors.white,
        body: currentLocation != null
            ? Stack(
                children: <Widget>[
                  GoogleMap(
                      myLocationEnabled: false,
                      compassEnabled: true,
                      tiltGesturesEnabled: false,
                      zoomGesturesEnabled: true,
                      markers: _markers,
                      polylines: _polylines,
                      mapType: MapType.normal,
                      initialCameraPosition: initialCameraPosition,
                      onTap: (LatLng loc) {
                        pinPillPosition = -100;
                      },
                      onMapCreated: (GoogleMapController controller) {
                        //controller.setMapStyle(Utility.mapStyles);
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
                    Icons.arrow_back_ios,
                    color: Colors.black54,
                  ), onPressed: () { Get.back(); },
                )
                    : IconButton(
                  icon: Icon(
                    Icons.directions_walk,
                    color: Colors.black54,
                  ), onPressed: () {  },
                ),
                backgroundColor: Colors.white,
              ),
            ],
          ),
        )
            : Container());
  }

  void showPinsOnMap() {
    var pinPosition = LatLng(currentLocation.latitude, currentLocation.longitude);

    var sourcePosition = widget.source;
    var destPosition = LatLng(destinationLocation.latitude, destinationLocation.longitude);

    currentPinInfo = PinInformation(
        locationName: widget.sourceName ?? "You",
        location: widget.sourceAddress ?? "",
        pinPath: "assets/images/driving_pin.png",
        avatarPath: widget.destPhoto != null
            ? widget.destPhoto.isNotEmpty
                ? widget.destPhoto
                : PocketShoppingDefaultAvatar
            : PocketShoppingDefaultAvatar,
        labelColor: Colors.blueAccent);

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
        pinPath: "assets/images/destination_map_marker.png",
        avatarPath: widget.destPhoto != null
            ? widget.destPhoto.isNotEmpty
                ? widget.destPhoto
                : PocketShoppingDefaultCover
            : PocketShoppingDefaultCover,
        labelColor: Colors.purple);


    // add the initial source location pin
    _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: sourcePosition,
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
    _markers.add(Marker(
        markerId: MarkerId('currentPin'),
        position: pinPosition,
        onTap: () {
          if (mounted) {
            setState(() {
              currentlySelectedPin = currentPinInfo;
              pinPillPosition = 0;
            });
          }
        },
        icon: currentIcon)
    );
    setPolylines();
  }

  void setPolylines() async {
    List<LatLng> result = await polylinePoints.getCoordinatesWithLocation(
        origin: widget.source,
        destination: widget.destination,
        mode: routeMode);

    if (result.isNotEmpty) {
      result.forEach((LatLng point) {
        polylineCoordinates.add(point);
      });
      await awayFrom(polylineCoordinates);
      if (mounted) {
        setState(() {
          _polylines.add(Polyline(
              width: 5,
              polylineId: PolylineId("poly"),
              color: Color.fromARGB(255, 40, 122, 198),
              points: polylineCoordinates));
        });
      }
    }
  }


  void updatePinOnMap() async {
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
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
        var pinPosition = LatLng(currentLocation.latitude, currentLocation.longitude);
        _markers.removeWhere((m) => m.markerId.value == 'currentPin');
        _markers.add(Marker(
            markerId: MarkerId('currentPin'),
            onTap: () {
              setState(() {
                currentlySelectedPin = sourcePinInfo;
                pinPillPosition = 0;
              });
            },
            position: pinPosition, // updated position
            icon: currentIcon));

      });
  /*    geoloc.Geolocator().distanceBetween(widget.destination.latitude, widget.destination.longitude, currentLocation.latitude, currentLocation.longitude).then((value)
      {
        if(value <= 50){
          if(!Get.isDialogOpen)
          Utility.infoDialogMaker('You are at the destination');
        }
        else if (value > 50 && value <= 100){
          if(!Get.isDialogOpen)
          Utility.infoDialogMaker('You are few meter away from the destination');
        }
      });*/
    }
   // await awayFrom(polylineCoordinates);
  }
}
