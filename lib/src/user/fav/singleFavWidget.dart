import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:pocketshopping/model/DataModel/categoryData.dart';
import 'package:pocketshopping/src/geofence/package_geofence.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:pocketshopping/src/user/fav/repository/favItem.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class SingleFavoriteWidget extends StatefulWidget {
  final FavItem item;
  final Position position;
  final User user;
  SingleFavoriteWidget({@required this.item,this.position,this.user});
  @override
  State<StatefulWidget> createState() => _FavoriteState();
}

class _FavoriteState extends State<SingleFavoriteWidget> {

  bool loading;
  Merchant merchant;
  @override
  void initState() {
    loading= false;
    MerchantRepo.getMerchant(widget.item.merchant).then((value) => setState((){merchant = value;}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              //offset: Offset(1.0, 0), //(x,y)
              blurRadius: 6.0,
            ),
          ],
          image: DecorationImage(
            image: NetworkImage(merchant != null? merchant.bPhoto.isNotEmpty ? merchant.bPhoto : PocketShoppingDefaultCover: PocketShoppingDefaultCover),
            fit: BoxFit.cover,
            colorFilter: new ColorFilter.mode(
                Colors.black.withOpacity(0.25), BlendMode.dstATop),
            //colorFilter: Colors.black.withOpacity(0.4),
          ),
        ),
        margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),

                child: merchant!=null?
                Center(child:
                GestureDetector(
                    onTap: () {
                      final page = MerchantUI(
                        merchant: merchant,
                        user: widget.user,
                        distance: getDistance(),
                        initPosition: widget.position,
                      );
                      Get.to(page);
                    },
                    child:
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${merchant.bName}',style: TextStyle(color: Colors.white,fontSize: 18),),
                    Text('${Utility.presentDate(DateTime.parse((widget.item.visitedAt as Timestamp).toDate().toString()))}',style: TextStyle(color: Colors.white),)
                  ],
                )
                )
                )
                    :Center(
                  child:JumpingDotsProgressIndicator(
                    fontSize: MediaQuery.of(context).size.height * 0.1,
                    color: Colors.white,
                  ),
                )
    );
  }

  double getDistance(){
    var current = GeoFirePoint(widget.position.latitude,widget.position.longitude);
    return  current.distance(
        lat: merchant.bGeoPoint['geopoint'].latitude,
        lng: merchant.bGeoPoint['geopoint'].longitude);
  }
}