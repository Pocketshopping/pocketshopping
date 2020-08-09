

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/connectivity/bloc/connectivityBloc.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/withdrawal/repository/withdrawalObj.dart';
import 'package:recase/recase.dart';
import 'package:http/http.dart' as http;

class ServerRepo {
  static final databaseReference = Firestore.instance;

  static Future<Map<String,dynamic>> get() async {


    try{
      var doc = await databaseReference.collection("server").document('wallet').get(source: Source.server)
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){ throw Exception;});
      return doc.data;
    }
    catch(_){
      return {'key':''};
    }
  }
}

