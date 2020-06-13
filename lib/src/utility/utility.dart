import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:location/location.dart';
import 'package:pocketshopping/src/ui/constant/ui_constants.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
class Utility {
  static var location = Location();
  static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "color": "#C3C3C3"
        
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';

  static locationAccess() {
    location.hasPermission().then((value) {
      if (value != PermissionStatus.granted) {
        location.requestPermission().then((value) {
          if (value == PermissionStatus.granted)
            enableLocation();
          else if (!Get.isDialogOpen)
            Get.defaultDialog(
                title: 'PERMISSION',
                content:
                    Text('Pocketshopping needs location access to operate'),
                cancel: FlatButton(
                  onPressed: () {
                    Get.back();
                    locationAccess();
                  },
                  child: Text('Ok'),
                ));
        });
      } else
        enableLocation();
    });
  }

  static enableLocation() {
    location.serviceEnabled().then((value) {
      if (!value)
        location.requestService().then((value) {
          if (!value) if (!Get.isDialogOpen)
            Get.defaultDialog(
                title: 'Location',
                content: Text(
                    'Please enable Location service to start using pocketshopping '),
                cancel: FlatButton(
                  onPressed: () {
                    Get.back();
                    enableLocation();
                  },
                  child: Text('Ok'),
                ));
        });
    });
  }

  static int setStartCount(dynamic dtime, int second) {
    //print(dtime);
    var otime = DateTime.parse((dtime as Timestamp).toDate().toString())
        .add(Duration(seconds: second));
    int diff = otime.difference(DateTime.now()).inSeconds;
    if (diff > 0)
      return diff;
    else
      return 0;
  }

  static Future<http.Response> fetchPaymentDetail(String ref) async {
    final response = await http.get(
      'https://api.paystack.co/transaction/verify/$ref',
      headers: {
        "Accept": "application/json",
        "Authorization": PAYSTACK
      },
    );
    if (response.statusCode == 200) {
      return response;
    } else {
      return null;
    }
  }

  static Future<dynamic> topUpWallet(
      String ReferenceID, String From, String Description, int Status,int Amount,int PaymentMethod) async {
    final response = await http.post("${WALLETAPI}wallets/fund/",
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          <String, dynamic>{
            "refID": "$ReferenceID",
            "statusId": "$Status",
            "amount":Amount,
            "paymentId": 1,
            "channelId": PaymentMethod,
            "from": "$From",
            "to": "304244166277",
          },
        ));
    //print(response.body);
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      return result['Message'].toString();
    } else {
      return null;
    }
  }


  static Future<dynamic> topUpUnit(
      String ReferenceID, String From, String Description, int Status,int Amount,int PaymentMethod) async {
    assert(ReferenceID != null);
    final response = await http.post("${WALLETAPI}wallets/fund/",
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          <String, dynamic>{
            "refID": "$ReferenceID",
            "statusId": "$Status",
            "amount":Amount,
            "paymentId": 5,
            "channelId": PaymentMethod,
            "from": "$From",
            "to": "304244166277",
          },
        ));
    //print(response.body);
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      return result['Message'].toString();
    } else {
      return null;
    }
  }

  static dynamic presentDate(dynamic datetime) {
    var result;
    bool yesterday = false;
    bool today = false;
    var date;
    var time;
    //if(DateTime.now().difference(datetime))
    result = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day - 1);
    yesterday = formatDate(
        DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day - 1),
        [dd, '/', mm, '/', yyyy]) ==
        formatDate(datetime, [dd, '/', mm, '/', yyyy]);
    today = formatDate(DateTime.now(), [dd, '/', mm, '/', yyyy]) ==
        formatDate(datetime, [dd, '/', mm, '/', yyyy]);
    date = formatDate(datetime, [d, ' ', M, ', ', yyyy]);
    time = formatDate(datetime, [HH, ':', nn, ' ', am]);
    if (today)
      return 'Today at $time';
    else if (yesterday)
      return 'Yesterday at $time';
    else
      return '$date at $time';
  }

  static localNotifier(String channelID,String channel,String title, String body)async{
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '$channelID', '$channel', '$channel',
      importance: Importance.Max,
      priority: Priority.High,
      ticker: 'ticker',
      icon: 'app_icon',
      ongoing: true,
      enableVibration: true,
      enableLights: true,
      playSound: true,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      '$title',
      '$body',
      platformChannelSpecifics,
      payload: '$channel',


    );
  }

  static Future<File> cropImage(File image) async {
    File temp;
    temp = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.ratio3x2,
        ],
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Editor',
          toolbarColor: PRIMARYCOLOR,
          toolbarWidgetColor: WHITECOLOR,
          initAspectRatio: CropAspectRatioPreset.original,
        ),
        iosUiSettings: IOSUiSettings(minimumAspectRatio: 1.0));
    return temp;
  }


  static Future<List<String>> uploadMultipleImages(List<File> _imageList,{String bucket='ProductPhoto'}) async {
    List<String> _imageUrls = List();

    try {
      for (int i = 0; i < _imageList.length; i++) {
        final StorageReference storageReference =
        FirebaseStorage().ref().child("$bucket/${DateTime.now().millisecondsSinceEpoch}.png");

        final StorageUploadTask uploadTask =
        storageReference.putFile(_imageList[i]);

        final StreamSubscription<StorageTaskEvent> streamSubscription =
        uploadTask.events.listen((event) {
          //print(event.toString());
        });

        // Cancel your subscription when done.
        await uploadTask.onComplete;
        streamSubscription.cancel();

        String imageUrl = await storageReference.getDownloadURL();
        _imageUrls.add(imageUrl); //all all the urls to the list
      }
      //upload the list of imageUrls to firebase as an array
      return _imageUrls;
    } catch (e) {
      //print(e);
      return [];
    }
  }

  static List<String> makeIndexList(String bName) {
    List<String> indexList = [];
    var temp = bName.split(' ');
    for (int i = 0; i < temp.length; i++) {
      for (int y = 1; y < temp[i].length + 1; y++) {
        indexList.add(temp[i].substring(0, y).toLowerCase());
      }
    }
    return indexList;
  }


  static bool dayMaker(dynamic datetime,String whichDay){
    bool yesterday = false;
    bool today = false;
    //if(DateTime.now().difference(datetime))
    yesterday = formatDate(
        DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day - 1),
        [dd, '/', mm, '/', yyyy]) ==
        formatDate(datetime, [dd, '/', mm, '/', yyyy]);
    today = formatDate(DateTime.now(), [dd, '/', mm, '/', yyyy]) ==
        formatDate(datetime, [dd, '/', mm, '/', yyyy]);

   switch(whichDay){
     case 'T':
       return today;
       break;
     case 'Y':
       return yesterday;
       break;
     default:
       return false;
     break;
   }
  }


}
