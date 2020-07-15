// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:pocketshopping/src/order/repository/confirmation.dart';
import 'package:pocketshopping/src/order/repository/customer.dart';
import 'package:pocketshopping/src/order/repository/errandObj.dart';
import 'package:pocketshopping/src/order/repository/orderItem.dart';
import 'package:pocketshopping/src/order/repository/orderMode.dart';
import 'package:pocketshopping/src/order/repository/receipt.dart';

class OrderEntity extends Equatable {
  final List<OrderItem> orderItem;
  final double orderAmount;
  final Customer orderCustomer;
  final String orderMerchant;
  final dynamic orderCreatedAt;
  final OrderMode orderMode;
  final int orderETA;
  final Receipt receipt;
  final int status;
  final String orderID;
  final String docID;
  final Confirmation orderConfirmation;
  final String customerID;
  final String agent;
  final String orderLogistic;
  final bool isAssigned;
  final String resolution;
  final List<String> potentials;
  final List<String> index;
  final String customerDevice;
  final ErrandObj errand;

  const OrderEntity(
      this.orderItem,
      this.orderAmount,
      this.orderCustomer,
      this.orderMerchant,
      this.orderCreatedAt,
      this.orderMode,
      this.orderETA,
      this.receipt,
      this.status,
      this.orderID,
      this.docID,
      this.orderConfirmation,
      this.customerID,
      this.agent,
      this.orderLogistic,
      this.isAssigned,
      this.resolution,
      this.potentials,
      this.index,
      this.customerDevice,
      this.errand
      );

  Map<String, Object> toJson() {
    return {
      'orderItem': orderItem,
      'orderAmount': orderAmount,
      'orderCustomer': orderCustomer,
      'orderMerchant': orderMerchant,
      'orderCreatedAt': orderCreatedAt,
      'orderMode': orderMode,
      'orderETA': orderETA,
      'receipt': receipt,
      'status': status,
      'orderID': orderID,
      'docID': docID,
      'orderConfirmation': orderConfirmation,
      'customerID': customerID,
      'agent':agent,
      'orderLogistic':orderLogistic,
      'isAssigned':isAssigned,
      'resolution':resolution,
      'potentials':potentials,
      'index':index,
      'customerDevice':customerDevice,
      'errand':errand
    };
  }

  @override
  List<Object> get props => [
        orderItem,
        orderAmount,
        orderCustomer,
        orderMerchant,
        orderCreatedAt,
        orderMode,
        orderETA,
        receipt,
        status,
        orderID,
        docID,
        orderConfirmation,
        customerID,
        agent,
        orderLogistic,
        isAssigned,
        resolution,
        potentials,
        index,
        customerDevice,
        errand
      ];

  @override
  String toString() {
    return '''Instance of OrderEntity''';
  }

  static OrderEntity fromJson(Map<String, Object> json) {
    return OrderEntity(
        json['orderItem'] as List,
        json['orderAmount'] as double,
        json['orderCustomer'] as Customer,
        json['orderMerchant'] as String,
        json['orderCreatedAt'] as dynamic,
        json['orderMode'] as OrderMode,
        json['orderETA'] as int,
        json['receipt'] as Receipt,
        json['status'] as int,
        json['orderID'] as String,
        json['docID'] as String,
        json['orderConfirmation'] as Confirmation,
        json['customerID'] as String,
        json['agent'] as String,
        json['orderLogistic'] as String,
        json['isAssigned'] as bool,
        json['resolution'] as String,
        json['potentials'] as List,
        json['index'] as List,
        json['customerDevice'] as String,
      json['errand'] as ErrandObj,
    );
  }

  static OrderEntity fromSnapshot(DocumentSnapshot snap) {
    //print(snap.data);
    return OrderEntity(
        OrderItem.fromListMap(snap.data['orderItem']),
        snap.data['orderAmount'],
        Customer.fromMap(snap.data['orderCustomer']),
        snap.data['orderMerchant'],
        snap.data['orderCreatedAt'],
        OrderMode.fromMap(snap.data['orderMode']),
        snap.data['orderETA'],
        Receipt.fromMap(snap.data['receipt']),
        snap.data['status'],
        snap.data['orderID'],
        snap.documentID,
        Confirmation.fromMap(snap.data['orderConfirmation']),
        snap.data['customerID'],
        snap.data['agent'],
        snap.data['orderLogistic'],
        snap.data['isAssigned'],
        snap.data['resolution'],
        List.castFrom(snap.data['potentials']),
       List.castFrom(snap.data['index']),
       snap.data['customerDevice'],
        ErrandObj.fromMap(snap.data['errand'])??null,
    );
  }

  static List<OrderEntity> fromListSnapshot(List<DocumentSnapshot> snap) {
    List<OrderEntity> collection =[];
    snap.forEach((element) { collection.add(OrderEntity.fromSnapshot(element));});
    return collection;
  }

  Map<String, Object> toDocument() {
    return {
      'orderItem': orderItem,
      'orderAmount': orderAmount,
      'orderCustomer': orderCustomer,
      'orderMerchant': orderMerchant,
      'orderCreatedAt': orderCreatedAt,
      'orderMode': orderMode,
      'orderETA': orderETA,
      'receipt': receipt,
      'status': status,
      'orderID': orderID,
      'docID': docID,
      'orderConfirmation': orderConfirmation,
      'customerID': customerID,
      'agent':agent,
      'orderLogistic':orderLogistic,
      'isAssigned':agent,
      'resolution':orderLogistic,
      'potentials':potentials,
      'index':index,
      'customerDevice':customerDevice,
      'errand':errand
    };
  }
}
