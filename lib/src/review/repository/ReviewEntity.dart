// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final double rating;
  final String text;
  final Timestamp reviewedAt;
  final String reviewed;
  final String reviewerId;
  final String reviewerName;
  final String reviewId;

  const ReviewEntity(
    this.rating,
    this.text,
    this.reviewedAt,
    this.reviewed,
    this.reviewerId,
    this.reviewerName,
    this.reviewId,
  );

  Map<String, Object> toJson() {
    return {
      'rating': rating,
      'text': text,
      'reviewedAt': reviewedAt,
      'reviewed': reviewed,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'reviewId': reviewId
    };
  }

  @override
  List<Object> get props => [
        rating,
        text,
        reviewedAt,
        reviewed,
        reviewerId,
        reviewerName,
        reviewId,
      ];

  @override
  String toString() {
    return '''ReviewEntity {$rating ,}''';
  }

  static ReviewEntity fromJson(Map<String, Object> json) {
    return ReviewEntity(
      json['rating'] as double,
      json['text'] as String,
      json['reviewedAt'] as Timestamp,
      json['reviewed'] as String,
      json['reviewerId'] as String,
      json['reviewerName'] as String,
      json['reviewId'] as String,
    );
  }

  static ReviewEntity fromSnapshot(DocumentSnapshot snap) {
    //print(snap.data);
    return ReviewEntity(
        snap.data()['rating'],
        snap.data()['text'],
        snap.data()['reviewedAt'],
        snap.data()['reviewed'],
        snap.data()['reviewerId'],
        snap.data()['reviewerName'],
        snap.id);
  }

  Map<String, Object> toDocument() {
    return {
      'rating': rating,
      'text': text,
      'reviewedAt': reviewedAt,
      'reviewed': reviewed,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'reviewId': reviewId,
    };
  }
}
