import 'dart:io';
import 'dart:math';
import 'package:pocketshopping/component/dynamicLinks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/order/repository/order.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:geoflutterfire/geoflutterfire.dart';


class OrderRepo {


  final databaseReference = Firestore.instance;

  Future<String> save(Order order) async{
    DocumentReference bid;
    bid = await databaseReference.collection("orders")
        .add(order.toMap());

    return bid.documentID;


  }

}