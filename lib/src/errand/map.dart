import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';

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


  @override
  void initState() {

    Future.delayed(Duration(seconds: 2),(){
      if(mounted)
      _latLngNotifier.value = widget.latLng;
    });
    super.initState();
  }

  @override
  void dispose() {
    _latLngNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 245, 245, 1),
      body:  ValueListenableBuilder(
          valueListenable: _latLngNotifier,
          builder: (_, latLng,__){
            if(latLng != null){
              return mounted?GoogleMap(
                onMapCreated: (GoogleMapController controller){
                  //controller.setMapStyle(Utility.mapStyles);
                },
                initialCameraPosition: CameraPosition(
                  target:  LatLng(latLng.latitude, latLng.longitude),
                  zoom: 17,
                ),
                zoomGesturesEnabled: true,
                mapToolbarEnabled: true,
                onTap: (latLng){
                  print(latLng.toString());
                  widget.callBack(latLng);
                },
                myLocationEnabled: true,
                buildingsEnabled: true,
                //markers: markerList(latLng),
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
          }),

    );
  }

  Set<Marker> markerList(latLng){

    final marker = Marker(
        markerId: MarkerId('${widget.customerName}'),
        position: LatLng(latLng.latitude, latLng.longitude),
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: widget.customerName,
            snippet:'${widget.telephone}'
        )
    );

    return [marker].toSet();
  }

}