import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';

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
}
