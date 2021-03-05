import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/errand/errand.dart';
import 'package:pocketshopping/src/geofence/singleMerchant.dart';
import 'package:pocketshopping/src/review/repository/ReviewRepo.dart';
import 'package:pocketshopping/src/review/repository/rating.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/fav/repository/favObj.dart' as favr;
import 'package:pocketshopping/src/user/fav/repository/favRepo.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

class MerchantScreen extends StatefulWidget {
  final String merchant;
  final String user;

  MerchantScreen({this.merchant,this.user});

  @override
  _MerchantScreen createState() => new _MerchantScreen();
}

class _MerchantScreen extends State<MerchantScreen> {
  StreamSubscription<Position> _position;
  final position = ValueNotifier<Position>(null);
  final favrite = ValueNotifier<bool>(false);
  @override
  void initState() {
    _position =  getPositionStream(desiredAccuracy: LocationAccuracy.best,timeInterval: 1000).listen((pos) {
      position.value = pos;
    });
    super.initState();
  }

  @override
  void dispose() {
    _position?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: UserRepo.getOneUsingUID(widget.user),
        builder: (context,AsyncSnapshot<User>user){
          if(user.connectionState == ConnectionState.waiting){
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  JumpingDotsProgressIndicator(
                    fontSize: Get.height * 0.12,
                    color: PRIMARYCOLOR,
                  ),
                  Text('Fetching User...')
                ],
              ),
            );
          }
          else if(user.hasError){
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Error Encountered while fetching user..Try Again'),
              ),
            );
          }
          else{
            if(user.data != null){
              return FutureBuilder(
                future: MerchantRepo.getMerchant(widget.merchant,source: 1),
                builder: (context,AsyncSnapshot<Merchant>merchant){
                  if(merchant.connectionState == ConnectionState.waiting){
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          JumpingDotsProgressIndicator(
                            fontSize: Get.height * 0.12,
                            color: PRIMARYCOLOR,
                          ),
                          Text('Fetching Merchant...')
                        ],
                      ),
                    );
                  }
                  else if(merchant.hasError){
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text('Error Encountered while fetching merchant..Try Again'),
                      ),
                    );
                  }
                  else{
                    if(merchant.data != null){

                      return Scaffold(
                          backgroundColor: Colors.white,
                          body: ListView(
                            children: [
                              Center(
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      height: Get.height * 0.4,
                                      child: ShaderMask(
                                        shaderCallback: (rect) {
                                          return LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [Colors.black, Colors.transparent],
                                          ).createShader(
                                              Rect.fromLTRB(0, 0, rect.width, rect.height));
                                        },
                                        blendMode: BlendMode.dstIn,
                                        child: FadeInImage.memoryNetwork(
                                          placeholder: kTransparentImage,
                                          image: merchant.data.bPhoto.isNotEmpty
                                              ? merchant.data.bPhoto
                                              : PocketShoppingDefaultCover,
                                          fit: BoxFit.cover,
                                          width: Get.width,
                                          height: Get.height * 0.4,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: Get.height * 0.5,
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                              merchant.data.bName ?? 'Merchant',
                                              style: TextStyle(
                                                  fontSize:
                                                  Get.height * 0.06,
                                                  color: Colors.black54),
                                              textAlign: TextAlign.center
                                          ),
                                          Text('${merchant.data.bAddress}'),
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
                                          SizedBox(height: 20),
                                          Text(
                                            'Contact Us',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize:
                                                Get.height * 0.03,
                                                color: Colors.black54),
                                          ),
                                          FlatButton(
                                            onPressed: () => launch("tel:${merchant.data.bTelephone}"),
                                            child: Icon(Icons.call,
                                                size:
                                                Get.height * 0.1,
                                                color: Colors.black54),
                                          ),
                                          Text('${merchant.data.bTelephone}'),
                                          SizedBox(height: 30),
                                          if(merchant.data.bCategory == 'Logistic')
                                            FlatButton(
                                                onPressed: (){
                                                  Get.off(Errand(logistic: merchant.data,position: position.value,user: Session(user: user.data),));
                                                },
                                                color: PRIMARYCOLOR,
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                                  child: Text('Request For A Rider',style: TextStyle(color: Colors.white),),
                                                )
                                            )
                                          else
                                            FlatButton(
                                                onPressed: ()async{
                                                  double distance=0.0;
                                                  if(position.value != null){
                                                    distance = await  Utility.computeDistance(GeoPoint(position.value.latitude, position.value.longitude),
                                                        merchant.data.bGeoPoint['geopoint']);

                                                    Get.off(MerchantUI(
                                                      merchant: merchant.data,
                                                      initPosition: position.value,
                                                      user: user.data,
                                                      distance: distance>0?(distance/1000):0.0,
                                                    ));
                                                  }

                                                },
                                                color: PRIMARYCOLOR,
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                                  child: Text('Shop Now',style: TextStyle(color: Colors.white),),
                                                )
                                            ),

                                          ValueListenableBuilder(
                                            valueListenable: favrite,
                                            builder: (_,bool added,__){
                                              if(added){
                                                return const SizedBox.shrink();
                                              }
                                              else{
                                                return FutureBuilder(
                                                  future: FavRepo.getFavourites(user.data.uid,'count',category: merchant.data.bCategory != 'Logistic'?'merchant':'logistic',),
                                                  builder: (context,AsyncSnapshot<favr.Favourite>fav){
                                                    if(fav.hasData){
                                                      if(fav.data.favourite.isNotEmpty){
                                                        return const SizedBox.shrink();
                                                      }
                                                      else{
                                                        return FlatButton.icon(
                                                          onPressed: (){
                                                            if(merchant.data.bCategory != 'Logistic'){
                                                              FavRepo.save(user.data.uid, merchant.data.mID,'merchant');
                                                            }
                                                            else{
                                                              FavRepo.save(user.data.uid, merchant.data.mID,'logistic');
                                                            }
                                                            favrite.value =true;
                                                          },
                                                          icon: Icon(Icons.favorite_border,color: PRIMARYCOLOR,),
                                                          label: Text('Add to Favourite',style: TextStyle(color: PRIMARYCOLOR),),
                                                        );
                                                      }
                                                    }
                                                    else{
                                                      return const SizedBox.shrink();
                                                    }
                                                  },
                                                );
                                              }
                                            },
                                          ),


                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          )
                      );
                    }
                    else{
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text('Error Encountered while fetching merchant..Try Again'),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                },
              );
            }
            else{
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Error Encountered while fetching user..Try Again'),
                    ),
                  ],
                ),
              );
            }
          }
        },
      )
    );
  }
}
