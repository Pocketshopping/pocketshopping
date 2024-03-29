import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:pocketshopping/src/errand/bloc/errandBloc.dart';
import 'package:pocketshopping/src/errand/direction.dart';
import 'package:pocketshopping/src/errand/preview.dart';
import 'package:pocketshopping/src/errand/repository/errandRepo.dart';
import 'package:pocketshopping/src/logistic/locationUpdate/agentLocUp.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:progress_indicators/progress_indicators.dart';

class SelectAuto extends StatefulWidget {
  final Session user;
  final Position position;
  final LatLng source;
  final LatLng destination;
  final int distance;
  final sourceAddress;
  final destinationAddress;
  final String logistic;
  final int bCount;
  final int cCount;
  final int vCount;
  final String logName;
  final bool canCheck;
  SelectAuto({this.user,
    this.position,
    this.source,
    this.destination,
    this.distance,
    this.sourceAddress,
    this.destinationAddress,
    this.logistic="",
    this.bCount =0,
    this.vCount = 0,
    this.cCount =0,
    this.logName,
    this.canCheck = false,
  });

  @override
  State<StatefulWidget> createState() => _SelectAutoState();
}

class _SelectAutoState extends State<SelectAuto> {
  Session currentUser;
  Position position;
  final load = ValueNotifier<bool>(false);
  final fee = ValueNotifier<List<int>>([0,0,0]);
  final agents = ValueNotifier<List<AgentLocUp>>([]);
  final destinationPosition = ValueNotifier<LatLng>(null);
  double zoom;
  loc.Location location;
  StreamSubscription<loc.LocationData> locStream;
  StreamSubscription<List<AgentLocUp>> agentStream;

  @override
  void dispose() {
    locStream?.cancel();
    agentStream?.cancel();
    fee?.dispose();
    load?.dispose();
    agents?.dispose();
    destinationPosition?.dispose();
    super.dispose();
  }

  @override
  void initState() {

    currentUser = widget.user;
    position = widget.position;
    Future.delayed(Duration(seconds: 1),(){load.value=true;});
    WalletRepo.getWallet(currentUser.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
    zoom = Utility.zoomer(widget.distance);
    CloudFunctions.instance.getHttpsCallable(functionName: "ErrandDeliveryCut",).call({'distance': (widget.distance*1000)}).then((value) {
      if(mounted)
      fee.value = List.castFrom(value.data);
    });
    agentStream = ErrandRepo.getNearByErrandRider(Position(latitude: widget.source.latitude,longitude: widget.source.longitude)).listen((event) {
      agents.value = event;
      ErrandBloc.instance.newAgentLocList(event);
    });
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
        onWillPop: () async {return true;},
        child: Scaffold(
            body: ValueListenableBuilder<List<AgentLocUp>>(
              valueListenable: agents,
              builder: (c, List<AgentLocUp> snapshot,cc){
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
                                fontSize: Get.height * 0.12,
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

                            child:snapshot.isNotEmpty || (widget.logistic.isNotEmpty && (widget.bCount>0 || widget.cCount>0 || widget.vCount>0))?
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
                                                  child: Text('Select Automobile.',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.black45),)
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


                                        snapshot.any((element) => element.agentAutomobile == 'MotorBike') || (widget.logistic.isNotEmpty && widget.bCount>0)?
                                        Padding(
                                          padding: EdgeInsets.symmetric(vertical: 5),
                                          child: ListTile(
                                            onTap: (){
                                              if(amount[0] != 0)
                                              {
                                                Get.off(Preview(
                                                  user: currentUser,
                                                  source: widget.source,
                                                  destination: widget.destination,
                                                  distance: widget.distance,
                                                  fee: amount[0],
                                                  position: position,
                                                  type: 0,
                                                  auto: 'MotorBike',
                                                  sourceAddress: widget.sourceAddress,
                                                  destinationAddress: widget.destinationAddress,
                                                  logistic:widget.logistic,
                                                  canCheck: widget.canCheck,
                                                  logisticName: widget.logName,
                                                  agents: (snapshot.where((element) => element.agentAutomobile == 'MotorBike')).toList(growable: false)??[],

                                                ));
                                              }
                                            },
                                            leading: CircleAvatar(
                                              child: Image.asset('assets/images/mbike.png'),
                                              backgroundColor: Colors.white,
                                            ),

                                            title: Text('MotorBike',style: TextStyle(fontSize: 18),),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text('Select this if you want a motorBike.'),
                                                snapshot.isEmpty?
                                                Text('${widget.logName}')
                                                :
                                                const SizedBox.shrink()
                                              ],
                                            ),
                                            trailing: amount[0] != 0?
                                            Text('$CURRENCY${amount[0]}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),):
                                            CircularProgressIndicator()
                                            ,
                                          ),
                                        ):const SizedBox.shrink(),

                                       snapshot.any((element) => element.agentAutomobile == 'Car') || (widget.logistic.isNotEmpty && widget.cCount>0) ?
                                        Padding(
                                          padding: EdgeInsets.symmetric(vertical: 5),
                                          child: ListTile(
                                            onTap: (){
                                              if(amount[1] != 0)
                                                Get.off(Preview(
                                                  user: currentUser,
                                                  source: widget.source,
                                                  destination: widget.destination,
                                                  distance: widget.distance,
                                                  fee: amount[1],
                                                  position: position,
                                                  type: 1,
                                                  auto: 'Car',
                                                  sourceAddress: widget.sourceAddress,
                                                  destinationAddress: widget.destinationAddress,
                                                  logistic:widget.logistic,
                                                  canCheck: widget.canCheck,
                                                  logisticName: widget.logName,
                                                  agents: (snapshot.where((element) => element.agentAutomobile == 'Car')).toList(growable: false)??[],
                                                ));
                                            },
                                            leading: CircleAvatar(
                                              child: Image.asset('assets/images/ecar.png'),
                                              backgroundColor: Colors.white,
                                            ),
                                            title: Text('Car',style: TextStyle(fontSize: 18),),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text('Select this if you want a Car.'),
                                                snapshot.isEmpty?
                                                Text('${widget.logName}')
                                                    :
                                                const SizedBox.shrink()
                                              ],
                                            ),
                                              trailing: amount[1] != 0?
                                              Text('$CURRENCY${amount[1]}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),):
                                              CircularProgressIndicator()
                                          ),
                                        )
                                            :const SizedBox.shrink(),

                                       snapshot.any((element) => element.agentAutomobile == 'Van') || (widget.logistic.isNotEmpty && widget.vCount>0)?
                                        Padding(
                                          padding: EdgeInsets.symmetric(vertical: 5),
                                          child: ListTile(
                                            onTap: (){
                                              if(amount[2] != 0)
                                                Get.off(Preview(
                                                  user: currentUser,
                                                  source: widget.source,
                                                  destination: widget.destination,
                                                  distance: widget.distance,
                                                  fee: amount[2],
                                                  position: position,
                                                  type: 2,
                                                  auto: 'Van',
                                                  sourceAddress: widget.sourceAddress,
                                                  destinationAddress: widget.destinationAddress,
                                                  logistic:widget.logistic,
                                                  canCheck: widget.canCheck,
                                                  logisticName: widget.logName,
                                                  agents: (snapshot.where((element) => element.agentAutomobile == 'Van')).toList(growable: false)??[],
                                                ));
                                            },
                                            leading: CircleAvatar(
                                              child: Image.asset('assets/images/evan.png'),
                                              backgroundColor: Colors.white,
                                            ),
                                            title: Text('Van/Truck',style: TextStyle(fontSize: 18),),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text('Select this if you want a Van/Truck.'),
                                                snapshot.isEmpty?
                                                Text('${widget.logName}')
                                                    :
                                                const SizedBox.shrink()
                                              ],
                                            ),
                                              trailing: amount[2] != 0?
                                              Text('$CURRENCY${amount[2]}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),):
                                              CircularProgressIndicator()
                                          ),
                                        )
                                            :const SizedBox.shrink(),

                                      ],
                                    )
                                ),
                              ],
                            ):(widget.logistic.isNotEmpty && widget.bCount==0 && widget.cCount==0 && widget.vCount==0)?
                            Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(' ${widget.logName} Is currently not operational'),
                                    FlatButton(
                                        onPressed: (){Get.back();},
                                        color: PRIMARYCOLOR,
                                        child: Text('Go Back',style: TextStyle(color: Colors.white),))
                                  ],
                                )
                            ):
                            Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('No available Rider within region.'),
                                            FlatButton(
                                                onPressed: (){Get.back();},
                                                color: PRIMARYCOLOR,
                                                child: Text('Go Back',style: TextStyle(color: Colors.white),))
                                          ],
                                        )
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