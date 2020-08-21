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

class ReviewPlaceWidget extends StatefulWidget {
  ReviewPlaceWidget({this.merchant, this.user, this.cPosition});

  final Merchant merchant;
  final GeoFirePoint cPosition;
  final User user;

  @override
  State<StatefulWidget> createState() => _SinglePlaceWidgetUIState();
}

class _SinglePlaceWidgetUIState extends State<ReviewPlaceWidget> {

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
            Utility.infoDialogMaker('Currently Unavailable',title: '${widget.merchant.bName}');
          }
        },
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                //offset: Offset(1.0, 0), //(x,y)
                blurRadius: 6.0,
              ),
            ],
            color: Colors.black,
            border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1.0),
            //color: Colors.white,
            image: DecorationImage(
              image: NetworkImage(widget.merchant.bPhoto.isNotEmpty
                  ? widget.merchant.bPhoto
                  : PocketShoppingDefaultCover),
              fit: BoxFit.cover,
              colorFilter: new ColorFilter.mode(
                  Colors.black.withOpacity(0.2), BlendMode.dstATop),
              //colorFilter: Colors.black.withOpacity(0.4),
            ),
          ),
          child: Column(
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
                            style: TextStyle(fontSize: 12, color: Colors.white),
                            textAlign: TextAlign.left,
                          )),
                    ),
                    /*Expanded(
                      child: widget.cPosition != null
                          ? IconButton(
                        icon: Icon(
                          Icons.place,
                          color: Colors.white,
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
                      )
                          : Container(),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: Icon(
                          Icons.info,
                          size: 20,
                          color: Colors.white,
                        ),
                        tooltip: 'Who we are',
                        onPressed: () {
                        },
                      ),
                    )*/
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  Text(widget.merchant.bName,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),textAlign: TextAlign.center
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
                              itemSize: MediaQuery.of(context).size.width * 0.05,
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
                              itemSize: MediaQuery.of(context).size.width * 0.05,
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
                            itemSize: MediaQuery.of(context).size.width * 0.05,
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

                  (widget.merchant.bStatus == 1 && Utility.isOperational(widget.merchant.bOpen, widget.merchant.bClose))?
                  Text(
                    '${awayFrom(dist)}',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ):Text(
                    'Unavailable',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  if (dist > 0.1)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        widget.merchant.bDelivery == 'No'
                            ? Text('Home Delivery', style: TextStyle(fontSize: 14, color: Colors.white))
                            :Container()
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  String awayFrom(double dist) {
    if (dist > 1)
      return '$dist   km away';
    else
      return '${dist * 1000} m away';
  }
}
