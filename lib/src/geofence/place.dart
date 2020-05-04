import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geocoder/geocoder.dart' as geocode;
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pocketshopping/component/dialog.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/geofence/package_geofence.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';

class SinglePlaceWidget extends StatefulWidget {
  SinglePlaceWidget({this.merchant, this.user, this.cPosition});

  final Merchant merchant;
  final GeoFirePoint cPosition;
  final User user;

  @override
  State<StatefulWidget> createState() => _SinglePlaceWidgetUIState();
}

class _SinglePlaceWidgetUIState extends State<SinglePlaceWidget> {
  //Position cPosition;

  @override
  void initState() {
    super.initState();
  }

  place() async {
    List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(
        widget.cPosition.geoPoint.latitude, widget.cPosition.geoPoint.longitude,
        localeIdentifier: 'en');
    print(placemark[0]);
  }

  address() async {
    final coordinates = new geocode.Coordinates(
        widget.cPosition.geoPoint.latitude,
        widget.cPosition.geoPoint.longitude);
    var address =
        await geocode.Geocoder.local.findAddressesFromCoordinates(coordinates);
    print(address.first.addressLine);
  }

  @override
  Widget build(BuildContext context) {
    double dist = widget.cPosition.distance(
        lat: widget.merchant.bGeoPoint['geopoint'].latitude,
        lng: widget.merchant.bGeoPoint['geopoint'].longitude);
    //address();
    return Builder(builder: (context) {
      return GestureDetector(
        onTap: () {
          final page = MerchantUI(
            merchant: widget.merchant,
            user: widget.user,
            distance: dist,
            initPosition: Position(
                latitude: widget.cPosition.latitude,
                longitude: widget.cPosition.longitude),
          );
          Get.to(page);

          //Navigator.of(context).push(
          //MaterialPageRoute(
          //builder: (_) {
          //return BlocProvider.value(
          //value: BlocProvider.of<GeoFenceBloc>(context),
          //child: BlocProvider.value(
          //value: BlocProvider.of<UserBloc>(context),
          //child: page,
          //),
          //);
          //},
          //),
          //);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10.0),
                topLeft: Radius.circular(30.0),
                bottomLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(30.0)),
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
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,

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
                    Expanded(
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
                                      source: LatLng(widget.cPosition.latitude,
                                          widget.cPosition.longitude),
                                      destination: LatLng(
                                        widget.merchant.bGeoPoint['geopoint']
                                            .latitude,
                                        widget.merchant.bGeoPoint['geopoint']
                                            .longitude,
                                      ),
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
                          dialog(context, {
                            'title': 'info',
                          }).showInfo();
                        },
                      ),
                    )
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  Text(
                    widget.merchant.bName,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  RatingBar(
                    //onRatingUpdate: (rate){},
                    initialRating: 3.5,
                    minRating: 1,
                    maxRating: 5,
                    itemSize: MediaQuery.of(context).size.width * 0.04,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    ignoreGestures: true,
                    itemCount: 5,
                    //itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                  ),
                  Text(
                    '${AwayFrom(dist)}',
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
                            ? Icon(
                                Icons.close,
                                color: Colors.red,
                              )
                            : Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                        Text('Home Delivery',
                            style: TextStyle(fontSize: 14, color: Colors.white))
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

  String AwayFrom(double dist) {
    if (dist > 1)
      return '$dist   km away';
    else
      return '${dist * 1000} m away';
  }
}
