import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:pocketshopping/src/ui/constant/ui_constants.dart';
import 'package:http/http.dart' as http;

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
}
