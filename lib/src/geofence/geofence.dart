import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:location/location.dart' as loc;
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/geofence/orderUI.dart';
import 'package:pocketshopping/src/geofence/package_geofence.dart';
import 'package:pocketshopping/src/geofence/repository/fenceRepo.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:transparent_image/transparent_image.dart';

class GeoFence extends StatefulWidget {

  final Session user;
  final String category;
  final Position position;
  GeoFence({this.user,this.category,this.position});

  @override
  State<StatefulWidget> createState() => _GeoFenceState();
}

class _GeoFenceState extends State<GeoFence> {

  Session currentUser;
  final category = ValueNotifier<String>('');
  final position = ValueNotifier<Position>(null);
  loc.Location location;
  StreamSubscription<Position> locStream;


  @override
  void initState() {


    currentUser = widget.user;
    category.value = widget.category.toLowerCase();
    position.value = widget.position;
    WalletRepo.getWallet(currentUser.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
    locStream = getPositionStream(
    desiredAccuracy: LocationAccuracy.bestForNavigation,
    timeInterval: 180000).listen((Position cLoc)
    {
    position.value =cLoc;
    });

    super.initState();
  }

  @override
  void dispose() {
    locStream?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
      child: Scaffold(
        resizeToAvoidBottomPadding : false,
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
              Get.height *
                  0.22),
          child: AppBar(
              title: Text('Pocketshopping',style: TextStyle(color: PRIMARYCOLOR),),
              backgroundColor: Color.fromRGBO(255, 255, 255, 1),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.grey,
                ),
                onPressed: () {
                  Get.back();
                },
              ),
              elevation: 0.0,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(
                    Get.height *
                        0.15),
                child: Column(
                  children: [
                    Container(
                        child: TextFormField(
                          controller: null,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search Pocketshooping',
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
                          onChanged: (value) {
                            if(value.isNotEmpty)category.value = value.toLowerCase();
                            else category.value = widget.category.toLowerCase();
                          },
                        )

                    ),
                    TabBar(
                      labelColor: PRIMARYCOLOR,
                      tabs: [
                        Tab(
                          text: "Merchant(s)",
                        ),
                        Tab(
                          text: "Product(s)",
                        ),
                      ],
                    ),

                  ],
                )

              ),

          ),
        ),
        body: TabBarView(
          children: [
            ValueListenableBuilder(
              valueListenable: position,
              builder: (i, Position posit,ii){
                return ValueListenableBuilder(
                  valueListenable: category,
                  builder: (_,String categori,__){
                    return StreamBuilder(
                      stream: FenceRepo.nearByMerchants(posit, categori),
                      initialData: null,
                      builder: (context,AsyncSnapshot<List<Merchant>>snapShot){
                        if(snapShot.connectionState == ConnectionState.waiting){
                          return Center(
                            child: JumpingDotsProgressIndicator(
                              fontSize: Get.height * 0.12,
                              color: PRIMARYCOLOR,
                            ),
                          );
                        }
                        else if(snapShot.hasError){
                          return Center(
                              child: Column(
                                children: [
                                  Center(
                                    child: Image.asset('assets/images/gpsError.png',
                                      height:Get.height*0.3,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                                    child:  Text('Error Fetching Merchant ensure your GPS is '
                                        'enabled and full permission is granted to pocketshopping and check you internet connection.',
                                      style: TextStyle(color: Colors.black54),
                                      textAlign: TextAlign.center,),
                                  ),
                                  const SizedBox(height: 10,),
                                  FlatButton.icon(
                                    onPressed: (){  },
                                    color: PRIMARYCOLOR,
                                    icon: Icon(Icons.refresh,color: Colors.white,),
                                    label: Text('Refresh',style: TextStyle(color: Colors.white),),
                                  ),
                                ],
                              )
                          );
                        }
                        else{
                          if(snapShot.data != null){
                            if(snapShot.data.isNotEmpty){
                              return ListView.builder(
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                      padding: EdgeInsets.symmetric(horizontal:10,vertical: 5),
                                      width: Get.width*0.5,
                                      child: PlaceWidget(
                                        merchant: snapShot.data[index],
                                        cPosition: GeoFirePoint(
                                            posit.latitude,
                                            posit.longitude),
                                        user: currentUser.user,
                                      )
                                  );
                                },
                                itemCount: snapShot.data.length,
                              );
                            }
                            else{
                              return Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image.asset('assets/images/emptyPlace.png'),
                                    Text(
                                      'No $categori within a 50km radius',
                                      style: TextStyle(color: Colors.black54),
                                    )
                                  ],
                                ),
                              );
                            }
                          }
                          else{
                            return Center(
                              child: JumpingDotsProgressIndicator(
                                fontSize: Get.height * 0.12,
                                color: PRIMARYCOLOR,
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: position,
              builder: (i, Position posit,ii){
                return ValueListenableBuilder(
                  valueListenable: category,
                  builder: (_,String categori,__){
                    return StreamBuilder(
                      stream: FenceRepo.nearByProduct(posit, categori),
                      initialData: null,
                      builder: (context,AsyncSnapshot<List<Product>>snapShot){
                        if(snapShot.connectionState == ConnectionState.waiting){
                          return Center(
                            child: JumpingDotsProgressIndicator(
                              fontSize: Get.height * 0.12,
                              color: PRIMARYCOLOR,
                            ),
                          );
                        }
                        else if(snapShot.hasError){
                          return Center(
                              child: Column(
                                children: [
                                  Center(
                                    child: Image.asset('assets/images/gpsError.png',
                                      height:Get.height*0.3,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                                    child:  Text('Error Fetching product ensure your GPS is '
                                        'enabled and full permission is granted to pocketshopping and check you internet connection.',
                                      style: TextStyle(color: Colors.black54),
                                      textAlign: TextAlign.center,),
                                  ),
                                  const SizedBox(height: 10,),
                                  FlatButton.icon(
                                    onPressed: (){  },
                                    color: PRIMARYCOLOR,
                                    icon: Icon(Icons.refresh,color: Colors.white,),
                                    label: Text('Refresh',style: TextStyle(color: Colors.white),),
                                  ),
                                ],
                              )
                          );
                        }
                        else{
                          if(snapShot.data != null){
                            if(snapShot.data.isNotEmpty){
                              return ListView.builder(
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                      padding: EdgeInsets.symmetric(vertical: 5),
                                      //width: Get.width*0.5,
                                      child: OneProduct(product: snapShot.data[index],user: widget.user.user,position: posit,
                                        distance: 1.0,)
                                  );
                                },
                                itemCount: snapShot.data.length,
                              );
                            }
                            else{
                              return Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image.asset('assets/images/emptyPlace.png'),
                                    Text(
                                      'No product within a 50km radius',
                                      style: TextStyle(color: Colors.black54),
                                    )
                                  ],
                                ),
                              );
                            }
                          }
                          else{
                            return Center(
                              child: JumpingDotsProgressIndicator(
                                fontSize: Get.height * 0.12,
                                color: PRIMARYCOLOR,
                              ),
                            );
                          }

                        }
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
    )
    );
  }

//@override
//void dispose() {
//context.bloc().close();
//super.dispose();
//}


}

class OneProduct extends StatelessWidget{
  final Product product;
  final User user;
  final Position position;
  final double distance;
  OneProduct({this.product,this.user,this.position,this.distance});
  
  @override
  Widget build(BuildContext context) {
    double height = Get.height;
    return FutureBuilder(
        future: MerchantRepo.getMerchant(product.mID.id),
    builder: (context,AsyncSnapshot<Merchant>merchant){
          return Container(
      //height: height*0.22,
      margin: EdgeInsets.only(
          //bottom: height * 0.02,
          left: height * 0.02,
          right: height * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        /*borderRadius: BorderRadius.only(
          topRight: Radius.circular(30.0),
          bottomLeft: Radius.circular(30.0),
        ),*/
        border:
        Border.all(color: Colors.grey.withOpacity(0.4), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            //offset: Offset(1.0, 0), //(x,y)
            blurRadius: 4.0,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.topRight,
                  colors: [Colors.black, Colors.transparent],
                ).createShader(
                    Rect.fromLTRB(0, 0, rect.width, rect.height));
              },
              blendMode: BlendMode.dstIn,
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: product.pPhoto.length > 0
                    ? product.pPhoto[0]
                    : 'https://i.pinimg.com/originals/85/8d/b9/858db9330ae2c94a28a6a99fcd07f85c.jpg',
                fit: BoxFit.cover,
                height: height * 0.2,
              ),
            )
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 10),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      product.pName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      '$CURRENCY ${product.pPrice}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                 if(merchant.hasData)
                 if(merchant.data != null)Text(merchant.data.bName),
                 if(product.isManaging)
                 if(product.pStockCount <= 0)
                   Row(
                     children: [
                       Expanded(
                           child: Center(
                               child: Text('Out of Stock',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey),)
                           )
                       )
                     ],
                   )
                 else
                   Row(
                     children: <Widget>[
                       Expanded(
                         child: FlatButton(
                           color: Colors.grey.withOpacity(0.2),
                           
                           onPressed: () {
                             if(merchant.data.bStatus == 1 && Utility.isOperational(merchant.data.bOpen, merchant.data.bClose)) {
                               Get.bottomSheet(
                                  OrderUI(
                                   merchant: merchant.data,
                                   payload: product,
                                   user: user,
                                   distance: GeoFirePoint(
                                       position.latitude,
                                       position.longitude).
                                   distance(lat: merchant.data.bGeoPoint['geopoint'].latitude, lng: merchant.data.bGeoPoint['geopoint'].longitude),
                                   initPosition: position,
                                 ),
                                 isScrollControlled: true,

                               );
                             }
                             else{
                               Utility.infoDialogMaker('Currently Unavailable',title: '${merchant.data.bName}');
                             }

                           },
                           child: Text(
                             "Order Now",
                             style: TextStyle(
                                 fontWeight: FontWeight.bold,
                                 color: PRIMARYCOLOR),
                           ),
                         ),
                       ),
                     ],
                   )
                 else
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: FlatButton(
                          color: PRIMARYCOLOR,
                          onPressed: () {
                          if(merchant.data.bStatus == 1 && Utility.isOperational(merchant.data.bOpen, merchant.data.bClose)) {
                            Get.bottomSheet(
                               OrderUI(
                                merchant: merchant.data,
                                payload: product,
                                user: user,
                                distance: GeoFirePoint(
                                    position.latitude,
                                    position.longitude).
                                distance(lat: merchant.data.bGeoPoint['geopoint'].latitude, lng: merchant.data.bGeoPoint['geopoint'].longitude),
                                initPosition: position,
                              ),
                              isScrollControlled: true,

                            );
                          }
                          else{
                            Utility.infoDialogMaker('Currently Unavailable',title: '${merchant.data.bName}');
                          }

                          },
                          child: Text(
                            "Order Now",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
          }
    );
  }
}