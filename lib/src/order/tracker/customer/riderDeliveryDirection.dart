import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:pocketshopping/src/logistic/agent/repository/agentObj.dart';
import 'package:pocketshopping/src/logistic/locationUpdate/agentLocUp.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/order/repository/currentPathLine.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;

class RiderDeliveryDirection extends StatefulWidget {
  RiderDeliveryDirection(
      {@required this.source,
        @required this.destination,
        this.destAddress,
        this.destName,
        this.destContact,
        this.sourceName,
        this.sourceContact,
        this.sourceAddress,
        this.autoType="MotorBike",
        this.agent,
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
  final Agent agent;

  @override
  State<StatefulWidget> createState() => _RiderDeliveryDirectionState();
}

class _RiderDeliveryDirectionState extends State<RiderDeliveryDirection> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
  BitmapDescriptor sourceIcon;
  BitmapDescriptor currentIcon;
  BitmapDescriptor destinationIcon;
  LocationData currentLocation;
  LocationData destinationLocation;

  Agent currentAgent;
  RouteMode routeMode;
  String distance;
  StreamSubscription<CurrentPathLine> pathLineStream;
  final pathLine = ValueNotifier<CurrentPathLine>(null);
  final slider = new PanelController();
  Stream<LocationData> lStream;



  @override
  void initState() {
    Future.delayed(Duration(seconds: 1),(){
      currentAgent = widget.agent;
      distance = '';



      setSourceAndDestinationIcons();
      setInitialLocation();



      LogisticRepo.getOneAgentLocationStream(currentAgent.agentID).listen((AgentLocUp cLoc) {
        currentLocation = LocationData.fromMap({'latitude':cLoc.agentLocation.latitude,'longitude':cLoc.agentLocation.longitude,'speed':0});
        updatePinOnMap();
        if (mounted) setState(() {});
      });


      pathLineStream = OrderRepo.currentPathLineStream(currentAgent.agent).listen((event) {
        if(event != null) {
          pathLine.value = event;
          //ErrandDirectionBloc.instance.newPath(event);
        }

      });
    });


    super.initState();
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
    //currentLocation = await location.getLocation();
    destinationLocation = LocationData.fromMap({
      "latitude": widget.destination.latitude,
      "longitude": widget.destination.longitude
    });
  }

  @override
  void dispose() {
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
            title: 'Rider',
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
                title: 'Rider',
                snippet: 'rider'

            ),
            markerId: MarkerId('currentPin'),
            position: pinPosition, // updated position
            icon: currentIcon));
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
                        Text('Rider is getting package from ${widget.sourceName}',
                          style: TextStyle(color: Colors.black54,fontSize: 18,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),

                      ),

                  if(path != null)
                    if(path.hasVisitedSource && !path.hasVisitedDestination )
                      Center(
                          child:
                          Text('Rider is bringing package to you.',
                            style: TextStyle(color: Colors.black54,fontSize: 18,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)

                      ),
                  if(path != null)
                    if(path.hasVisitedSource && path.hasVisitedDestination )
                      Center(
                          child:
                          Text('Rider is few meters to the destination.',
                            style: TextStyle(color: Colors.black54,fontSize: 14,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)

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
                              child: Text('Rider is currently going to get the package from ${widget.sourceName}, please stay put.',
                                style: TextStyle(color: Colors.black54,fontSize: 18),textAlign: TextAlign.center,),
                            )

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
                              child: Text('Rider is bringing package to you. Please stay put.',
                                style: TextStyle(color: Colors.black54,fontSize: 18),textAlign: TextAlign.center,),
                            )

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
                            Text('Rider is getting items from ${widget.sourceName}',
                              style: TextStyle(color: Colors.black54,fontSize: 18,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),

                          ),

                      if(path != null)
                        if(path.hasVisitedSource)
                          Center(
                              child:
                              Text('Rider is bringing package to you.',
                                style: TextStyle(color: Colors.black54,fontSize: 18,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)

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
