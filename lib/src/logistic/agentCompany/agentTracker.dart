import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pocketshopping/src/logistic/locationUpdate/agentLocUp.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';

class AgentTracker extends StatefulWidget {
  final AgentLocUp agent;
  AgentTracker({this.agent});
  @override
  _AgentTrackerState createState() => new _AgentTrackerState();
}

class _AgentTrackerState extends State<AgentTracker> {

  final _latLngNotifier = ValueNotifier<LatLng>(null);


  @override
  void initState() {

    Future.delayed(Duration(seconds: 2),(){
      _latLngNotifier.value = LatLng( widget.agent.agentLocation.latitude, widget.agent.agentLocation.longitude);
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
        appBar:PreferredSize(
          preferredSize: Size.fromHeight(
              MediaQuery.of(context).size.height *
                  0.15),
          child: AppBar(
              title: Text('${widget.agent.agentName}',style: TextStyle(color: PRIMARYCOLOR),),
            backgroundColor: Color.fromRGBO(245, 245, 245, 1),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.grey,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              elevation: 0.0,
            bottom: PreferredSize(
                preferredSize: Size.fromHeight(
                    MediaQuery.of(context).size.height *
                        0.5),
                child:Column(
                  children: [

                    ValueListenableBuilder(
                        valueListenable: _latLngNotifier,
                        builder: (_, latLng,__){
                          if(latLng != null){
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                              child: Text(
                                '${widget.agent.address} (last updated: ${Utility.presentDate(DateTime.parse(widget.agent.agentUpdateAt.toDate().toString()))})',
                                style: TextStyle(color: Colors.black54),
                              ),
                            );
                          }
                          else{
                            return const SizedBox.shrink();
                          }
                        }),

                  ],
                )

          )
          ),
        ),
        backgroundColor: Color.fromRGBO(245, 245, 245, 1),
        body:  ValueListenableBuilder(
                    valueListenable: _latLngNotifier,
                    builder: (_, latLng,__){
                      if(latLng != null){
                        return mounted?GoogleMap(
                          onMapCreated: (GoogleMapController controller){
                            controller.setMapStyle(Utility.mapStyles);
                          },
                          initialCameraPosition: CameraPosition(
                            target:  LatLng(latLng.latitude, latLng.longitude),
                            zoom: 12,
                          ),
                          markers: markerList(latLng),
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
        markerId: MarkerId('${widget.agent.agentName}'),
        position: LatLng(latLng.latitude, latLng.longitude),
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: widget.agent.agentName,
        snippet:'${widget.agent.address} (last updated: ${Utility.presentDate(DateTime.parse(widget.agent.agentUpdateAt.toDate().toString()))})'
        )
      );

    return [marker].toSet();
  }

}