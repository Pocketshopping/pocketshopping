// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String pID;
  final DocumentReference mID;
  final String pName;
  final double pPrice;
  final String pCategory;
  final String pDesc;
  final List<dynamic> pPhoto;
  final String pGroup;
  final int pStockCount;
  final String pQRCode;
  final String pUploader;
  final String pUnit;
  final Timestamp pCreatedAt;

  const ProductEntity(
      this.pID,
      this.mID,
      this.pName,
      this.pPrice,
      this.pCategory,
      this.pDesc,
      this.pPhoto,
      this.pGroup,
      this.pStockCount,
      this.pQRCode,
      this.pUploader,
      this.pUnit,
      this.pCreatedAt);

  Map<String, Object> toJson() {
    return {
      'pID': pID,
      'mID': mID,
      'pName': pName,
      'pPrice': pPrice,
      'pCategory': pCategory,
      'pDesc': pDesc,
      'pPhoto': pPhoto,
      'pGroup': pGroup,
      'pStockCount': pStockCount,
      'pQRCode': pQRCode,
      'pUploader': pUploader,
      'pUnit': pUnit,
      'pCreatedAt': pCreatedAt
    };
  }

  @override
  List<Object> get props => [
        pID,
        mID,
        pName,
        pPrice,
        pCategory,
        pDesc,
        pPhoto,
        pGroup,
        pStockCount,
        pQRCode,
        pUploader,
        pUnit,
        pCreatedAt
      ];

  @override
  String toString() {
    return '''ProductEntity {
        bName:$pName ,}''';
  }

  static ProductEntity fromJson(Map<String, Object> json) {
    return ProductEntity(
      json['pID'] as String,
      json['mID'] as DocumentReference,
      json['pName'] as String,
      json['pPrice'] as double,
      json['pCategory'] as String,
      json['pDesc'] as String,
      json['pPhoto'] as List,
      json['pGroup'] as String,
      json['pStockCount'] as int,
      json['pQRCode'] as String,
      json['pUploader'] as String,
      json['pUnit'] as String,
      json['pCreatedAt'] as Timestamp,
    );
  }

  static ProductEntity fromSnapshot(DocumentSnapshot snap) {
    //print(snap.data);
    return ProductEntity(
      snap.documentID,
      snap.data['productMerchant'],
      snap.data['productName'],
      snap.data['productPrice'],
      snap.data['productCategory'],
      snap.data['productDesc'],
      snap.data['productPhoto'],
      snap.data['productGroup'],
      snap.data['productStockCount'],
      snap.data['productQRCode'],
      snap.data['productUploader'].toString(),
      snap.data['productUnit'],
      snap.data['productCreatedAt'],
    );
  }

  Map<String, Object> toDocument() {
    return {
      'pID': pID,
      'mID': mID,
      'pName': pName,
      'pPrice': pPrice,
      'pCategory': pCategory,
      'pDesc': pDesc,
      'pPhoto': pPhoto,
      'pGroup': pGroup,
      'pStockCount': pStockCount,
      'pQRCode': pQRCode,
      'pUploader': pUploader,
      'pUnit': pUnit,
      'pCreatedAt': pCreatedAt
    };
  }
}
