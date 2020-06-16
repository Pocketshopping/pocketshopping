import 'package:flutter/material.dart';
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
import 'package:pocketshopping/src/utility/utility.dart';

class SinglePlaceWidget extends StatelessWidget {
  SinglePlaceWidget({this.merchant, this.user, this.cPosition});

  final Merchant merchant;
  final GeoFirePoint cPosition;
  final User user;
  //double dist=0.0;

  place() async {
    List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(
        cPosition.geoPoint.latitude, cPosition.geoPoint.longitude,
        localeIdentifier: 'en');
    print(placemark[0]);
  }

  address() async {
    final coordinates = new geocode.Coordinates(
        cPosition.geoPoint.latitude,
        cPosition.geoPoint.longitude);
    var address = await geocode.Geocoder.local.findAddressesFromCoordinates(coordinates);
    print(address.first.addressLine);
  }

  @override
  Widget build(BuildContext context) {

    double dist = cPosition.distance(
        lat: merchant.bGeoPoint['geopoint'].latitude,
        lng: merchant.bGeoPoint['geopoint'].longitude);


      return GestureDetector(
        onTap: () {
          if(merchant.bStatus == 1 && Utility.isOperational(merchant.bOpen, merchant.bClose)) {
            final page = MerchantUI(
              merchant: merchant,
              user: user,
              distance: dist,
              initPosition: Position(
                  latitude: cPosition.latitude,
                  longitude: cPosition.longitude),
            );
            Get.to(page);
          }
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
              image: NetworkImage(merchant.bPhoto.isNotEmpty
                  ? merchant.bPhoto
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
                        merchant.bCategory,
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                        textAlign: TextAlign.left,
                      )),
                    ),
                    Expanded(
                      child: cPosition != null
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
                                      source: LatLng(cPosition.latitude,
                                          cPosition.longitude),
                                      destination: LatLng(
                                        merchant.bGeoPoint['geopoint']
                                            .latitude,
                                        merchant.bGeoPoint['geopoint']
                                            .longitude,
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
                            )
                          : const SizedBox.shrink(),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: const Icon(
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
              const SizedBox(height: 15,),
              Column(
                children: <Widget>[
                  Text(
                    merchant.bName,
                    style: TextStyle(
                        color: Colors.white,fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${awayFrom(dist)}',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  if (merchant.bStatus == 0 || !Utility.isOperational(merchant.bOpen, merchant.bClose))
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[Text('Unavailable', style: TextStyle(fontSize: 14, color: Colors.white))],
                    ),
                ],
              ),
            ],
          ),
        ),
      );

  }

  String awayFrom(double dist) {
    if (dist > 1)
      return '$dist   km away';
    else
      return '${dist * 1000} m away';
  }
}
