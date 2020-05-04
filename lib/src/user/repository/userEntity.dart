// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String fname;
  final String email;
  final String telephone;
  final String role;
  final String notificationID;
  final String defaultAddress;
  final String profile;
  final String uid;
  final DocumentReference bid;
  final Timestamp createdat;
  final DocumentReference behaviour;
  final String country;

  const UserEntity(
    this.uid,
    this.fname,
    this.email,
    this.telephone,
    this.profile,
    this.notificationID,
    this.defaultAddress,
    this.role,
    this.bid,
    this.createdat,
    this.behaviour,
    this.country,
  );

  Map<String, Object> toJson() {
    return {
      'fname': fname,
      'email': email,
      'telephone': telephone,
      'profile': profile,
      'notificationID': notificationID,
      'defaultAddress': defaultAddress,
      'role': role,
      'business': bid,
      'createdAt': createdat,
      'behaviour': behaviour,
      'country': country
    };
  }

  @override
  List<Object> get props => [
        uid,
        fname,
        email,
        telephone,
        notificationID,
        defaultAddress,
        role,
        bid,
        profile,
        behaviour,
        country,
      ];

  @override
  String toString() {
    return '''UserEntity {
        fname: $fname,
    email: $email,
    telephone: $telephone,
    profile:$profile,
    notificationID:$notificationID,
    defaultAddress:$defaultAddress,
    role:$role,
    business:$bid,
    createdAt:$createdat,
    behaviour:$behaviour,
    country:$country}''';
  }

  static UserEntity fromJson(Map<String, Object> json) {
    return UserEntity(
        json['uid'] as String,
        json['fname'] as String,
        json['email'] as String,
        json['telephone'] as String,
        json['profile'] as String,
        json['notificationID'] as String,
        json['defaultAddress'] as String,
        json['role'] as String,
        json['business'] as DocumentReference,
        json['createdAt'] as Timestamp,
        json['behaviour'] as DocumentReference,
        json['country'] as String);
  }

  static UserEntity fromSnapshot(DocumentSnapshot snap) {
    //print(snap.data);
    return UserEntity(
      snap.documentID,
      snap.data['fname'],
      snap.data['email'],
      snap.data['telephone'],
      snap.data['profile'],
      snap.data['notificationID'],
      snap.data['defaultAddress'],
      snap.data['role'],
      snap.data['business'],
      snap.data['createdAt'],
      snap.data['behaviour'],
      snap.data['country'],
    );
  }

  Map<String, Object> toDocument() {
    return {
      'fname': fname,
      'email': email,
      'telephone': telephone,
      'profile': profile,
      'notificationID': notificationID,
      'defaultAddress': defaultAddress,
      'role': role,
      'business': bid,
      'createdAt': createdat,
      'behaviour': behaviour,
      'country': country
    };
  }
}
