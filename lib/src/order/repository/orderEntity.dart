// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:pocketshopping/src/order/repository/orderItem.dart';
import 'package:pocketshopping/src/order/repository/orderMode.dart';
import 'package:pocketshopping/src/order/repository/receipt.dart';
import 'package:pocketshopping/src/order/repository/customer.dart';
import 'package:pocketshopping/src/order/repository/confirmation.dart';

class OrderEntity extends Equatable {
  final List<OrderItem>orderItem;
  final double orderAmount;
  final Customer orderCustomer;
  final String orderMerchant;
  final dynamic orderCreatedAt;
  final OrderMode orderMode;
  final int orderETA;
  final Receipt receipt;
  final String status;
  final String orderID;
  final String docID;
  final Confirmation orderConfirmation;

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
      this.orderConfirmation
      );

  Map<String, Object> toJson() {
    return {
      'orderItem':orderItem,
      'orderAmount':orderAmount,
      'orderCustomer':orderCustomer,
      'orderMerchant':orderMerchant,
      'orderCreatedAt':orderCreatedAt,
      'orderMode':orderMode,
      'orderETA':orderETA,
      'receipt':receipt,
      'status':status,
      'orderID':orderID,
      'docID':docID,
      'orderConfirmation':orderConfirmation,
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
    orderConfirmation
  ];

  @override
  String toString() {
    return '''OrderEntity {bName:$orderID ,}''';
  }

  static OrderEntity fromJson(Map<String, Object> json) {
    return OrderEntity(
      json['orderItem'] as  List,
      json['orderAmount'] as  double,
      json['orderCustomer'] as  Customer,
      json['orderMerchant'] as  String,
      json['orderCreatedAt'] as  dynamic,
      json['orderMode'] as  OrderMode,
      json['orderETA'] as  int,
      json['receipt'] as  Receipt,
      json['status'] as  String,
      json['orderID'] as  String,
      json['docID'] as  String,
      json['orderConfirmation'] as Confirmation,
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
    );
  }

  Map<String, Object> toDocument() {
    return {
      'orderItem':orderItem,
      'orderAmount':orderAmount,
      'orderCustomer':orderCustomer,
      'orderMerchant':orderMerchant,
      'orderCreatedAt':orderCreatedAt,
      'orderMode':orderMode,
      'orderETA':orderETA,
      'receipt':receipt,
      'status':status,
      'orderID':orderID,
      'docID':docID,
      'orderConfirmation':orderConfirmation,
    };
  }
}
