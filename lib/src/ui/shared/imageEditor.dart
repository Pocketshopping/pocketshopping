import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_crop/image_crop.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';


class Editor extends StatelessWidget{

  Editor({this.imageFile,this.callbvck});

  final Function callbvck;
  final  dynamic imageFile;
  final cropKey = GlobalKey<CropState>();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
        onWillPop: ()async{
          return true;
        },
        child:Scaffold(
          appBar: AppBar(
            backgroundColor: PRIMARYCOLOR,
            title: Text('Editor'),
            actions: [
              IconButton(
                onPressed: ()async{
                  final crop = cropKey.currentState;
                  final scale = crop.scale;
                  final area = crop.area;

                  if (area != null) {

                    final croppedFile = await ImageCrop.cropImage(
                      file: imageFile,
                      area: crop.area,
                    );
                    callbvck(croppedFile);
                  }
                  Get.back();
                },
                icon: Icon(Icons.check,color: Colors.white,),
              )
            ],
          ),
          body: Container(
            color: Colors.black,
            padding: const EdgeInsets.all(20.0),
            child: Crop(
              key: cropKey,
              image: FileImage(imageFile),
              aspectRatio: 4.0 / 3.0,
            ),
          ),
        )
    );
  }
}
