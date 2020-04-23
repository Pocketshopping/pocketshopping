import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pocketshopping/src/ui/shared/shared.dart';

class BottomSheetMapTemplate extends StatelessWidget{

  BottomSheetMapTemplate({
    @required this.source,
    @required this.destination,
    this.destAddress,
    this.destName,
    this.destPhoto,
    this.sourceName,
    this.sourcePhoto,
    this.sourceAddress
  });
  final LatLng source;
  final LatLng destination;
  final String destName;
  final String destAddress;
  final String destPhoto;
  final String sourceName;
  final String sourcePhoto;
  final String sourceAddress;

  @override
  Widget build(BuildContext context) {
    return BottomSheetTemplate(
      color: Color.fromRGBO(239, 238, 236, 1),
      height: MediaQuery.of(context).size.height*0.8,
      child:Container(
        color:Colors.white,
        width:MediaQuery.of(context).size.width,
        height:MediaQuery.of(context).size.height*0.75,
        child:  MerchantMap(
          source: source,
          destination: destination,
          destAddress: destAddress,
          destName: destName,
          destPhoto: destPhoto,
          sourceName: sourceName,
          sourceAddress: sourceAddress,
          sourcePhoto: sourcePhoto,
        ),
      ),
    );

  }





}

