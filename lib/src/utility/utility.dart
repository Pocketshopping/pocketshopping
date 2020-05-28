import 'dart:async';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:pocketshopping/src/ui/constant/ui_constants.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
class Utility {
  static var location = Location();

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
    print(dtime);
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
      String ReferenceID, String To, String Description, String Status,int Amount,String PaymentMethod) async {
    final response = await http.post("${WALLETAPI}fund/wallet/online",
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          <String, dynamic>{
            "To": "$To",
            "ReferenceID": "$ReferenceID",
            "Description": "$Description",
            "Status": "$Status",
            "Amount":Amount,
            "PkCharge": 0.0,
            "Servicecharge": 0.0,
            "Comfirmedby": "",
            "PaymentMethod": "$PaymentMethod",
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
      String ReferenceID, String To, String Description, String Status,int Amount,String PaymentMethod) async {
    final response = await http.post("${WALLETAPI}fund/pocket/online",
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          <String, dynamic>{
            "To": "$To",
            "ReferenceID": "$ReferenceID",
            "Description": "$Description",
            "Status": "$Status",
            "Amount":Amount,
            "PkCharge": 0.0,
            "Servicecharge": 0.0,
            "Comfirmedby": "",
            "PaymentMethod": "$PaymentMethod",
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


  static Future<List<String>> uploadMultipleImages(List<File> _imageList) async {
    List<String> _imageUrls = List();

    try {
      for (int i = 0; i < _imageList.length; i++) {
        final StorageReference storageReference =
        FirebaseStorage().ref().child("ProductPhoto/${DateTime.now()}.png");

        final StorageUploadTask uploadTask =
        storageReference.putFile(_imageList[i]);

        final StreamSubscription<StorageTaskEvent> streamSubscription =
        uploadTask.events.listen((event) {
          print(event.toString());
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
      print(e);
      return [];
    }
  }
}
