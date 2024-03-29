import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/geofence/package_geofence.dart';
import 'package:pocketshopping/src/review/repository/ReviewRepo.dart';
import 'package:pocketshopping/src/review/repository/rating.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceWidget extends StatefulWidget {
  PlaceWidget({this.merchant, this.user, this.cPosition});

  final Merchant merchant;
  final GeoFirePoint cPosition;
  final User user;

  @override
  State<StatefulWidget> createState() => _PlaceWidgetState();
}

class _PlaceWidgetState extends State<PlaceWidget> {
  //Position cPosition;

  double dist;
  @override
  void initState() {
    dist = widget.cPosition.distance(lat: widget.merchant.bGeoPoint['geopoint'].latitude, lng: widget.merchant.bGeoPoint['geopoint'].longitude);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    //address();
    return Builder(builder: (context) {
      return GestureDetector(
        onTap: () {
          if(widget.merchant.bStatus == 1 && Utility.isOperational(widget.merchant.bOpen, widget.merchant.bClose)) {
            final page = MerchantUI(
              merchant: widget.merchant,
              user: widget.user,
              distance: dist,
              initPosition: Position(
                  latitude: widget.cPosition.latitude,
                  longitude: widget.cPosition.longitude),
            );
            Get.to(page);
          }
          else{
            Utility.infoDialogMaker('${widget.merchant.bName} is currently Unavailable',title: '');
          }
        },
        child: Container(
          //height: 180,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                //offset: Offset(1.0, 0), //(x,y)
                blurRadius: 6.0,
              ),
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1.0),
          ),
          //margin: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                flex: 1,
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
                    image: widget.merchant.bPhoto.isNotEmpty ? widget.merchant.bPhoto : PocketShoppingDefaultCover,
                    fit: BoxFit.cover,
                    height: Get.height * 0.2,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topCenter,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Center(
                                  child: Text(
                                    widget.merchant.bCategory,
                                    style: TextStyle(fontSize: 12, color: Colors.black54),
                                    textAlign: TextAlign.left,
                                  )),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            widget.merchant.bName,
                            style: TextStyle(
                                color: PRIMARYCOLOR,fontSize: 16, fontWeight: FontWeight.bold),textAlign: TextAlign.center,
                          ),
                          FutureBuilder(
                            future: ReviewRepo.getRating(widget.merchant.mID),
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
                          Text('${awayFrom(dist)}', style: TextStyle(fontSize: 12, color: Colors.black54),),
                          const SizedBox(height: 5,),
                          Text('${widget.merchant.bAddress}', style: TextStyle(fontSize: 12, color: Colors.black54),textAlign: TextAlign.center,),
                          if (widget.merchant.bStatus == 0 || !Utility.isOperational(widget.merchant.bOpen, widget.merchant.bClose))
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[Text('Unavailable', style: TextStyle(fontSize: 14, color: Colors.black54))],
                            ),
                        ],
                      ),
                    ],
                  ),
                )
              ),
              Expanded(
                flex: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: widget.cPosition != null
                          ? IconButton(
                        icon: Icon(
                          Icons.place,
                          color: Colors.grey,
                          size: 20,
                        ),
                        tooltip: 'View Map and get Direction',
                        onPressed: () {
                          //Navigator.of(context).pushNamed(MerchantMap.tag);
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return BottomSheetMapTemplate(
                                source: LatLng(widget.cPosition.latitude, widget.cPosition.longitude),
                                destination: LatLng(widget.merchant.bGeoPoint['geopoint'].latitude, widget.merchant.bGeoPoint['geopoint'].longitude,),
                                destAddress: widget.merchant.bAddress,
                                destName: widget.merchant.bName,
                                destPhoto: widget.merchant.bPhoto,
                                sourceName: widget.user.fname,
                                sourceAddress: widget.user.defaultAddress,
                                sourcePhoto: widget.user.profile,
                              );
                            },
                            enableDrag: false,
                            isDismissible: false,
                            isScrollControlled: true,
                          );
                        },
                      ) : Container(),
                    ),
                    Center(
                      child: IconButton(
                        icon: Icon(
                          Icons.call,
                          color: Colors.grey,
                          size: 20,
                        ),
                        tooltip: 'Click to call',
                        onPressed: () => launch("tel:${widget.merchant.bTelephone}"),
                      )
                    )
                  ],
                ),
              )
            ],
          )
        ),
      );
    });
  }

  String awayFrom(double dist) {
    if (dist > 1)
      return '$dist   kilometer(s)';
    else
      return '${dist * 1000} meter(s)';
  }
}
