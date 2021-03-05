import 'dart:async';

import 'package:ant_icons/ant_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_skeleton/flutter_skeleton.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:location/location.dart' as loc;
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/errand/map.dart';
import 'package:pocketshopping/src/errand/selectAuto.dart';
import 'package:pocketshopping/src/geofence/repository/fenceRepo.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/review/repository/ReviewRepo.dart';
import 'package:pocketshopping/src/review/repository/rating.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/fav/repository/favObj.dart';
import 'package:pocketshopping/src/user/fav/repository/favRepo.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';


class Errand extends StatefulWidget {
  final Session user;
  final Position position;
  final Merchant logistic;
  Errand({this.user,this.position,this.logistic});

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
  final logisticList = ValueNotifier<List<Merchant>>([]);
  final favourites = ValueNotifier<Favourite>(null);

  @override
  void initState() {
    location = new loc.Location();
    googlePlace = GooglePlace(googleAPIKey);
    currentUser = widget.user;

    position = widget.position;

    if(position != null){
      Utility.address(position).then((value) => source.text=value);
      sourcePosition.value = LatLng(position.latitude,position.longitude);
      FenceRepo.nearByLogistic(position, null).then((value) => logisticList.value = value);
    }
    else{
      location.changeSettings(accuracy: loc.LocationAccuracy.high);
      location.getLocation().then((loc.LocationData cLoc) {
        position = Position(latitude: cLoc.latitude,longitude: cLoc.longitude);
        if (mounted) setState(() {});
        Utility.address(position).then((value) => source.text=value);
        sourcePosition.value = LatLng(position.latitude,position.longitude);
        FenceRepo.nearByLogistic(position, null).then((value) => logisticList.value = value);
      });
    }

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
    FavRepo.getFavourites(widget.user.user.uid, 'count',category: 'logistic').then((value) => favourites.value = value);
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
                                              Expanded(
                                                flex: 0,
                                                  child:
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
                                              ),
                                              Expanded(
                                                  child:Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Padding(
                                                        padding: EdgeInsets.symmetric(vertical: 5),
                                                        child: Text('Request For a ${widget.logistic != null?widget.logistic.bName:''} Rider.',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),)
                                                    ),
                                                  ),
                                              )
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
                                                                showButton.value = false;
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
                                                            showButton.value= source.text.isNotEmpty&&destination.text.isNotEmpty;
                                                            autocomplete.value=[];
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
                                                                showButton.value = false;
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
                                                            showButton.value= source.text.isNotEmpty&&destination.text.isNotEmpty;
                                                            autocomplete.value=[];
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
                                                    double distance =  distanceBetween(sourcePosition.value.latitude, sourcePosition.value.longitude,
                                                        destinationPosition.value.latitude, destinationPosition.value.longitude);
                                                    if(distance > 0){
                                                      /*Get.to(SelectAuto(
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
                                                      });*/
                                                      if(widget.logistic == null)
                                                      Get.dialog(GestureDetector(
                                                        onTap: (){Get.back();},
                                                        child: Scaffold(
                                                          backgroundColor: Colors.black.withOpacity(0.3),
                                                          body: Center(
                                                            child: Padding(
                                                              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Container(
                                                                    color: Colors.white,
                                                                    child: Column(
                                                                      children: [
                                                                        Padding(
                                                                          padding: EdgeInsets.symmetric(vertical: 10),
                                                                          child: Text('Choose a Rider.',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                                                                        ),
                                                                        ListTile(
                                                                          onTap: (){
                                                                            Merchant one = logisticList.value.firstWhere((element) => (element.vanCount > 0 || element.bikeCount>0 || element.carCount>0)&&(element.bStatus == 1 &&
                                                                                Utility.isOperational(
                                                                                    element.bOpen,
                                                                                    element.bClose)));
                                                                            Get.off(

                                                                                SelectAuto(
                                                                              user: currentUser,
                                                                              position: position,
                                                                              source: sourcePosition.value,
                                                                              destination: destinationPosition.value,
                                                                              distance: (distance/1000).round(),
                                                                              sourceAddress: source.text,
                                                                              destinationAddress: destination.text,
                                                                              logistic:one?.mID,
                                                                              bCount: one?.bikeCount,
                                                                              cCount: one?.carCount,
                                                                              vCount: one?.vanCount,
                                                                              logName: one?.bName,
                                                                              canCheck: true,

                                                                            )).then((value) {
                                                                              destination.clear();
                                                                              isTyping.value=false;
                                                                            });
                                                                          },
                                                                          leading: CircleAvatar(
                                                                            radius: 20,
                                                                            child: Image.asset('assets/images/blogo.png'),
                                                                            backgroundColor: Colors.white,

                                                                          ),
                                                                          title: Text('Let Pocketshopping choose for you'),
                                                                          subtitle: Text('Pocketshooping algorithm will pick the closest rider'),
                                                                        ),
                                                                        const Divider(
                                                                          thickness: 1,
                                                                        ),
                                                                        ListTile(
                                                                          onTap: (){
                                                                            Get.back();
                                                                            Get.dialog(GestureDetector(
                                                                              onTap: (){Get.back();},
                                                                              child: Scaffold(
                                                                                resizeToAvoidBottomPadding : false,
                                                                                backgroundColor: Colors.black.withOpacity(0.3),
                                                                                body: Center(
                                                                                  child: Padding(
                                                                                    padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                                                                    child: Column(
                                                                                      mainAxisSize: MainAxisSize.min,
                                                                                      children: [
                                                                                        Container(
                                                                                          color: Colors.white,
                                                                                          height: Get.height*0.8,
                                                                                          child: Column(
                                                                                            children: [
                                                                                              ListTile(
                                                                                                  onTap: (){},
                                                                                                  title: Text('Select Rider', style: TextStyle(fontSize: Get.height * 0.03),),
                                                                                                  subtitle: Text('Please note this method might take more time. Select from list below.')//,
                                                                                              ),
                                                                                              Padding(
                                                                                                padding: EdgeInsets.symmetric(vertical: 5,horizontal: 15),
                                                                                                child: TextFormField(
                                                                                                  controller: null,
                                                                                                  decoration: InputDecoration(
                                                                                                    prefixIcon: Icon(Icons.search),
                                                                                                    labelText: 'Search For Rider',
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
                                                                                                    if(value.isNotEmpty)
                                                                                                    {
                                                                                                      logisticList.value=null;
                                                                                                      favourites.value = null;
                                                                                                      logisticList.value = await FenceRepo.searchNearByLogistic(position, value.toLowerCase().trim());

                                                                                                    }
                                                                                                    else{
                                                                                                      logisticList.value=null;
                                                                                                      FavRepo.getFavourites(widget.user.user.uid, 'count',category: 'logistic').then((value) => favourites.value = value);
                                                                                                      logisticList.value = await FenceRepo.nearByLogistic(position, null);
                                                                                                    }
                                                                                                  },
                                                                                                ),
                                                                                              ),
                                                                                              const SizedBox(height: 10,),
                                                                                              Expanded(
                                                                                                  child: ListView(
                                                                                                    children: [
                                                                                                      ValueListenableBuilder(
                                                                                                        valueListenable: favourites,
                                                                                                        builder: (i,Favourite fav,ii){
                                                                                                          if(fav != null){
                                                                                                            if(fav.favourite.isNotEmpty)
                                                                                                            return Column(
                                                                                                              children: [
                                                                                                                Align(
                                                                                                                  alignment: Alignment.centerLeft,
                                                                                                                  child: Padding(
                                                                                                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                                                                                                    child: Text('Favourite'),
                                                                                                                  ),
                                                                                                                ),
                                                                                                                Column(
                                                                                                                    children: List<Widget>.generate(fav.favourite.values.length, (index){
                                                                                                                      return FutureBuilder(
                                                                                                                        future: MerchantRepo.getMerchant(fav.favourite.values.toList(growable: false)[index].merchant),
                                                                                                                        builder: (context,AsyncSnapshot<Merchant>merchant){
                                                                                                                          if(merchant.connectionState == ConnectionState.waiting){
                                                                                                                            return Container(
                                                                                                                              height: 80,
                                                                                                                              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                                                                                                              child: ListSkeleton(
                                                                                                                                style: SkeletonStyle(
                                                                                                                                  theme: SkeletonTheme.Light,
                                                                                                                                  isShowAvatar: false,
                                                                                                                                  barCount: 3,
                                                                                                                                  colors: [
                                                                                                                                    Colors.grey.withOpacity(0.5),
                                                                                                                                    Colors.grey,
                                                                                                                                    Colors.grey.withOpacity(0.5)
                                                                                                                                  ],
                                                                                                                                  isAnimation: true,
                                                                                                                                ),
                                                                                                                              ),
                                                                                                                              alignment: Alignment.center,
                                                                                                                            );
                                                                                                                          }
                                                                                                                          else if(merchant.hasError){return const SizedBox.shrink();}
                                                                                                                          else{
                                                                                                                            if(fav.favourite.isNotEmpty){
                                                                                                                              return Column(
                                                                                                                                children: [
                                                                                                                                  Padding(
                                                                                                                                      padding: EdgeInsets.symmetric(vertical: 5),
                                                                                                                                      child: ListTile(
                                                                                                                                        onTap: (){

                                                                                                                                          Get.off(SelectAuto(
                                                                                                                                            user: currentUser,
                                                                                                                                            position: position,
                                                                                                                                            source: sourcePosition.value,
                                                                                                                                            destination: destinationPosition.value,
                                                                                                                                            distance: (distance/1000).round(),
                                                                                                                                            sourceAddress: source.text,
                                                                                                                                            destinationAddress: destination.text,
                                                                                                                                            logistic:merchant.data.mID,
                                                                                                                                            bCount: merchant.data.bikeCount,
                                                                                                                                            cCount: merchant.data.carCount,
                                                                                                                                            vCount: merchant.data.vanCount,
                                                                                                                                            logName: merchant.data.bName,
                                                                                                                                          )).then((value) {
                                                                                                                                            destination.clear();
                                                                                                                                            isTyping.value=false;
                                                                                                                                          });

                                                                                                                                        },
                                                                                                                                        leading: CircleAvatar(
                                                                                                                                          radius: 30,
                                                                                                                                          backgroundImage: NetworkImage(merchant.data.bPhoto.isNotEmpty?merchant.data.bPhoto:PocketShoppingDefaultCover),
                                                                                                                                        ),
                                                                                                                                        title: Text(merchant.data.bName),
                                                                                                                                        subtitle: Column(
                                                                                                                                          children: [
                                                                                                                                            Row(
                                                                                                                                              children: [
                                                                                                                                                FutureBuilder(
                                                                                                                                                  future: ReviewRepo.getRating(merchant.data.mID),
                                                                                                                                                  builder: (context,AsyncSnapshot<Rating>snapshot){
                                                                                                                                                    if(snapshot.connectionState == ConnectionState.waiting)return const SizedBox.shrink();
                                                                                                                                                    else if(snapshot.hasError)return const SizedBox.shrink();
                                                                                                                                                    else {
                                                                                                                                                      if(snapshot.hasData){
                                                                                                                                                        if(snapshot.data != null){
                                                                                                                                                          return RatingBar(
                                                                                                                                                            onRatingUpdate: null,
                                                                                                                                                            initialRating: snapshot.data.rating,
                                                                                                                                                            minRating: 1,
                                                                                                                                                            maxRating: 5,
                                                                                                                                                            itemSize: Get.width * 0.05,
                                                                                                                                                            direction: Axis.horizontal,
                                                                                                                                                            allowHalfRating: true,
                                                                                                                                                            ignoreGestures: true,
                                                                                                                                                            itemCount: 5,
                                                                                                                                                            //itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                                                                                                                                            itemBuilder: (context, _) => Icon(
                                                                                                                                                              Icons.star,
                                                                                                                                                              color: Colors.amber,
                                                                                                                                                            ),
                                                                                                                                                          );
                                                                                                                                                        }
                                                                                                                                                        else{
                                                                                                                                                          return RatingBar(
                                                                                                                                                            onRatingUpdate: null,
                                                                                                                                                            initialRating: 3,
                                                                                                                                                            minRating: 1,
                                                                                                                                                            maxRating: 5,
                                                                                                                                                            itemSize: Get.width * 0.05,
                                                                                                                                                            direction: Axis.horizontal,
                                                                                                                                                            allowHalfRating: true,
                                                                                                                                                            ignoreGestures: true,
                                                                                                                                                            itemCount: 5,
                                                                                                                                                            //itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                                                                                                                                            itemBuilder: (context, _) => Icon(
                                                                                                                                                              Icons.star,
                                                                                                                                                              color: Colors.amber,
                                                                                                                                                            ),
                                                                                                                                                          );
                                                                                                                                                        }
                                                                                                                                                      }
                                                                                                                                                      else{
                                                                                                                                                        return RatingBar(
                                                                                                                                                          onRatingUpdate: null,
                                                                                                                                                          initialRating: 3,
                                                                                                                                                          minRating: 1,
                                                                                                                                                          maxRating: 5,
                                                                                                                                                          itemSize: Get.width * 0.05,
                                                                                                                                                          direction: Axis.horizontal,
                                                                                                                                                          allowHalfRating: true,
                                                                                                                                                          ignoreGestures: true,
                                                                                                                                                          itemCount: 5,
                                                                                                                                                          //itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                                                                                                                                          itemBuilder: (context, _) => Icon(
                                                                                                                                                            Icons.star,
                                                                                                                                                            color: Colors.amber,
                                                                                                                                                          ),
                                                                                                                                                        );
                                                                                                                                                      }
                                                                                                                                                    }
                                                                                                                                                  },
                                                                                                                                                ),
                                                                                                                                              ],
                                                                                                                                            ),
                                                                                                                                            Row(
                                                                                                                                              children: [
                                                                                                                                                Expanded(child:
                                                                                                                                                FutureBuilder(
                                                                                                                                                    future: Utility.computeDistance(merchant.data.bGeoPoint['geopoint'],GeoPoint(sourcePosition.value.latitude, sourcePosition.value.longitude)),
                                                                                                                                                    initialData: 0.1,
                                                                                                                                                    builder: (context,AsyncSnapshot<double> distance){
                                                                                                                                                      if(distance.hasData){
                                                                                                                                                        return Text('${Utility.formatDistance(distance.data, 'Source')}');
                                                                                                                                                      }
                                                                                                                                                      else{
                                                                                                                                                        return const SizedBox.shrink();
                                                                                                                                                      }
                                                                                                                                                    })
                                                                                                                                                )
                                                                                                                                              ],
                                                                                                                                            )
                                                                                                                                          ],
                                                                                                                                        ),
                                                                                                                                        trailing:
                                                                                                                                        (merchant.data.bStatus == 1 && Utility.isOperational(merchant.data.bOpen, merchant.data.bClose))?
                                                                                                                                        Icon(Icons.lock_open,color: Colors.green,)
                                                                                                                                            :Icon(Icons.lock_outline,color: Colors.redAccent,),
                                                                                                                                        enabled: (merchant.data.bStatus == 1 && Utility.isOperational(merchant.data.bOpen, merchant.data.bClose)),
                                                                                                                                      )
                                                                                                                                  ),
                                                                                                                                  Divider(thickness: 1,)
                                                                                                                                ],
                                                                                                                              );
                                                                                                                            }
                                                                                                                            else{
                                                                                                                              return const SizedBox.shrink();
                                                                                                                            }
                                                                                                                          }
                                                                                                                        },
                                                                                                                      );
                                                                                                                    }).toList(growable: false)
                                                                                                                ),
                                                                                                                const SizedBox(height: 30,),
                                                                                                                Align(
                                                                                                                  alignment: Alignment.centerLeft,
                                                                                                                  child: Padding(
                                                                                                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                                                                                                    child: Text('Others'),
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ],
                                                                                                            );
                                                                                                            else
                                                                                                              return const SizedBox.shrink();
                                                                                                          }
                                                                                                          else{return const SizedBox.shrink();}
                                                                                                        },
                                                                                                      ),

                                                                                                      ValueListenableBuilder(
                                                                                                          valueListenable: logisticList,
                                                                                                          builder: (_,List<Merchant> logisticList,__){
                                                                                                            if(logisticList != null)
                                                                                                              if(logisticList.isNotEmpty)
                                                                                                               return Column(
                                                                                                                    children: List<Widget>.generate(logisticList.length, (index){
                                                                                                                      return Column(
                                                                                                                        children: [
                                                                                                                          Padding(
                                                                                                                              padding: EdgeInsets.symmetric(vertical: 5),
                                                                                                                              child: ListTile(
                                                                                                                                onTap: (){
                                                                                                                                  Get.off(SelectAuto(
                                                                                                                                    user: currentUser,
                                                                                                                                    position: position,
                                                                                                                                    source: sourcePosition.value,
                                                                                                                                    destination: destinationPosition.value,
                                                                                                                                    distance: (distance/1000).round(),
                                                                                                                                    sourceAddress: source.text,
                                                                                                                                    destinationAddress: destination.text,
                                                                                                                                    logistic:logisticList[index].mID,
                                                                                                                                    bCount: logisticList[index].bikeCount,
                                                                                                                                    cCount: logisticList[index].carCount,
                                                                                                                                    vCount: logisticList[index].vanCount,
                                                                                                                                    logName: logisticList[index].bName,
                                                                                                                                  )).then((value) {
                                                                                                                                    destination.clear();
                                                                                                                                    isTyping.value=false;
                                                                                                                                  });
                                                                                                                                },
                                                                                                                                leading: CircleAvatar(
                                                                                                                                  radius: 30,
                                                                                                                                  backgroundImage: NetworkImage(logisticList[index].bPhoto.isNotEmpty?logisticList[index].bPhoto:PocketShoppingDefaultCover),
                                                                                                                                ),
                                                                                                                                title: Text(logisticList[index].bName),
                                                                                                                                subtitle: Column(
                                                                                                                                  children: [
                                                                                                                                    Row(
                                                                                                                                      children: [
                                                                                                                                        FutureBuilder(
                                                                                                                                          future: ReviewRepo.getRating(logisticList[index].mID),
                                                                                                                                          builder: (context,AsyncSnapshot<Rating>snapshot){
                                                                                                                                            if(snapshot.connectionState == ConnectionState.waiting)return const SizedBox.shrink();
                                                                                                                                            else if(snapshot.hasError)return const SizedBox.shrink();
                                                                                                                                            else {
                                                                                                                                              if(snapshot.hasData){
                                                                                                                                                if(snapshot.data != null){
                                                                                                                                                  return RatingBar(
                                                                                                                                                    onRatingUpdate: null,
                                                                                                                                                    initialRating: snapshot.data.rating,
                                                                                                                                                    minRating: 1,
                                                                                                                                                    maxRating: 5,
                                                                                                                                                    itemSize: Get.width * 0.05,
                                                                                                                                                    direction: Axis.horizontal,
                                                                                                                                                    allowHalfRating: true,
                                                                                                                                                    ignoreGestures: true,
                                                                                                                                                    itemCount: 5,
                                                                                                                                                    //itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                                                                                                                                    itemBuilder: (context, _) => Icon(
                                                                                                                                                      Icons.star,
                                                                                                                                                      color: Colors.amber,
                                                                                                                                                    ),
                                                                                                                                                  );
                                                                                                                                                }
                                                                                                                                                else{
                                                                                                                                                  return RatingBar(
                                                                                                                                                    onRatingUpdate: null,
                                                                                                                                                    initialRating: 3,
                                                                                                                                                    minRating: 1,
                                                                                                                                                    maxRating: 5,
                                                                                                                                                    itemSize: Get.width * 0.05,
                                                                                                                                                    direction: Axis.horizontal,
                                                                                                                                                    allowHalfRating: true,
                                                                                                                                                    ignoreGestures: true,
                                                                                                                                                    itemCount: 5,
                                                                                                                                                    //itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                                                                                                                                    itemBuilder: (context, _) => Icon(
                                                                                                                                                      Icons.star,
                                                                                                                                                      color: Colors.amber,
                                                                                                                                                    ),
                                                                                                                                                  );
                                                                                                                                                }
                                                                                                                                              }
                                                                                                                                              else{
                                                                                                                                                return RatingBar(
                                                                                                                                                  onRatingUpdate: null,
                                                                                                                                                  initialRating: 3,
                                                                                                                                                  minRating: 1,
                                                                                                                                                  maxRating: 5,
                                                                                                                                                  itemSize: Get.width * 0.05,
                                                                                                                                                  direction: Axis.horizontal,
                                                                                                                                                  allowHalfRating: true,
                                                                                                                                                  ignoreGestures: true,
                                                                                                                                                  itemCount: 5,
                                                                                                                                                  //itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                                                                                                                                  itemBuilder: (context, _) => Icon(
                                                                                                                                                    Icons.star,
                                                                                                                                                    color: Colors.amber,
                                                                                                                                                  ),
                                                                                                                                                );
                                                                                                                                              }
                                                                                                                                            }
                                                                                                                                          },
                                                                                                                                        ),
                                                                                                                                      ],
                                                                                                                                    ),
                                                                                                                                    Row(
                                                                                                                                      children: [

                                                                                                                                        Expanded(child:
                                                                                                                                        FutureBuilder(
                                                                                                                                            future: Utility.computeDistance(logisticList[index].bGeoPoint['geopoint'],GeoPoint(sourcePosition.value.latitude, sourcePosition.value.longitude)),
                                                                                                                                            initialData: 0.1,
                                                                                                                                            builder: (context,AsyncSnapshot<double> distance){
                                                                                                                                              if(distance.hasData){
                                                                                                                                                return Text('${Utility.formatDistance(distance.data, 'Source')}');
                                                                                                                                              }
                                                                                                                                              else{
                                                                                                                                                return const SizedBox.shrink();
                                                                                                                                              }
                                                                                                                                            })
                                                                                                                                        )
                                                                                                                                      ],
                                                                                                                                    )
                                                                                                                                  ],
                                                                                                                                ),
                                                                                                                                trailing:
                                                                                                                                (logisticList[index].bStatus == 1 && Utility.isOperational(logisticList[index].bOpen, logisticList[index].bClose))?
                                                                                                                                Icon(Icons.lock_open,color: Colors.green,)
                                                                                                                                    :Icon(Icons.lock_outline,color: Colors.redAccent,),
                                                                                                                                enabled: (logisticList[index].bStatus == 1 && Utility.isOperational(logisticList[index].bOpen, logisticList[index].bClose)),
                                                                                                                              )
                                                                                                                          ),
                                                                                                                          Divider(thickness: 1,)
                                                                                                                        ],
                                                                                                                      );
                                                                                                                    }).toList(growable: false)
                                                                                                                );
                                                                                                              else
                                                                                                                return Center(
                                                                                                                    child: Padding(
                                                                                                                      padding: EdgeInsets.symmetric(vertical: 20),
                                                                                                                      child: Text('No Rider(s)'),
                                                                                                                    )
                                                                                                                );
                                                                                                            else
                                                                                                            return  Center(
                                                                                                                  child: Padding(
                                                                                                                    padding: EdgeInsets.symmetric(vertical: 20),
                                                                                                                    child: Text('Fetching Riders...Please wait'),
                                                                                                                  )
                                                                                                              );
                                                                                                          })
                                                                                                    ],
                                                                                                  )
                                                                                              )
                                                                                            ],
                                                                                          ),
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ));
                                                                          },
                                                                          leading: CircleAvatar(
                                                                            radius: 20,
                                                                            child: Icon(Icons.person_outline),
                                                                            backgroundColor: Colors.white,

                                                                          ),
                                                                          title: Text('I want choose for myself'),
                                                                          subtitle: Text('please note this might take more time.'),
                                                                          enabled: position != null,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ));
                                                      else{
                                                        Get.off(SelectAuto(
                                                          user: currentUser,
                                                          position: position,
                                                          source: sourcePosition.value,
                                                          destination: destinationPosition.value,
                                                          distance: (distance/1000).round(),
                                                          sourceAddress: source.text,
                                                          destinationAddress: destination.text,
                                                          logistic:widget.logistic.mID,
                                                          bCount: widget.logistic.bikeCount,
                                                          cCount: widget.logistic.carCount,
                                                          vCount: widget.logistic.vanCount,
                                                          logName: widget.logistic.bName,
                                                        )).then((value) {
                                                          destination.clear();
                                                          isTyping.value=false;
                                                        });
                                                      }

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
                                             child: predictions.isNotEmpty?ListView.builder(
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
                                                         try{
                                                           isTypingDestination.value=true;
                                                           DetailsResponse result = await googlePlace.details.get("${predictions[index].placeId}",);
                                                           //print(result.result.geometry.location.lng);
                                                           if(result != null){
                                                             destination.text = ((predictions[index].description as String).contains('Nigeria')?(predictions[index].description as String).replaceFirst(', Nigeria', ''):(predictions[index].description as String));
                                                             destinationPosition.value=LatLng(result.result.geometry.location.lat,result.result.geometry.location.lng);
                                                             if(source.text.isNotEmpty) showButton.value = true;
                                                             isTypingDestination.value=false;
                                                           }
                                                           else{
                                                             isTypingDestination.value=false;
                                                             destination.text ="";
                                                             showButton.value = false;
                                                             Scaffold.of(
                                                                 context)
                                                               ..hideCurrentSnackBar()
                                                               ..showSnackBar(
                                                                   SnackBar(
                                                                     content: Text(
                                                                         'Error Picking Destination. Try again'),
                                                                     backgroundColor:
                                                                     Colors
                                                                         .redAccent,
                                                                     behavior:
                                                                     SnackBarBehavior
                                                                         .floating,
                                                                   ));
                                                           }

                                                         }catch(e){

                                                           isTypingDestination.value=false;
                                                           destination.text ="";
                                                           showButton.value = false;
                                                           Scaffold.of(
                                                               context)
                                                             ..hideCurrentSnackBar()
                                                             ..showSnackBar(
                                                                 SnackBar(
                                                                   content: Text(
                                                                       'Error Picking Destination. Try again'),
                                                                   backgroundColor:
                                                                   Colors
                                                                       .redAccent,
                                                                   behavior:
                                                                   SnackBarBehavior
                                                                       .floating,
                                                                 ));
                                                         }
                                                       }
                                                       else if(addressType.value == 1){
                                                         try{
                                                           isTypingSource.value=true;
                                                           DetailsResponse result = await googlePlace.details.get("${predictions[index].placeId}",);
                                                           if(result != null){
                                                             source.text = ((predictions[index].description as String).contains('Nigeria')?(predictions[index].description as String).replaceFirst(', Nigeria', ''):(predictions[index].description as String));
                                                             sourcePosition.value=LatLng(result.result.geometry.location.lat,result.result.geometry.location.lng);
                                                             logisticList.value = await FenceRepo.nearByLogistic(Position(latitude: sourcePosition.value.latitude,longitude: sourcePosition.value.longitude), null);
                                                             if(destination.text.isNotEmpty) showButton.value = true;
                                                             isTypingSource.value=false;
                                                           }
                                                           else{
                                                             isTypingSource.value=false;
                                                             source.text = "";
                                                             showButton.value = false;
                                                             Scaffold.of(
                                                                 context)
                                                               ..hideCurrentSnackBar()
                                                               ..showSnackBar(
                                                                   SnackBar(
                                                                     content: Text(
                                                                         'Error Picking Source. Try again'),
                                                                     backgroundColor:
                                                                     Colors
                                                                         .redAccent,
                                                                     behavior:
                                                                     SnackBarBehavior
                                                                         .floating,
                                                                   ));
                                                           }
                                                         }
                                                         catch(e){
                                                           isTypingSource.value=false;
                                                           source.text = "";
                                                           showButton.value = false;
                                                           Scaffold.of(
                                                               context)
                                                             ..hideCurrentSnackBar()
                                                             ..showSnackBar(
                                                                 SnackBar(
                                                                   content: Text(
                                                                       'Error Picking Source. Try again'),
                                                                   backgroundColor:
                                                                   Colors
                                                                       .redAccent,
                                                                   behavior:
                                                                   SnackBarBehavior
                                                                       .floating,
                                                                 ));
                                                         }
                                                       }
                                                     },
                                                   );
                                                 },
                                               itemCount: predictions.length,
                                             ):
                                             Column(
                                               mainAxisSize: MainAxisSize.min,
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: [
                                                 Align(

                                                   child: JumpingDotsProgressIndicator(
                                                     fontSize: Get.height * 0.12,
                                                     color: PRIMARYCOLOR,

                                                   ),
                                                   alignment: Alignment.topCenter,
                                                 ),
                                                 Center(
                                                   child: Image.asset('assets/images/google.png',height: 100,width: 150,),
                                                 ),
                                               ],
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
                        fontSize: Get.height * 0.12,
                        color: PRIMARYCOLOR,
                      ))
              )

    );


  }
}