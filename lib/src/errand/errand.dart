import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:location/location.dart' as loc;
import 'package:pocketshopping/src/errand/map.dart';
import 'package:pocketshopping/src/errand/selectAuto.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';


class Errand extends StatefulWidget {
  final Session user;
  final Position position;
  Errand({this.user,this.position});

  @override
  State<StatefulWidget> createState() => _ErrandState();
}

class _ErrandState extends State<Errand> {

  Session currentUser;
  Position position;
  final selected = ValueNotifier<int>(0);
  final isTyping = ValueNotifier<bool>(false);
  final isTypingDestination = ValueNotifier<bool>(false);
  final isTypingSource = ValueNotifier<bool>(false);
  final showButton = ValueNotifier<bool>(false);
  final addressType = ValueNotifier<int>(0);

  final sourcePosition = ValueNotifier<LatLng>(null);
  final destinationPosition = ValueNotifier<LatLng>(null);
  final source = TextEditingController();
  final destination = TextEditingController();
  var googlePlace;
  final autocomplete = ValueNotifier<List<AutocompletePrediction>>([]);
  var result;// = await googlePlace.autocomplete.get("1600 Amphitheatre");
  final handleOnTap = ValueNotifier<String>('');
  final slider = new PanelController();
  loc.Location location;
  StreamSubscription<loc.LocationData> geoStream;

  @override
  void initState() {
    location = new loc.Location();
    googlePlace = GooglePlace(googleAPIKey);
    currentUser = widget.user;

    position = widget.position;

    if(position != null){
      Utility.address(position).then((value) => source.text=value);
      sourcePosition.value = LatLng(position.latitude,position.longitude);
    }

    location.changeSettings(accuracy: loc.LocationAccuracy.high, distanceFilter: 10);
    geoStream = location.onLocationChanged.listen((loc.LocationData cLoc) {
      position = Position(latitude: cLoc.latitude,longitude: cLoc.longitude);
      if (mounted) setState(() {});
      Utility.address(position).then((value) => source.text=value);
      sourcePosition.value = LatLng(position.latitude,position.longitude);
    });

    /*googlePlace.autocomplete.get('a',
      location: LatLon(position.latitude,position.longitude),
      radius: 50000,
      strictbounds:true,
    ).then((  value){
      try{
        if(selected.value == 2)
          addressType.value=2;
        else if (selected.value == 1)
          addressType.value=1;
        autocomplete.value = value.predictions;
      }
      catch(_){}
    });*/


    WalletRepo.getWallet(currentUser.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
    Utility.locationAccess();
    super.initState();

  }

  @override
  void dispose() {
    geoStream?.cancel();
    /*selected?.dispose();
    isTyping?.dispose();
    isTypingDestination?.dispose();
    isTypingSource?.dispose();
    showButton?.dispose();
    addressType?.dispose();
    sourcePosition?.dispose();
    destinationPosition?.dispose();
    source?.dispose();
    destination?.dispose();
    autocomplete?.dispose();
    handleOnTap?.dispose();*/
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
        onWillPop: () async {
      if (isTyping.value){
        isTyping.value=false;
        return false;
      }

      else {
        return true;
      }
    },
    child:
    Scaffold(
                  body: position != null ? ValueListenableBuilder(
                    valueListenable: isTyping,
                    builder: (_,bool typing,__){
                      return  Column(
                        children: [

                          if(!typing)
                          Expanded(
                              flex: 5,
                              child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  child: MapWidget(
                                    latLng: LatLng(position.latitude,position.longitude),
                                    customerName: '',
                                    telephone: '',
                                    callBack: (LatLng latLng)async{
                                      isTyping.value = false;
                                      handleOnTap.value='';
                                      if(latLng != null){
                                      Get.defaultDialog(title: 'Address',
                                        content: ValueListenableBuilder(
                                          valueListenable: handleOnTap,
                                          builder: (i,String tap,ii){
                                            return tap.isNotEmpty?Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 0,
                                                      child: Icon(Icons.place,color: Colors.grey,),
                                                    ),
                                                    Expanded(
                                                      child: Text('$tap',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(height: 20,),
                                                Text('Use Address As'),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: FlatButton(
                                                        onPressed: (){
                                                          Get.back();

                                                          sourcePosition.value = latLng;
                                                          isTyping.value=true;
                                                          selected.value =1;
                                                          source.text = tap;
                                                          showButton.value = source.text.isNotEmpty&&destination.text.isNotEmpty;
                                                        },
                                                        child: Text('Source',style: TextStyle(color: Colors.white),),
                                                        color: PRIMARYCOLOR,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: FlatButton(
                                                        onPressed: (){
                                                          Get.back();

                                                          destinationPosition.value=latLng;
                                                          isTyping.value=true;
                                                          selected.value =2;
                                                          destination.text = tap;
                                                          showButton.value= source.text.isNotEmpty&&destination.text.isNotEmpty;
                                                        },
                                                        child: Text('Destination',style: TextStyle(color: Colors.white),),
                                                        color: PRIMARYCOLOR,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ):Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children:[ CircularProgressIndicator()],
                                            );
                                          },
                                        ),
                                      );

                                      handleOnTap.value = await Utility.address(Position(latitude: latLng.latitude,longitude: latLng.longitude ));
                                      }


                                      //destination.text
                                    },
                                  )
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

                              child: Column(
                                children: [
                                  if(typing)
                                  Expanded(
                                      flex: 0,
                                  child: const SizedBox(height: 30,),
                                  ),
                                  Expanded(
                                      flex: 0,
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              GestureDetector(
                                                child: IconButton(

                                                  icon: Icon(Icons.arrow_back_ios),
                                                  onPressed: (){
                                                    if (typing){
                                                      isTyping.value=false;
                                                      //destination.clear();
                                                    }
                                                    else {
                                                      Get.back();
                                                    }
                                                  },
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                    padding: EdgeInsets.symmetric(vertical: 5),
                                                    child: Text('Request For a Rider.',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),)
                                                ),
                                              ),
                                            ],
                                          ),
                                          if(typing)
                                          Center(
                                              child: Row(
                                                children: [
                                                  Expanded(

                                                    child: Padding(
                                                        padding: EdgeInsets.only(left: 10,top: 5,right: 10),
                                                        child:  TextFormField(
                                                          controller: source,
                                                          decoration: InputDecoration(
                                                            prefixIcon: Icon(Icons.search),
                                                            suffix: GestureDetector(
                                                              onTap: ()async{
                                                                source.text = await Utility.address(position);
                                                                sourcePosition.value = LatLng(position.latitude,position.longitude);
                                                                showButton.value= source.text.isNotEmpty&&destination.text.isNotEmpty;
                                                              },
                                                              child: Icon(Icons.place,color: Colors.black54,size: 20,),
                                                            ),
                                                            prefix: GestureDetector(
                                                              onTap: ()async{
                                                                source.clear();
                                                              },
                                                              child: Padding(
                                                                padding: EdgeInsets.symmetric(horizontal: 5),
                                                                child: Icon(Icons.clear,color: Colors.black54,size: 20,),
                                                              ),
                                                            ),
                                                            labelText: 'Source Address',
                                                            filled: true,
                                                            fillColor: Colors.grey.withOpacity(0.2),
                                                            focusedBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                                            ),
                                                            enabledBorder: UnderlineInputBorder(
                                                              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                                            ),
                                                          ),
                                                          autofocus: false,
                                                          enableSuggestions: true,
                                                          textInputAction: TextInputAction.done,
                                                          onChanged: (value) async{
                                                            if(value.isEmpty){
                                                              showButton.value=false;
                                                              AutocompleteResponse result = await googlePlace.autocomplete.get('a',
                                                                location: LatLon(position.latitude,position.longitude),
                                                                radius: 50000,
                                                                strictbounds:true,
                                                              );
                                                              if(result != null)
                                                              autocomplete.value = result.predictions;
                                                            }
                                                            else{
                                                              AutocompleteResponse result = await googlePlace.autocomplete.get('$value',
                                                                location: LatLon(position.latitude,position.longitude),
                                                                radius: 50000,
                                                                strictbounds:true,
                                                              );
                                                              if(result != null)
                                                              autocomplete.value = result.predictions;
                                                            }
                                                            addressType.value=1;
                                                            },
                                                          onTap: (){
                                                            isTyping.value=true;
                                                            selected.value =1;
                                                          },
                                                        )
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: ValueListenableBuilder(
                                                      valueListenable: isTypingSource,
                                                      builder: (_,bool itd,__){
                                                        return itd?Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                                          child: CircularProgressIndicator(),
                                                        ):const SizedBox.shrink();
                                                      },
                                                    ),
                                                  )
                                                ],
                                              )
                                          ),
                                          Center(
                                              child: Row(
                                                children: [
                                                  Expanded(

                                                    child: Padding(
                                                        padding: EdgeInsets.only(left: 10,top: 5,right: 10),
                                                        child:  TextFormField(
                                                          controller: destination,
                                                          decoration: InputDecoration(
                                                            suffix: GestureDetector(
                                                              onTap: ()async{
                                                                destination.text = await Utility.address(position);
                                                                destinationPosition.value=LatLng(position.latitude,position.longitude);
                                                                showButton.value= source.text.isNotEmpty&&destination.text.isNotEmpty;
                                                              },
                                                              child: Icon(Icons.place,color: Colors.black54,size: 20,),
                                                            ),
                                                            prefix: GestureDetector(
                                                              onTap: ()async{
                                                                destination.clear();
                                                              },
                                                              child: Padding(
                                                                padding: EdgeInsets.symmetric(horizontal: 5),
                                                                child: Icon(Icons.clear,color: Colors.black54,size: 20,),
                                                              ),
                                                            ),
                                                            prefixIcon: Icon(Icons.search),
                                                            labelText: 'Search Destination',
                                                            filled: true,
                                                            fillColor: Colors.grey.withOpacity(0.2),
                                                            focusedBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                                            ),
                                                            enabledBorder: UnderlineInputBorder(
                                                              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                                            ),
                                                          ),
                                                          autofocus: typing,
                                                          enableSuggestions: true,
                                                          textInputAction: TextInputAction.done,
                                                          onChanged: (value) async{
                                                            if(value.isEmpty){
                                                              showButton.value=false;
                                                              AutocompleteResponse result = await googlePlace.autocomplete.get('a',
                                                                location: LatLon(position.latitude,position.longitude),
                                                                radius: 50000,
                                                                strictbounds:true,
                                                              );
                                                              if(result != null)
                                                              autocomplete.value = result.predictions;
                                                            }
                                                            else{
                                                              AutocompleteResponse result = await googlePlace.autocomplete.get('$value',
                                                                location: LatLon(position.latitude,position.longitude),
                                                                radius: 50000,
                                                                strictbounds:true,
                                                              );
                                                              if(result != null)
                                                              autocomplete.value = result.predictions;
                                                            }
                                                            addressType.value=2;
                                                            },
                                                          onTap: (){
                                                            isTyping.value=true;
                                                            selected.value =2;

                                                          },
                                                        )
                                                    ),
                                                        ),
                                                        Expanded(
                                                          flex: 0,
                                                          child: ValueListenableBuilder(
                                                            valueListenable: isTypingDestination,
                                                            builder: (_,bool itd,__){
                                                              return itd?Padding(
                                                                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                                                child: CircularProgressIndicator(),
                                                              ):const SizedBox.shrink();
                                                            },
                                                          ),
                                                        )


                                                ],
                                              )
                                          ),
                                        ],
                                      )
                                  ),
                                  if(typing)
                                  Expanded(
                                    flex: 0,
                                    child: ValueListenableBuilder(
                                      valueListenable: showButton,
                                      builder: (_,bool show,__){
                                        return show?Container(
                                          color: PRIMARYCOLOR,
                                          margin: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                          child: Center(
                                            child: FlatButton(
                                              onPressed: ()async{


                                                  if(sourcePosition.value != null && destinationPosition.value != null){
                                                    double distance =  await Geolocator().distanceBetween(sourcePosition.value.latitude, sourcePosition.value.longitude,
                                                        destinationPosition.value.latitude, destinationPosition.value.longitude);
                                                    if(distance > 0){
                                                      Get.to(SelectAuto(
                                                        user: currentUser,
                                                        position: position,
                                                        source: sourcePosition.value,
                                                        destination: destinationPosition.value,
                                                        distance: (distance/1000).round(),
                                                        sourceAddress: source.text,
                                                        destinationAddress: destination.text,
                                                      )).then((value) {
                                                        destination.clear();
                                                        isTyping.value=false;
                                                      });
                                                    }
                                                    else{
                                                      Utility.infoDialogMaker("Source and Destination cannot be thesame.",title: 'Information');
                                                    }
                                                  }
                                                  else{
                                                    //print('source${sourcePosition.value}');
                                                    //print('destination${destinationPosition.value}' );
                                                    Utility.infoDialogMaker("Error parsing address ensure you select a valid address and also check your internet connectivity",title: 'Information');
                                                  }
                                              },
                                              child: Text('Request',style: TextStyle(color: Colors.white),),
                                            ),
                                          ),
                                        ):const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                  if(typing)
                                    Expanded(

                                      child: ValueListenableBuilder(
                                        valueListenable: autocomplete,
                                        builder: (i,predictions,__){
                                          return Container(
                                             child: ListView.builder(
                                                 itemBuilder: (context,index){
                                                   return ListTile(
                                                     leading: CircleAvatar(
                                                       child: Icon(
                                                         Icons.place,
                                                         color: Colors.grey.withOpacity(0.5),
                                                       ),
                                                       backgroundColor: Colors.white,
                                                     ),
                                                     title: Text((predictions[index].description as String).contains('Nigeria')?(predictions[index].description as String).replaceFirst(', Nigeria', ''):(predictions[index].description as String)),
                                                     onTap: () async{
                                                       FocusScope.of(context).requestFocus(FocusNode());
                                                       if(addressType.value == 2){
                                                         isTypingDestination.value=true;
                                                         DetailsResponse result = await googlePlace.details.get("${predictions[index].placeId}",);
                                                         //print(result.result.geometry.location.lng);
                                                         destination.text = ((predictions[index].description as String).contains('Nigeria')?(predictions[index].description as String).replaceFirst(', Nigeria', ''):(predictions[index].description as String));
                                                         destinationPosition.value=LatLng(result.result.geometry.location.lat,result.result.geometry.location.lng);
                                                         if(source.text.isNotEmpty)
                                                           showButton.value = true;
                                                         isTypingDestination.value=false;
                                                       }
                                                       else if(addressType.value == 1){
                                                         isTypingSource.value=true;
                                                         DetailsResponse result = await googlePlace.details.get("${predictions[index].placeId}",);
                                                         source.text = ((predictions[index].description as String).contains('Nigeria')?(predictions[index].description as String).replaceFirst(', Nigeria', ''):(predictions[index].description as String));
                                                         sourcePosition.value=LatLng(result.result.geometry.location.lat,result.result.geometry.location.lng);
                                                         if(destination.text.isNotEmpty)
                                                           showButton.value = true;
                                                         isTypingSource.value=false;
                                                       }
                                                     },
                                                   );
                                                 },
                                               itemCount: predictions.length,
                                             )
                                          );
                                        },
                                      )
                                    ),
                                  if(!typing)
                                    Expanded(
                                      flex: 0,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(vertical: 20),
                                            child: ListTile(
                                              leading: Icon(Icons.place),
                                              subtitle: Text('you can also select a destination by clicking the destination point on the google map.'),
                                            ),
                                          ),
                                          /*Padding(
                                            padding: EdgeInsets.symmetric(vertical: 10),
                                            child: ListTile(
                                              leading: Icon(AntIcons.question),
                                              title: Text('Information'),
                                              subtitle: Text('Please ensure a rider accept your request before engaging them.'),
                                            ),
                                          ),*/
                                        ],
                                      )
                                    ),
                                ],
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  ):Center(
                      child: JumpingDotsProgressIndicator(
                        fontSize: MediaQuery.of(context).size.height * 0.12,
                        color: PRIMARYCOLOR,
                      ))
              )

    );


  }
}