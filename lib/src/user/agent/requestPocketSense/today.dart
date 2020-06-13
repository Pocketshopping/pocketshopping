import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geoLoc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:pocketshopping/src/statistic/repository.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';

class TodayMisses extends StatefulWidget {
  final Session user;
  TodayMisses({this.user});
  @override
  _TodayMissesState createState() => new _TodayMissesState();
}

class _TodayMissesState extends State<TodayMisses> {

  final _latLngNotifier = ValueNotifier<List<LatLng>>(null);
  final _currentLocationNotifier = ValueNotifier<LocationData>(null);
  StreamSubscription<LocationData> locStream;
  Location location;


  @override
  void initState() {
    location = new Location();
    location.changeSettings(accuracy: LocationAccuracy.navigation, distanceFilter: 10);
    location.getLocation().then((cLcc) => _currentLocationNotifier.value =cLcc);
    locStream = location.onLocationChanged.listen((LocationData cLoc) {
      _currentLocationNotifier.value= cLoc;
    });



    super.initState();
  }

  @override
  void dispose() {
    locStream.cancel();
    _latLngNotifier.dispose();
    _currentLocationNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
        backgroundColor: Color.fromRGBO(245, 245, 245, 1),
        body: ValueListenableBuilder(
        valueListenable: _currentLocationNotifier,
        builder: (_, LocationData currentLoc,__){
          if(currentLoc != null)
            {
              StatisticRepo.getMissedDeliveryRequest(geoLoc.Position(latitude: currentLoc.latitude,longitude:currentLoc.longitude ),"T").then((value) { if(mounted)_latLngNotifier.value=value;});
              return ValueListenableBuilder(
                  valueListenable: _latLngNotifier,
                  builder: (_, List<LatLng> latLng,__){
                    if(latLng != null){
                      return mounted?GoogleMap(
                        onMapCreated: (GoogleMapController controller){
                          controller.setMapStyle(Utility.mapStyles);
                        },
                        initialCameraPosition: CameraPosition(
                          target:  latLng.isNotEmpty?latLng[0]:LatLng(currentLoc.latitude, currentLoc.longitude),
                          zoom: 10.5,
                        ),
                        markers: markerList(latLng),
                      ):
                      Container();
                    }
                    else{
                      print('empty');
                      return Center(
                        child: JumpingDotsProgressIndicator(
                          fontSize: MediaQuery.of(context)
                              .size
                              .height *
                              0.12,
                          color: PRIMARYCOLOR,
                        ),
                      );
                    }
                  });
            }
          else{
            return Center(
              child: JumpingDotsProgressIndicator(
                fontSize: MediaQuery.of(context)
                    .size
                    .height *
                    0.12,
                color: PRIMARYCOLOR,
              ),
            );
          }
        }
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: ValueListenableBuilder(

          valueListenable: _latLngNotifier,
          builder: (_,latLng,__){
            if(latLng != null){
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FloatingActionButton.extended(
                      onPressed: () {},
                      label: Text(
                        'Today Miss: ${_latLngNotifier.value.toSet().length}',
                        style: TextStyle(color: Colors.black54),
                      ),
                      icon:  IconButton(
                        onPressed: (){},
                        icon: Icon(
                          Icons.remove_shopping_cart,
                          color: Colors.black54,
                        ),
                      ),
                      backgroundColor: Colors.grey,
                    ),
                  ],
                ),
              );
            }
            else{
              return const SizedBox.shrink();
            }
          },
        )
    );
  }

  Set<Marker> markerList(latLng){
    List<Marker> _markers = [];
    for(int i=0; i<latLng.length;i++){
      final marker = Marker(
          markerId: MarkerId('MISS$i'),
          position: LatLng(latLng[i].latitude, latLng[i].longitude),
          icon: BitmapDescriptor.defaultMarker,

      );
      _markers.add(marker);

    }
    return _markers.toSet();
  }

}