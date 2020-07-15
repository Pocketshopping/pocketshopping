import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pocketshopping/src/errand/bloc/errandBloc.dart';
import 'package:pocketshopping/src/errand/repository/errandRepo.dart';
import 'package:pocketshopping/src/logistic/locationUpdate/agentLocUp.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:random_string/random_string.dart';

class MapWidget extends StatefulWidget {
  final LatLng latLng;
  final String customerName;
  final String telephone;
  final Function callBack;
  MapWidget({this.latLng,this.customerName,this.telephone,this.callBack});
  @override
  _MapWidgetState createState() => new _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {

  final _latLngNotifier = ValueNotifier<LatLng>(null);
  StreamSubscription<List<AgentLocUp>> agentStream;
  BitmapDescriptor carIcon;
  BitmapDescriptor bikeIcon;
  BitmapDescriptor vanIcon;
  double zoom;
  final _markers = ValueNotifier<Set<Marker> >(Set<Marker>());
  Completer<GoogleMapController> _controller = Completer();


  @override
  void initState() {
      zoom=17.0;

    Future.delayed(Duration(seconds: 2),(){
      if(mounted)
      _latLngNotifier.value = widget.latLng;
    });
    agentStream = ErrandRepo.getNearByErrandRider(Position(latitude: widget.latLng.latitude,longitude: widget.latLng.longitude)).listen((event) {
      //agents.value = event;
      //_markers.value.clear();
      event.forEach((element) {
        updatePinOnMap(element);
      });
     // _markers.value.addAll(temp);
      ErrandBloc.instance.newAgentLocList(event);
    });
    setIcons();
    super.initState();
  }

  void setIcons() async {
    carIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2),
        'assets/images/driving_pin.png');

    bikeIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2),
        'assets/images/biking_pin.png');

    vanIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2),
        'assets/images/van_pin.png');
  }

  @override
  void dispose() {
    _latLngNotifier?.dispose();
    agentStream?.cancel();
    _markers?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 245, 245, 1),
      body:  ValueListenableBuilder(
        valueListenable: _markers,
        builder: (_, Set<Marker> markers,__){
          return ValueListenableBuilder(
              valueListenable: _latLngNotifier,
              builder: (_, latLng,__){
                if(latLng != null){
                  return mounted?GoogleMap(
                    onMapCreated: (GoogleMapController controller){
                      controller.setMapStyle(Utility.mapStyles);
                      _controller.complete(controller);
                      //showPinsOnMap();
                    },
                    initialCameraPosition: CameraPosition(
                      target:  LatLng(latLng.latitude, latLng.longitude),
                      zoom: 17,
                    ),
                    zoomGesturesEnabled: true,
                    mapToolbarEnabled: true,
                    onTap: (latLng){
                      //print(latLng.toString());
                      widget.callBack(latLng);
                    },
                    myLocationEnabled: true,
                    buildingsEnabled: true,
                    markers: markers,
                    mapType: MapType.normal,
                  ):
                  Container();
                }
                else{
                  return Center(
                    child: JumpingDotsProgressIndicator(
                      fontSize: MediaQuery.of(context)
                          .size
                          .height *
                          0.15,
                      color: PRIMARYCOLOR,
                    ),
                  );
                }
              });
        },
      )

    );
  }

  void showPinsOnMap()async {



  }

  void updatePinOnMap(AgentLocUp agent) async {
    CameraPosition cPosition = CameraPosition(
      zoom: zoom,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(agent.agentLocation.latitude, agent.agentLocation.longitude),
    );
    if (mounted) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    }
    if (mounted) {
      setState(() {
        _markers.value.removeWhere((m) => m.markerId.value.contains('${agent.agent}'));
        _markers.value.add(Marker(
            markerId: MarkerId('${agent.agent}'),
            position: LatLng(agent.agentLocation.latitude,agent.agentLocation.longitude),
            icon: agent.agentAutomobile == 'MotorBike'?bikeIcon:agent.agentAutomobile == 'Car'?carIcon:vanIcon));
      });
    }
  }



}