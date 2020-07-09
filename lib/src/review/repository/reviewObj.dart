import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

import 'ReviewEntity.dart';

@immutable
class Review {
  final double rating;
  final String text;
  final Timestamp reviewedAt;
  final String reviewed;
  final String reviewerId;
  final String reviewerName;
  final String reviewId;

  Review({
    this.rating,
    this.text,
    this.reviewedAt,
    this.reviewed,
    this.reviewerId,
    this.reviewerName,
    this.reviewId,
  });

  Review copyWith({
    double rating,
    String text,
    Timestamp reviewedAt,
    String reviewed,
    String reviewerId,
    String reviewerName,
    String reviewId,
  }) {
    return Review(
        reviewedAt: reviewedAt ?? this.reviewedAt,
        reviewed: reviewed ?? this.reviewed,
        rating: rating ?? this.rating,
        reviewerName: reviewerName ?? this.reviewerName,
        reviewerId: reviewerId ?? this.reviewerId,
        text: text ?? this.text,
        reviewId: reviewId ?? this.reviewId);
  }

  @override
  int get hashCode =>
      text.hashCode ^
      rating.hashCode ^
      reviewed.hashCode ^
      reviewerId.hashCode ^
      reviewerName.hashCode ^
      reviewedAt.hashCode ^
      reviewId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Review &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          reviewedAt == other.reviewedAt &&
          reviewed == other.reviewed &&
          reviewerName == other.reviewerName &&
          reviewerId == other.reviewerId &&
          reviewId == other.reviewId;

  Review update({
    double rating,
    String text,
    Timestamp reviewedAt,
    String reviewed,
    String reviewerId,
    String reviewerName,
    String reviewId,
  }) {
    return copyWith(
      reviewedAt: reviewedAt,
      reviewed: reviewed,
      rating: rating,
      reviewerName: reviewerName,
      reviewerId: reviewerId,
      text: text,
      reviewId: reviewId,
    );
  }

  @override
  String toString() {
    return '''Review{orderID: $rating,}''';
  }

  Map<String, dynamic> toMap() {
    return {
      'reviewedAt': reviewedAt,
      'reviewed': reviewed,
      'rating': rating,
      'reviewerName': reviewerName,
      'reviewerId': reviewerId,
      'text': text,
      'reviewId': reviewId,
    };
  }

  static Review fromEntity(ReviewEntity reviewEntity) {
    return Review(
      reviewedAt: reviewEntity.reviewedAt,
      reviewed: reviewEntity.reviewed,
      rating: reviewEntity.rating,
      reviewerName: reviewEntity.reviewerName,
      reviewerId: reviewEntity.reviewerId,
      text: reviewEntity.text,
      reviewId: reviewEntity.reviewId,
    );
  }
}
