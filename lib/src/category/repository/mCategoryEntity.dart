// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MCategoryEntity extends Equatable {
  final String categoryName;
  final String categoryURI;
  final int categoryView;
  final String categoryId;
  final String desc;

  const MCategoryEntity(
    this.categoryName,
    this.categoryURI,
    this.categoryView,
    this.categoryId,
      this.desc
  );

  Map<String, Object> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryURI': categoryURI,
      'categoryView': categoryView,
      'desc':desc
    };
  }

  @override
  List<Object> get props => [
        categoryName,
        categoryURI,
        categoryView,
        categoryId,
        desc
      ];

  @override
  String toString() {
    return '''Instance of MCategoryEntity''';
  }

  static MCategoryEntity fromJson(Map<String, Object> json) {
    return MCategoryEntity(
      json['categoryName'] as String,
      json['categoryURI'] as String,
      json['categoryView'] as int,
      json['categoryId'] as String,
      json['desc'] as String,
    );
  }

  static MCategoryEntity fromSnapshot(DocumentSnapshot snap) {
    //print(snap.data);
    return MCategoryEntity(
      snap.data['categoryName'],
      snap.data['categoryURI'],
      snap.data['categoryView'],
      snap.documentID,
      snap.data['desc'],
    );
  }

  Map<String, Object> toDocument() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryURI': categoryURI,
      'categoryView': categoryView,
      'desc':desc
    };
  }
}
