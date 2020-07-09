// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MerchantEntity extends Equatable {
  final String bName;
  final String bEmail;
  final String bTelephone;
  final String bTelephone2;
  final String bUnique;
  final String bAddress;
  final Map<String, dynamic> bSocial;
  final String bDelivery;
  final String bCategory;
  final String bDescription;
  final dynamic bGeoPoint;
  final String bID;
  final String mID;
  final String bClose;
  final String bOpen;
  final DocumentReference bCreator;
  final DocumentReference bParent;
  final bool bIsBranch;
  final String bPhoto;
  final int bStatus;
  final Timestamp bCreatedAt;
  final String bCountry;
  final bool adminUploaded;
  final bool bActive;
  final String bWallet;

  const MerchantEntity(
      this.bName,
      this.bEmail,
      this.bTelephone,
      this.bTelephone2,
      this.bPhoto,
      this.bAddress,
      this.bCategory,
      this.mID,
      this.bParent,
      this.bCountry,
      this.bID,
      this.bStatus,
      this.bSocial,
      this.bDescription,
      this.bDelivery,
      this.bClose,
      this.bCreatedAt,
      this.bCreator,
      this.bGeoPoint,
      this.bIsBranch,
      this.bOpen,
      this.bUnique,
      this.adminUploaded,
      this.bActive,
      this.bWallet);

  Map<String, Object> toJson() {
    return {
      'bName': bName,
      'bEmail': bEmail,
      'bTelephone': bTelephone,
      'bTelephone2': bTelephone2,
      'bUnique': bUnique,
      'bAddress': bAddress,
      'bSocial': bSocial,
      'bDelivery': bDelivery,
      'bCategory': bCategory,
      'bDescription': bCategory,
      'bGeoPoint': bGeoPoint,
      'bID': bID,
      'mID': mID,
      'bClose': bClose,
      'bOpen': bOpen,
      'bCreator': bCreator,
      'bParent': bParent,
      'bIsBranch': bIsBranch,
      'bPhoto': bPhoto,
      'bStatus': bStatus,
      'bCreatedAt': bCreatedAt,
      'bCountry': bCountry,
      'adminUploaded':adminUploaded,
      'bActive':bActive,
      'bWallet':bWallet,
    };
  }

  @override
  List<Object> get props => [
        bName,
        bEmail,
        bTelephone,
        bTelephone2,
        bPhoto,
        bAddress,
        bCategory,
        mID,
        bParent,
        bCountry,
        bID,
        bStatus,
        bSocial,
        bDescription,
        bDelivery,
        bClose,
        bCreatedAt,
        bCreator,
        bGeoPoint,
        bIsBranch,
        bOpen,
        bUnique,
        adminUploaded,
        bActive,
        bWallet
      ];

  @override
  String toString() {
    return '''Instance of MerchantEntity''';
  }

  static MerchantEntity fromJson(Map<String, Object> json) {
    return MerchantEntity(
      json['bName'] as String,
      json['bEmail'] as String,
      json['bTelephone'] as String,
      json['bTelephone2'] as String,
      json['bPhoto'] as String,
      json['bAddress'] as String,
      json['bCategory'] as String,
      json['mID'] as String,
      json['bParent'] as DocumentReference,
      json['bCountry'] as String,
      json['bID'] as String,
      json['bStatus'] as int,
      json['bSocial'] as Map<String, dynamic>,
      json['bDescription'] as String,
      json['bDelivery'] as String,
      json['bClose'] as String,
      json['bCreatedAt'] as Timestamp,
      json['bCreator'] as DocumentReference,
      json['bGeoPoint'] as dynamic,
      json['bIsBranch'] as bool,
      json['bOpen'] as String,
      json['bUnique'] as String,
      json['adminUploaded'] as bool,
      json['bActive'] as bool,
      json['bWallet'] as String
    );
  }

  static MerchantEntity fromSnapshot(DocumentSnapshot snap) {
    //print(snap.data);
    return MerchantEntity(
      snap.data['businessName'],
      snap.data['businessEmail'],
      snap.data['businessTelephone'],
      snap.data['businessTelephone2'],
      snap.data['businessPhoto'],
      snap.data['businessAdress'],
      snap.data['businessCategory'],
      snap.documentID,
      snap.data['businessParent'],
      snap.data['businessCountry'],
      snap.data['businessID'],
      snap.data['businessStatus'].runtimeType == int?snap.data['businessStatus']:1,
      snap.data['businessSocial'],
      snap.data['businessDescription'],
      snap.data['businessDelivery'],
      snap.data['businessCloseTime'],
      snap.data['businessCreatedAt'],
      snap.data['businessCreator'],
      snap.data['businessGeopint'],
      snap.data['isBranch'],
      snap.data['businessOpenTime'],
      snap.data['branchUnique'],
      snap.data['adminUploaded']??false,
      snap.data['businessActive']??true,
      snap.data['bWallet']??"",
    );
  }


  static List<MerchantEntity> fromListSnapshot(List<DocumentSnapshot> snap) {
    return snap.map((e) => MerchantEntity.fromSnapshot(e)).toList();
  }


  Map<String, Object> toDocument() {
    return {
      'bName': bName,
      'bEmail': bEmail,
      'bTelephone': bTelephone,
      'bTelephone2': bTelephone2,
      'bUnique': bUnique,
      'bAddress': bAddress,
      'bSocial': bSocial,
      'bDelivery': bDelivery,
      'bCategory': bCategory,
      'bDescription': bCategory,
      'bGeoPoint': bGeoPoint,
      'bID': bID,
      'mID': mID,
      'bClose': bClose,
      'bOpen': bOpen,
      'bCreator': bCreator,
      'bParent': bParent,
      'bIsBranch': bIsBranch,
      'bPhoto': bPhoto,
      'bStatus': bStatus,
      'bCreatedAt': bCreatedAt,
      'bCountry': bCountry,
      'adminUploaded':adminUploaded,
      'bActive':bActive,
      'bWallet':bWallet
    };
  }
}
