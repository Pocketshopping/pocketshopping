import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geoloc;
import 'package:get/get.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:pocketshopping/src/location/bloc/locationBloc.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/order/repository/currentPathLine.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';
import 'package:pocketshopping/src/ui/shared/direction/bloc/errandDirectionBloc.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;

class Direction extends StatefulWidget {
  Direction(
      {@required this.source,
      @required this.destination,
      this.destAddress,
      this.destName,
      this.destContact,
      this.sourceName,
      this.sourceContact,
      this.sourceAddress,
      this.autoType="MotorBike",
      this.user,
      });

  final LatLng source;
  final LatLng destination;
  final String destName;
  final String destAddress;
  final String destContact;
  final String sourceName;
  final String sourceContact;
  final String sourceAddress;
  final String autoType;
  final User user;

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
  User currentUser;
  StreamSubscription<LocationData> locStream;
  RouteMode routeMode;
  String distance;
  StreamSubscription<CurrentPathLine> pathLineStream;
  final pathLine = ValueNotifier<CurrentPathLine>(null);
  final slider = new PanelController();
  Stream<LocationData> lStream;

  Stream<CurrentPathLine> _pathStream;

  @override
  void initState() {
    Future.delayed(Duration(seconds: 1),(){
      currentUser = widget.user;
      location = new Location();
      distance = '';
      location.changeSettings(accuracy: LocationAccuracy.navigation, interval: 1000);
      polylinePoints = GoogleMapPolyline(apiKey: googleAPIKey);
      routeMode = RouteMode.driving;
      locStream = location.onLocationChanged.listen((LocationData cLoc) {LocationBloc.instance.newLocationUpdate(cLoc);});
      setSourceAndDestinationIcons();
      setInitialLocation();

      lStream = LocationBloc.instance.locationStream;
      lStream.listen((LocationData cLoc) async {
        currentLocation = cLoc;
        updatePinOnMap();
        if (mounted) setState(() {});
        await LogisticRepo.updateAgentTrackerLocation(widget.user.uid,cLoc);
      });
      pathLineStream = OrderRepo.currentPathLineStream(currentUser.uid).listen((event) {
        if(event != null) {
          pathLine.value = event;
          updatePolyLines(event);
          ErrandDirectionBloc.instance.newPath(event);
        }

      });
    });
    super.initState();
  }

  awayFrom(List<LatLng> polylineCoordinates) async {
    //print(polylineCoordinates[0]);
    double dist = 0.0;

    for (int i = 0; i < polylineCoordinates.length; i++) {
      if (polylineCoordinates[i] == polylineCoordinates.last) {
        dist +=  geoloc.distanceBetween(
            polylineCoordinates[i - 1].latitude,
            polylineCoordinates[i - 1].longitude,
            polylineCoordinates[i].latitude,
            polylineCoordinates[i].longitude);
      } else {
        dist +=  geoloc.distanceBetween(
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

  String getRiderIcon(String type){
    switch(type){
      case 'MotorBike':
        return 'assets/images/delivery.png';
      break;

      case 'Car':
        return 'assets/images/deliverycar.png';
        break;

      case 'Van':
        return 'assets/images/truck.png';
        break;

      default:
        return 'assets/images/delivery.png';
        break;

    }
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.0),
        'assets/images/markerS.png');

    currentIcon =await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.0),
        getRiderIcon(widget.autoType));

    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.0),
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
    locStream?.cancel();
    pathLineStream?.cancel();
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
    return ValueListenableBuilder(
        valueListenable: pathLine,
        builder: (_,CurrentPathLine path,__){
          return Scaffold(
        backgroundColor: Colors.white,
        body: SlidingUpPanel(
          controller: slider,
          body: currentLocation != null
              ?
          GoogleMap(
              myLocationEnabled: false,
              compassEnabled: true,
              tiltGesturesEnabled: false,
              zoomGesturesEnabled: true,
              markers: _markers,
              polylines: _polylines,
              mapType: MapType.normal,
              initialCameraPosition: initialCameraPosition,
              onTap: (LatLng loc) {},
              onMapCreated: (GoogleMapController controller) {
                controller.setMapStyle(Utility.directionMapStyles);
                _controller.complete(controller);
                // my map has completed being created;
                // i'm ready to show the pins on the map
                showPinsOnMap();
              })
              : Center(child: CircularProgressIndicator(),),
          renderPanelSheet: false,
         panel: _floatingPanel(path),
         collapsed: _floatingCollapsed(path),
          slideDirection: SlideDirection.DOWN,
        )
          );
            }
        );
  }

  void showPinsOnMap() {
    var pinPosition = LatLng(currentLocation.latitude, currentLocation.longitude);

    var sourcePosition = widget.source;
    var destPosition = widget.destination;


    // add the initial source location pin
    _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        infoWindow: InfoWindow(
            title: 'Source',
            snippet: '${widget.sourceAddress}'

        ),
        position: sourcePosition,
        icon: sourceIcon));
    // destination pin
    _markers.add(Marker(
        markerId: MarkerId('destPin'),
        infoWindow: InfoWindow(
            title: 'Destination',
            snippet: '${widget.destAddress}'

        ),
        position: destPosition,
        icon: destinationIcon));
    _markers.add(Marker(
        markerId: MarkerId('currentPin'),
        infoWindow: InfoWindow(
            title: 'You',
            snippet: 'rider'

        ),
        position: pinPosition,
        icon: currentIcon)
    );

    /*if(pathLine.value == null){
      setDestinationPolylines();
    }
    else{
      if(!pathLine.value.hasVisitedSource)
        setSourcePolylines();
      else
        setDestinationPolylines();
    }*/

  }

  void setSourcePolylines() async {
    List<LatLng> result = await polylinePoints.getCoordinatesWithLocation(
        origin: LatLng(currentLocation.latitude,currentLocation.longitude),
        destination: widget.source,
        mode: routeMode);

    if (result.isNotEmpty) {
      result.forEach((LatLng point) {
        polylineCoordinates.add(point);
      });
      //await awayFrom(polylineCoordinates);
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

  void setDestinationPolylines() async {
    List<LatLng> result = await polylinePoints.getCoordinatesWithLocation(
        origin: LatLng(currentLocation.latitude,currentLocation.longitude),
        destination: widget.destination,
        mode: routeMode);

    if (result.isNotEmpty) {
      result.forEach((LatLng point) {
        polylineCoordinates.add(point);
      });
      //await awayFrom(polylineCoordinates);
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
      setState((){
        var pinPosition = LatLng(currentLocation.latitude, currentLocation.longitude);
        _markers.removeWhere((m) => m.markerId.value == 'currentPin');
        _markers.add(Marker(
            rotation: currentLocation.heading,
            flat: true,
            infoWindow: InfoWindow(
              title: 'You',
              snippet: 'rider'

            ),
            markerId: MarkerId('currentPin'),
            position: pinPosition, // updated position
            icon: currentIcon));
      });
    }
  }

  void updatePolyLines(CurrentPathLine path) async{
    if (mounted) {
      setState(() {
        polylineCoordinates.clear();
        _polylines.clear();
        if(path.hasVisitedSource)
          setDestinationPolylines();
        else
          setSourcePolylines();
      });
    }
  }

  Widget _floatingCollapsed(CurrentPathLine path){
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      margin: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(flex: 0,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black54,
              ), onPressed: () {
              Get.back();
            },
            ),),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if(path != null)
                    if(!path.hasVisitedSource && !path.hasVisitedDestination)
                      Center(
                        child:
                          Text('Get package from Source',
                            style: TextStyle(color: Colors.black54,fontSize: 18,fontWeight: FontWeight.bold),),

                      ),

                  if(path != null)
                    if(path.hasVisitedSource && !path.hasVisitedDestination )
                      Center(
                        child:
                          Text('Take package to Destination',
                            style: TextStyle(color: Colors.black54,fontSize: 18,fontWeight: FontWeight.bold),)

                      ),
                  if(path != null)
                    if(path.hasVisitedSource && path.hasVisitedDestination )
                      Center(
                          child:
                          Text('You are few meters to the destination. Call The Reciever',
                            style: TextStyle(color: Colors.black54,fontSize: 14,fontWeight: FontWeight.bold),)

                      ),
                ],
              ),
            ),
            Expanded(flex: 0,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_downward,
                  color: Colors.black54,
                ), onPressed: () {
                slider.open();
              },
              ),),
          ],
        ),
      ),
    );
  }

  Widget _floatingPanel(CurrentPathLine path){
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20.0,
              color: Colors.grey,
            ),
          ]
      ),
      margin: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: Center(child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if(path != null)
                  if(!path.hasVisitedSource)
                   Column(
                     children: [
                       Center(
                           child:
                           Padding(
                             padding: EdgeInsets.symmetric(horizontal: 10),
                             child: Text('Head to the source to collect the package for delivery. If you have already collected the package click the button below to get '
                                 ' map route to the destination',
                               style: TextStyle(color: Colors.black54,fontSize: 18),textAlign: TextAlign.center,),
                           )

                       ),
                       Center(
                         child: FlatButton(
                           color: PRIMARYCOLOR,
                           child: Text('Destination route',style: TextStyle(color: Colors.white),),
                           onPressed: ()async{
                              slider.close();
                              //CurrentPathLine p = path;
                             //p = p.copyWith(hasVisitedSource: true);
                              await OrderRepo.setCurrentPathLine(path.copyWith(hasVisitedSource: true));
                           },
                         ),
                       ),
                     ],
                   ),

                if(path != null)
                  if(path.hasVisitedSource)
                Column(
                  children: [
                    Center(
                        child:
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('Take the package to the destination. Call the reciever once you get to the destination. If you have not collected the package click the button below to get '
                              ' map route to the source',
                            style: TextStyle(color: Colors.black54,fontSize: 18),textAlign: TextAlign.center,),
                        )

                    ),
                    Center(
                      child: FlatButton(
                        color: PRIMARYCOLOR,
                        child: Text('Source route',style: TextStyle(color: Colors.white),),
                        onPressed: ()async{
                          slider.close();
                          //CurrentPathLine p = path;
                          //p = p.copyWith(hasVisitedSource: true);
                          await OrderRepo.setCurrentPathLine(path.copyWith(hasVisitedSource: false,hasVisitedDestination: false));
                        },
                      ),
                    ),
                  ],
                ),
              ],
            )
            ),
          ),
          Expanded(
            flex: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(flex: 0,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black54,
                    ), onPressed: () {
                    Get.back();
                  },
                  ),),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if(path != null)
                        if(!path.hasVisitedSource)
                          Center(
                            child:
                            Text('Get package from Source',
                              style: TextStyle(color: Colors.black54,fontSize: 18,fontWeight: FontWeight.bold),),

                          ),

                      if(path != null)
                        if(path.hasVisitedSource)
                          Center(
                              child:
                              Text('Take package to Destination',
                                style: TextStyle(color: Colors.black54,fontSize: 18,fontWeight: FontWeight.bold),)

                          ),
                    ],
                  ),
                ),
                Expanded(flex: 0,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_upward,
                      color: Colors.black54,
                    ), onPressed: () {
                    slider.close();
                  },
                  ),),
              ],
            ),
          )
        ],
      ),
    );
  }
}
