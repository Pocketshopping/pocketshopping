import 'dart:async';
import 'dart:typed_data';

import 'package:ant_icons/ant_icons.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:pocketshopping/src/errand/direction.dart';
import 'package:pocketshopping/src/errand/map.dart';
import 'package:pocketshopping/src/errand/repository/errandRepo.dart';
import 'package:pocketshopping/src/geofence/package_geofence.dart';
import 'package:pocketshopping/src/geofence/reviewPlace.dart';
import 'package:pocketshopping/src/logistic/locationUpdate/agentLocUp.dart';
import 'package:pocketshopping/src/order/customerMapTracker.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:location/location.dart' as loc;

class SelectAuto extends StatefulWidget {
  final Session user;
  final Position position;
  final LatLng source;
  final LatLng destination;
  final int distance;
  SelectAuto({this.user,this.position,this.source,this.destination,this.distance});

  @override
  State<StatefulWidget> createState() => _SelectAutoState();
}

class _SelectAutoState extends State<SelectAuto> {

  Session currentUser;
  Position position;
  final load = ValueNotifier<bool>(false);
  final fee = ValueNotifier<List<int>>([0,0,0]);

  final destinationPosition = ValueNotifier<LatLng>(null);
  double zoom;

  loc.Location location;
  StreamSubscription<loc.LocationData> locStream;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {

    currentUser = widget.user;
    position = widget.position;
    Future.delayed(Duration(seconds: 1),(){load.value=true;});
    WalletRepo.getWallet(currentUser.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
    zoom = Utility.zoomer(widget.distance);


    Utility.locationAccess();

    CloudFunctions.instance
        .getHttpsCallable(
      functionName: "ErrandDeliveryCut",
    ).call({'distance': (widget.distance*1000)}).then((value) {fee.value = List.castFrom(value.data);});
    super.initState();

  }



  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
        onWillPop: () async {

            return true;

        },
        child:
        Scaffold(
            body: StreamBuilder<List<AgentLocUp>>(
              stream: ErrandRepo.getNearByErrandRider(Position(latitude: widget.source.latitude,longitude: widget.source.longitude)),
              initialData: [],
              builder: (context, AsyncSnapshot <List<AgentLocUp>> snapshot){

                return ValueListenableBuilder(
                    valueListenable: fee,
                    builder: (i,List<int> amount,ii){

                      return ValueListenableBuilder(
                  valueListenable: load,
                  builder: (_,bool loading,__){
                    return Column(
                      children: [
                        Expanded(
                            flex: 5,
                            child: loading?Container(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: ErrandDirection(
                                  source: widget.source,
                                  destination: widget.destination,
                                  zoom: zoom,
                                )
                            ):
                            Center(
                              child: JumpingDotsProgressIndicator(
                                fontSize: MediaQuery.of(context).size.height * 0.12,
                                color: PRIMARYCOLOR,
                              ),
                            )
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              //border: Border(top: BorderSide(width: 0.5, color: Colors.black54)),
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20.0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: Offset(0.0, 1.0), //(x,y)
                                  blurRadius: 6.0,
                                ),
                              ],
                            ),

                            child: snapshot.connectionState != ConnectionState.waiting?
                                !snapshot.hasError?
                                    snapshot.data.isNotEmpty?
                            Column(
                              children: [
                                Expanded(
                                    flex: 0,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            GestureDetector(
                                              child: IconButton(

                                                icon: Icon(Icons.arrow_back_ios,color: Colors.black54,),
                                                onPressed: (){

                                                  Get.back();

                                                },
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 5),
                                                  child: Text('Select Rider.',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.black45),)
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                ),
                                Expanded(
                                    flex: 1,
                                    child: ListView(
                                      children: [


                                        snapshot.data.any((element) => element.agentAutomobile == 'MotorBike')?
                                        Padding(
                                          padding: EdgeInsets.symmetric(vertical: 5),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              child: Image.asset('assets/images/mbike.png'),
                                              backgroundColor: Colors.white,
                                            ),

                                            title: Text('MotorBike',style: TextStyle(fontSize: 18),),
                                            subtitle: Text('Select this if you want a motorBike.'),
                                            trailing: Text('$CURRENCY${amount[0]}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                                          ),
                                        ):const SizedBox.shrink(),

                                       snapshot.data.any((element) => element.agentAutomobile == 'Car')?
                                        Padding(
                                          padding: EdgeInsets.symmetric(vertical: 5),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              child: Image.asset('assets/images/ecar.png'),
                                              backgroundColor: Colors.white,
                                            ),
                                            title: Text('Car',style: TextStyle(fontSize: 18),),
                                            subtitle: Text('Select this if you want a Car.'),
                                            trailing: Text('$CURRENCY${amount[1]}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                                          ),
                                        )
                                            :const SizedBox.shrink(),

                                       snapshot.data.any((element) => element.agentAutomobile == 'Van')?
                                        Padding(
                                          padding: EdgeInsets.symmetric(vertical: 5),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              child: Image.asset('assets/images/evan.png'),
                                              backgroundColor: Colors.white,
                                            ),
                                            title: Text('Van/Truck',style: TextStyle(fontSize: 18),),
                                            subtitle: Text('Select this if you want a Van/Truck.'),
                                            trailing: Text('$CURRENCY${amount[2]}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                                          ),
                                        )
                                            :const SizedBox.shrink(),

                                      ],
                                    )
                                ),
                              ],
                            ):Center(
                                        child: Text('No Rider within region.')
                                    )

                                        :
                                Center(
                                  child: Text('Error Fetching Rider. Check connection and try again.')
                                )

                                    :
                            Center(
                              child: JumpingDotsProgressIndicator(
                                fontSize: MediaQuery.of(context).size.height * 0.12,
                                color: PRIMARYCOLOR,
                              ),
                            )
                          ),
                        )
                      ],
                    );
                  },
                );
              }
              );
              },
            )
        )

    );


  }
}