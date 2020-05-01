import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart' as geoloc;
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:pocketshopping/src/ui/shared/direction/package_direction.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';


const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;



class Direction extends StatefulWidget {

  Direction({
    @required this.source,
    @required this.destination,
    this.destAddress,
    this.destName,
    this.destPhoto,
    this.sourceName,
    this.sourcePhoto,
    this.sourceAddress
  });
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
  String googleAPIKey = 'AIzaSyDWhKPubZYbSnuCUcOHyYptuQsXQYRDdSc';
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
  FirebaseUser CurrentUser;
  StreamSubscription<LocationData> locStream;
  RouteMode routeMode;
  String distance;

  @override
  void initState() {
    super.initState();
    location = new Location();
    distance='';
    location.changeSettings(accuracy: LocationAccuracy.navigation
        ,interval: 1000);
    polylinePoints = GoogleMapPolyline(apiKey: googleAPIKey);
    routeMode = RouteMode.walking;
    locStream=location.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
      updatePinOnMap();
      if(mounted)
      setState(() { });
    });
    setSourceAndDestinationIcons();
    setInitialLocation();
  }

  AwayFrom(List<LatLng> polylineCoordinates)async{
    print(polylineCoordinates[0]);
    double dist = 0.0;

    for (int i=0; i< polylineCoordinates.length;i++){

      if(polylineCoordinates[i] == polylineCoordinates.last){
        dist += await geoloc.Geolocator().distanceBetween(
            polylineCoordinates[i-1].latitude,
            polylineCoordinates[i-1].longitude,
            polylineCoordinates[i].latitude,
            polylineCoordinates[i].longitude);
      }
      else{
        dist += await geoloc.Geolocator().distanceBetween(
            polylineCoordinates[i].latitude,
            polylineCoordinates[i].longitude,
            polylineCoordinates[i+1].latitude,
            polylineCoordinates[i+1].longitude);
      }

    }
    if(dist < 1000 ){
      distance= '${dist.round()} meter(s) away';
      setState(() { });
    }
    else{
      distance= '${(dist/1000).round()} kilometer(s) away';
      setState(() { });
    }


  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/images/driving_pin.png');

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
    location=null;
    _controller=null;
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
      body: currentLocation != null ?Stack(
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
                controller.setMapStyle(Utils.mapStyles);
                _controller.complete(controller);
                // my map has completed being created;
                // i'm ready to show the pins on the map
                showPinsOnMap();
              }),
          MapPinPillComponent(
              pinPillPosition: pinPillPosition,
              currentlySelectedPin: currentlySelectedPin)
        ],
      ):
      Center(
        child: CircularProgressIndicator(),
      )
      ,      //store btn

        floatingActionButtonLocation:
        FloatingActionButtonLocation.centerDocked,
        floatingActionButton: currentLocation !=null ?Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FloatingActionButton.extended(
                onPressed: () {},
                label: Text(distance,style: TextStyle(color: Colors.black54),),
                icon: routeMode == RouteMode.driving?
                IconButton(icon: Icon(Icons.drive_eta,color: Colors.black54,),):
                IconButton(icon: Icon(Icons.directions_walk,color: Colors.black54,),),
                backgroundColor: Colors.grey,
              ),
              FloatingActionButton(
                onPressed: (){
                  routeMode = routeMode == RouteMode.driving?RouteMode.walking:RouteMode.driving;
                  setState(() { });
                  _polylines.clear();
                  polylineCoordinates.clear();
                  showPinsOnMap();
                },
                child: routeMode == RouteMode.driving?
                IconButton(icon: Icon(Icons.directions_walk,color: Colors.black54,),):
                IconButton(icon: Icon(Icons.drive_eta,color: Colors.black54,),),
                backgroundColor: Colors.grey,
              )
            ],
          ),
        ):Container()
    );
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
        locationName: widget.sourceName??"You",
        location: widget.sourceAddress??"",
        pinPath: "assets/images/driving_pin.png",
        avatarPath: widget.destPhoto !=null?widget.destPhoto.isNotEmpty?widget.destPhoto:PocketShoppingDefaultAvatar:PocketShoppingDefaultAvatar,
        labelColor: Colors.blueAccent);

    destinationPinInfo = PinInformation(
        locationName: widget.destName??"Destination",
        location: widget.destAddress??"",
        pinPath: "assets/images/destination_map_marker.png",
        avatarPath: widget.destPhoto !=null?widget.destPhoto.isNotEmpty?widget.destPhoto:PocketShoppingDefaultCover:PocketShoppingDefaultCover,
        labelColor: Colors.purple);

    // add the initial source location pin
    _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: pinPosition,
        onTap: () {
          if(mounted) {
          setState(() {

              currentlySelectedPin = sourcePinInfo;
              pinPillPosition = 0;

          });
          }
        },
        icon: sourceIcon));
    // destination pin
    _markers.add(
        Marker(
        markerId: MarkerId('destPin'),
        position: destPosition,
        onTap: () {
          if(mounted) {
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
        origin: LatLng(
          currentLocation.latitude,
          currentLocation.longitude
        ), destination: LatLng(
      destinationLocation.latitude,
      destinationLocation.longitude,
    ), mode: routeMode);



    if (result.isNotEmpty) {
      result.forEach((LatLng point) {
        polylineCoordinates.add(point);
      });
      await AwayFrom(polylineCoordinates);
      if(mounted) {
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
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );
    if(mounted){
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    }
    if(mounted) {
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
  static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "color": "#C3C3C3"
        
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';
}