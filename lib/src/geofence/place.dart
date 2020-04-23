import 'package:flutter/material.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pocketshopping/component/dialog.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/geofence/package_geofence.dart';
import 'package:pocketshopping/src/business/business.dart';


class SinglePlaceWidget extends StatelessWidget {
  SinglePlaceWidget({this.merchant,this.user,this.cPosition});
  final Merchant merchant;
  final GeoFirePoint cPosition;
  final User user;

  @override
      Widget build(BuildContext context) {
    //print(' position ${BlocProvider.of<GeoFenceBloc>(context).state.currentPosition}');
        return
          GestureDetector(
            onTap: (){
              final page =  MerchantUI(merchant: merchant,);
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page));
        },
    child:
          Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10.0),
          topLeft: Radius.circular(30.0),
          bottomLeft: Radius.circular(10.0),
          bottomRight: Radius.circular(30.0)
        ),
        border: Border.all(
        color: Colors.grey.withOpacity(0.3), width: 1.0
        ),
        //color: Colors.white,
        image: DecorationImage(
          image: NetworkImage(merchant.bPhoto.isNotEmpty?merchant.bPhoto:PocketShoppingDefaultCover),
          fit: BoxFit.cover,
          colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
          //colorFilter: Colors.black.withOpacity(0.4),

        ),
        ),
      child:
         Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
                  child:  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceAround,

                    children:<Widget>[
                      Expanded(
                        flex:3,
                        child: Center(child:
                        Text(merchant.bCategory,style: TextStyle(fontSize:12,
                        color: Colors.white),
                          textAlign: TextAlign.left
                          ,)),
                      ),
                      Expanded(
                        child: cPosition != null ?IconButton(
                          icon:Icon(Icons.place,
                            color: Colors.white,size: 20,),
                          tooltip: 'View Map and get Direction',
                          onPressed: () {
                            //Navigator.of(context).pushNamed(MerchantMap.tag);
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return BottomSheetMapTemplate(
                                    source: LatLng(
                                        cPosition.latitude,
                                        cPosition.longitude),
                                    destination: LatLng(
                                        merchant.bGeoPoint['geopoint'].latitude,
                                        merchant.bGeoPoint['geopoint'].longitude,
                                    ),
                                    destAddress: merchant.bAddress,
                                    destName: merchant.bName,
                                    destPhoto: merchant.bPhoto,
                                    sourceName: user.fname,
                                    sourceAddress: user.defaultAddress,
                                    sourcePhoto: user.profile,
                                  );
                                },
                              enableDrag: false,
                              isDismissible: false,
                              isScrollControlled: true,
                            );
                          },
                        ):Container(),
                      ),

                      Expanded(
                        child: IconButton(
                          icon:Icon(Icons.info,size: 20,
                            color: Colors.white,),
                          tooltip: 'Who we are',
                          onPressed: () {
                            dialog(context,{'title':'info',}).showInfo();
                          },
                        ),
                      )

                    ],
                  ),
                ),

                 Column(
                    children: <Widget>[
                      Text(merchant.bName,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                      RatingBar(
                        onRatingUpdate: (rate){},
                        initialRating: 3.5,
                        minRating: 1,
                        maxRating: 5,
                        itemSize: MediaQuery.of(context).size.width*0.04,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        //itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                        itemBuilder: (context, _)=>Icon(Icons.star, color: Colors.amber,),

                      ),
                      Text('${AwayFrom()}',style: TextStyle(fontSize:12,color: Colors.white),),
                      FlatButton(
                        onPressed: () {
                          final page = MerchantUI(merchant: merchant,);
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => page,));
                        },
                        textColor: Colors.white,
                        child: Text(
                            'Check In',
                            style: TextStyle(fontSize: 14,color: Colors.white)


                        ),
                      ),
                    ],
                  ),

              ],
            ),


),

    );
      }


      String AwayFrom(){
        double dist =  cPosition.distance(lat: merchant.bGeoPoint['geopoint'].latitude,
        lng: merchant.bGeoPoint['geopoint'].longitude);

        if(dist > 1 )
          return '$dist   km away';
        else
          return '${dist*1000} m away';
      }
}