// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:pocketshopping/src/order/repository/confirmation.dart';
import 'package:pocketshopping/src/order/repository/customer.dart';
import 'package:pocketshopping/src/order/repository/orderItem.dart';
import 'package:pocketshopping/src/order/repository/orderMode.dart';
import 'package:pocketshopping/src/order/repository/receipt.dart';

class ReviewEntity extends Equatable {
  final double reviewRating;
  final String reviewText;
  final Timestamp reviewedAt;
  final String reviewedMerchant;
  final String customerId;
  final String customerName;
  final String reviewId;

  const ReviewEntity(

      this.reviewRating,
      this.reviewText,
      this.reviewedAt,
      this.reviewedMerchant,
      this.customerId,
      this.customerName,
      this.reviewId,

      );

  Map<String, Object> toJson() {
    return {
      'reviewRating': reviewRating,
      'reviewText': reviewText,
      'reviewedAt': reviewedAt,
      'reviewedMerchant': reviewedMerchant,
      'customerId': customerId,
      'customerName': customerName,
      'reviewId':reviewId
    };
  }

  @override
  List<Object> get props => [
    reviewRating,
    reviewText,
    reviewedAt,
    reviewedMerchant,
    customerId,
    customerName,
    reviewId,
  ];

  @override
  String toString() {
    return '''ReviewEntity {$reviewRating ,}''';
  }

  static ReviewEntity fromJson(Map<String, Object> json) {
    return ReviewEntity(
        json['reviewRating'] as double,
        json['reviewText'] as String,
        json['reviewedAt'] as Timestamp,
        json['reviewedMerchant'] as String,
        json['customerId'] as String,
        json['customerName'] as String,
      json['reviewId'] as String,
       );
  }

  static ReviewEntity fromSnapshot(DocumentSnapshot snap) {
    //print(snap.data);
    return ReviewEntity(
        snap.data['reviewRating'],
        snap.data['reviewText'],
        snap.data['reviewedAt'],
        snap.data['reviewedMerchant'],
        snap.data['customerId'],
        snap.data['customerName'],
        snap.documentID
    );
  }

  Map<String, Object> toDocument() {
    return {
      'reviewRating': reviewRating,
      'reviewText': reviewText,
      'reviewedAt': reviewedAt,
      'reviewedMerchant': reviewedMerchant,
      'customerId': customerId,
      'customerName': customerName,
      'reviewId': reviewId,
    };
  }
}
