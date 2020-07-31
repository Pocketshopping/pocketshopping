import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:location/location.dart';
import 'package:pocketshopping/src/ui/constant/ui_constants.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:workmanager/workmanager.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
class Utility {
  static var location = Location();
  static final  FirebaseMessaging _fcm = FirebaseMessaging();
  static const platform = const MethodChannel('fleepage.pocketshopping');
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

  static String directionMapStyles = '''[
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
    var otime = DateTime.parse((dtime).toDate().toString())
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
    ).timeout(
      Duration(seconds: TIMEOUT),
      onTimeout: () {
        return null;
      },
    );
    if(response !=null)
    if (response.statusCode == 200) {
      return response;
    } else {
      return null;
    }
    else
      return null;
  }

  static Future<dynamic> walletTransfer({String to, String from,int amount,int channelId}) async {
    print({'to:$to from:$from amount:${(amount*1.0)} channelid:$channelId'});
    final response = await http.post("${WALLETAPI}wallets/transfer/wallet",
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          <String, dynamic>{
            "amount":(amount*1.0),
            "channel": channelId,
            "from": "$from",
            "to": "$to",
          },
        )).timeout(
      Duration(seconds: TIMEOUT),
      onTimeout: () {
        return null;
      },
    );
    if(response != null)
      {
        print(response.statusCode);
        print(response.body);
        if (response.statusCode == 200) {return true;}
        else {return false;}
      }
    else
      return false;
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
            "statusId": Status,
            "amount":(Amount/100).round(),
            "paymentId": 1,
            "channelId": PaymentMethod,
            "from": "$From",
            "to": "$PocketDefaultWallet",
          },
        )).timeout(
      Duration(seconds: TIMEOUT),
      onTimeout: () {
        return null;
      },
    );
    if(response != null)
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      return result['Message'].toString();
    } else {
      return null;
    }
    else
      return null;
  }

  static Future<dynamic> initializePay({
      String referenceID, String from, String to, int status=4,int amount,int paymentMethod=4,
      int channelId,int deliveryFee,String state='Abuja'}) async {
    Map<String, dynamic> data = {
      "amount": amount,
      "from": from,
      "to": to,
      "channelId": channelId,
      "paymentId": paymentMethod,
      "statusId": status,
      "refID": referenceID,
      "deliveryfee": deliveryFee,
      'state':state
    };
    final response = await http.post("${WALLETAPI}wallets/pay/initiate/",
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          data
        )).timeout(
      Duration(seconds: TIMEOUT),
      onTimeout: () {
        return null;
      },
    );

    if(response != null)
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      return result['id'].toString();
    } else {
      return null;
    }
    else
      return null;
  }

  static Future<dynamic> agentAccept({String collectionID, String to, bool status=true,String agent,}) async {
    Map<String, dynamic> data = {
      "to": to,
      "agentID": agent,
      "status": status,
      "collectionID": collectionID,
      "logistics": to
    };
    final response = await http.post("${WALLETAPI}wallets/pay/agent/accept",
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
            data
        )).timeout(
      Duration(seconds: TIMEOUT),
      onTimeout: () {
        return null;
      },
    );

    if(response != null)
      if (response.statusCode == 200) {

        return true;
      } else {
        return null;
      }
    else
      return null;
  }

  static Future<dynamic> initializePosPay({
     String from, String to, int status=4,int amount,int paymentMethod=2,
    int channelId=2,String agent }) async {
    Map<String, dynamic> data = {
      "amount": amount,
      "from": from,
      "to": to,
      "agentID": agent,
      "channelId": channelId,
      "paymentId": paymentMethod,
      "statusId": status,
    };
    final response = await http.post("${WALLETAPI}wallets/pay/pos/initiate/",
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
            data
        )).timeout(
      Duration(seconds: TIMEOUT),
      onTimeout: () {
        return null;
      },
    );
    if(response != null){
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      return result['id'].toString();
    } else {
      return null;
    }}
    else{
      return null;
    }
  }

  static Future<dynamic> finalizePosPay({String collectionID, bool isSuccessful=true }) async {
    final response = await http.post("${WALLETAPI}wallets/pay/pos/finalize/",
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          <String, dynamic>{
            "collectionID": collectionID,
            "status": isSuccessful,
          },
        )).timeout(
      Duration(seconds: TIMEOUT),
      onTimeout: () {
        return null;
      },
    );
    if(response != null)
    if (response.statusCode == 200) {
      return true;
    } else {
      return null;
    }
    return null;
  }

  static Future<dynamic> finalizePay({String collectionID, bool isSuccessful=true }) async {
    final response = await http.post("${WALLETAPI}wallets/pay/finalize/",
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          <String, dynamic>{
            "collectionID": collectionID,
            "status": isSuccessful,
          },
        )).timeout(
      Duration(seconds: TIMEOUT),
      onTimeout: () {
        return null;
      },
    );
    if(response != null)
    if (response.statusCode == 200) {
      return true;
    } else {
      return null;
    }
    return null;
  }

  static Future<dynamic> updateWallet({String uid, String cid,int type }) async {
    final response = await http.post("${WALLETAPI}wallets/update",
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          <String, dynamic>{
            "walletID": uid,
            "companyID": cid,
            "typeId":type
          },
        )).timeout(
      Duration(seconds: TIMEOUT),
      onTimeout: () {
        return null;
      },
    );
    if(response != null)
    if (response.statusCode == 200) {
      return true;
    } else {
      return null;
    }
    else
      return null;
  }

  static Future<bool> updateWalletAccount({String wid, String accountNumber,String sortCode,String bankName }) async {
    final response = await http.post("${WALLETAPI}wallets/updatebank",
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          <String, dynamic>{
            "walletID": wid,
            "accountNumber": accountNumber,
            "sortCode":sortCode,
            "bankName":bankName
          },
        )).timeout(
      Duration(seconds: TIMEOUT),
      onTimeout: () {
        return null;
      },
    );
    if(response != null)
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    else
      return false;
  }

  static Future<bool> withdrawFunds({String wid, int type=1 }) async {
    final response = await http.post("${WALLETAPI}Withdraw",
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          <String, dynamic>{
            "walletID": wid,
            "type": type,
          },
        )).timeout(
      Duration(seconds: TIMEOUT),
      onTimeout: () {
        return null;
      },
    );
    if(response != null)
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    else
      return false;
  }

  static Future<bool> clearRemittance(String rid) async {
    final response = await http.get("${WALLETAPI}remittance/update/clear?id=$rid").timeout(
      Duration(seconds: TIMEOUT),
      onTimeout: () {
        return null;
      },
    );
    if(response != null)
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
    else
      return null;
  }



  static Future<Map<String,dynamic>> generateRemittance({String aid, int limit}) async {
    final response = await http.get("${WALLETAPI}collection/cash/agent/remittance?id=$aid&limit=$limit").timeout(
      Duration(seconds: TIMEOUT),
      onTimeout: () {
        return null;
      },
    );
    if(response != null)
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      return result;
    } else {
      return null;
    }
    else
      return null;
  }

  static Future<dynamic> topUpUnit(
      String referenceID, String from, String description, int status,int amount,int paymentMethod) async {
    assert(referenceID != null);
    final response = await http.post("${WALLETAPI}wallets/fund/",
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          <String, dynamic>{
            "refID": "$referenceID",
            "statusId": status,
            "amount":(amount/100).round(),
            "paymentId": 5,
            "channelId": paymentMethod,
            "from": "$from",
            "to": "$PocketDefaultWallet",
          },
        )).timeout(
      Duration(seconds: TIMEOUT),
      onTimeout: () {
        return null;
      },
    );
    if(response != null)
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      return result['Message'].toString();
    } else {
      return null;
    }
    else
      return null;
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
      importance: Importance.Default,
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

  static String numberFormatter(int number){
    if(number > 1000 && number < 1000000)
      return '${(number/1000).toStringAsFixed(1)}K';
    else if(number > 1000000 && number < 1000000000)
      return '${(number/1000000).toStringAsFixed(1)}M';
    else if(number > 1000000000)
      return '${(number/1000000000).toStringAsFixed(1)}B';
    else
      return '$number';
  }

  static Future<void> noWorker(){
    Workmanager.cancelAll();
    return Future.value();
  }

  static bool isOperational(String openTime,String closeTime){
    var open = openTime.split(":");
    var close = closeTime.split(":");
    DateTime opened = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,int.tryParse(open[0])??0,int.tryParse(open[1])??0);
    DateTime closed = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,int.tryParse(close[0])??0,int.tryParse(close[1])??0);
    DateTime now = DateTime.now();
    return now.isAfter(opened) && now.isBefore(closed);
  }

 static Future<String> address(Position position) async {
    final coordinates = Coordinates(position.latitude, position.longitude);
    var address = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var generatedAddress='';
    List<String> temp = address.first.addressLine.split(',');
    temp.removeLast();
    temp.removeLast();
    generatedAddress = temp.reduce((value, element) => value + ',' + element);
    return generatedAddress;
  }


  static Future<String> getState(Position position) async {
    final coordinates = Coordinates(position.latitude, position.longitude);
    var address = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var state='';
    List<String> temp = address.first.addressLine.split(',');
    if(temp.length>2){
      temp.removeLast();
      state = temp.last;
    }
    else{
      state = address.first.adminArea;
    }
    return state;
  }

  static Future<String> getCountryCode(Position position) async {
    final coordinates = Coordinates(position.latitude, position.longitude);
    var address = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    return address.first.countryCode;
  }

  static bottomProgressLoader({String title='Loading', String body='...please wait',bool goBack=false}){
    if(!Get.isSnackbarOpen)
    GetBar(
      title: title,
      messageText: Text(body,style: TextStyle(color: Colors.white),),
      backgroundColor: PRIMARYCOLOR,
      showProgressIndicator: true,
      progressIndicatorValueColor:new AlwaysStoppedAnimation<Color>(Colors.white),
      duration: Duration(days: 365),
    ).show().then((value) {
      if(goBack)
        Get.back();
    });
  }

  static bottomProgressSuccess({String title='Loading', String body='...please wait',int duration=3,bool goBack=false, String wallet=''}){
    if(!Get.isSnackbarOpen)
    GetBar(
      title: title,
      messageText: Text(body??'',style: TextStyle(color: Colors.white),),
      backgroundColor: PRIMARYCOLOR,
      icon: Icon(Icons.check,color: Colors.white,),
      duration: Duration(seconds: duration),
    ).show().then((value) {
      if(goBack)
        Get.back();
      if(wallet.isNotEmpty)
        WalletRepo.getWallet(wallet).then((value) => WalletBloc.instance.newWallet(value));
    });

  }

  static bottomProgressFailure({String title='Loading', String body='...please wait',int duration=3}){
    if(!Get.isSnackbarOpen)
    GetBar(
      title: title,
      messageText: Text(body,style: TextStyle(color: Colors.white),),
      backgroundColor: Colors.red,
      icon: Icon(Icons.check,color: Colors.white,),
      duration: Duration(seconds: duration),
    ).show();
  }

  static noInternet(){
    if(!Get.isSnackbarOpen)
    GetBar(
      title: 'Internet',
      messageText: Text("No internet connection",style: TextStyle(color: Colors.white),),
      backgroundColor: PRIMARYCOLOR,
      icon: Icon(Icons.check,color: Colors.white,),
      duration: Duration(seconds: 5),
    ).show();
  }

  static infoDialogMaker(String body,{String title='Info',}){
    if(!Get.isDialogOpen)
    Get.defaultDialog(title:title,
        content: Text(body),
        confirm: FlatButton(
          onPressed: (){Get.back();},
          child: Text('Ok'),
        )
    );
  }

  static Future<bool> confirmDialogMaker(String body,{String title='Confirm',})async{
    bool isConfirmed=false;
    if(!Get.isDialogOpen)
   await  Get.defaultDialog(title:title,
        content: Text(body),
        cancel: FlatButton(
          onPressed: (){
            isConfirmed = false;
            Get.back();
            },
          child: Text('No'),
        ),
        confirm: FlatButton(
          onPressed: (){
            isConfirmed = true;
            Get.back();
            },
          child: Text('Yes'),
        )
    );
    return isConfirmed;
  }

 static double sum(List<dynamic> items) {
    double sum = 0;
    items.forEach((element) {
      sum += element.total;
    });
    return sum;
  }

  static Future<void> _requestPusher(String fcm) async {
    //print('team meeting');
    await _fcm.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: false),
    );
    await http.post('https://fcm.googleapis.com/fcm/send',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken'
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'body':  'You have a request to attend to click for more information',
            'title': 'Request'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'payload': {
              'NotificationType': 'WorkRequestResponse',
            }
          },
          'to': fcm,
        }));
  }

  static Future<void> pushMessage({String fcm,String body, String title, String notificationType="",Map<String,dynamic>data}) async {
    await _fcm.requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false),);
    await http.post('https://fcm.googleapis.com/fcm/send',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken'
        },
        body: jsonEncode(<String, dynamic>{
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'payload': {
              'NotificationType': '$notificationType',
              'message':'$body',
              'title':'$title',
              'data':data,
            }
          },
          'to': fcm,
        }));
  }

  static Future<void> pushNotifier({String fcm,String body, String title, String notificationType="",Map<String,dynamic>data}) async {
    await _fcm.requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false),);
    await http.post('https://fcm.googleapis.com/fcm/send',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken'
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'body':  '$body',
            'title': '$title',
            "icon" : "app_icon",
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'payload': {
              'NotificationType': '$notificationType',
              'message':'$body',
              'title':'$title',
              'data':data,
            }
          },
          'to': fcm,
        }));
  }

  static Future<void> pushGroupNotifier({List<String> fcm,String body, String title, String notificationType="",Map<String,dynamic>data}) async {
    await _fcm.requestNotificationPermissions(const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false),);
    await http.post('https://fcm.googleapis.com/fcm/send',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken'
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'body':  '$body',
            'title': '$title',
            "icon" : "app_icon",
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'payload': {
              'NotificationType': '$notificationType',
              'message':'$body',
              'title':'$title',
              'data':data,
            }
          },
          'registration_ids': fcm,
        }));
  }

  static double zoomer(int distance){

    if(distance < 10)
      return 12.0;
    else if(distance > 10 && distance < 20)
      return 11.0;
    else if(distance > 20 && distance < 30)
      return 10.0;
    else if(distance > 30)
      return 9.0;
    else
      return 13.0;
  }


  static LatLng computeCentroid(List<LatLng> points) {
    double latitude = 0;
    double longitude = 0;
    int n = points.length;

    points.forEach((point) {
      latitude += point.latitude;
      longitude += point.longitude;
    });

    return new LatLng(latitude/n, longitude/n);
  }

  static Future<void> stopAllService()async{
    try{
      await AndroidAlarmManager.cancel(requestWorkerID);
      await Workmanager.cancelAll();
    }catch(_){}

  }
  static List<String> rangeOf30Days(){
    DateTime thirty = DateTime.now().subtract(Duration(days: 29));
    String start = '${thirty.day}-${thirty.month}-${thirty.year}';
    List<String> days = [];

    DateTime changing = DateTime.now();
    String current = '${changing.day}-${changing.month}-${changing.year}';

    while(start != current){
      days.add(current);

      changing = changing.subtract(Duration(days: 1));
      current = '${changing.day}-${changing.month}-${changing.year}';
    }

    days.add(start);
    return days.reversed.toList();

  }

  static int multiListSum(List<List<dynamic>> data){
    int sum=0;
    data.forEach((element) {
      sum += (element[1] as int);
    });
    return sum;
  }

}
