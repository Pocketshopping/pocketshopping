import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

import 'ReviewEntity.dart';

@immutable
class Review {
  final double reviewRating;
  final String reviewText;
  final Timestamp reviewedAt;
  final String reviewedMerchant;
  final String customerId;
  final String customerName;
  final String reviewId;

  Review({
    this.reviewRating,
    this.reviewText,
    this.reviewedAt,
    this.reviewedMerchant,
    this.customerId,
    this.customerName,
    this.reviewId,
  });

  Review copyWith({
    double reviewRating,
    String reviewText,
    Timestamp reviewedAt,
    String reviewedMerchant,
    String customerId,
    String customerName,
    String reviewId,
  }) {
    return Review(
        reviewedAt: reviewedAt ?? this.reviewedAt,
        reviewedMerchant: reviewedMerchant ?? this.reviewedMerchant,
        reviewRating: reviewRating ?? this.reviewRating,
        customerName: customerName ?? this.customerName,
        customerId: customerId ?? this.customerId,
        reviewText: reviewText ?? this.reviewText,
        reviewId: reviewId ?? this.reviewId);
  }

  @override
  int get hashCode =>
      reviewText.hashCode ^
      reviewRating.hashCode ^
      reviewedMerchant.hashCode ^
      customerId.hashCode ^
      customerName.hashCode ^
      reviewedAt.hashCode ^
      reviewId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Review &&
          runtimeType == other.runtimeType &&
          reviewText == other.reviewText &&
          reviewedAt == other.reviewedAt &&
          reviewedMerchant == other.reviewedMerchant &&
          customerName == other.customerName &&
          customerId == other.customerId &&
          reviewId == other.reviewId;

  Review update({
    double reviewRating,
    String reviewText,
    Timestamp reviewedAt,
    String reviewedMerchant,
    String customerId,
    String customerName,
    String reviewId,
  }) {
    return copyWith(
      reviewedAt: reviewedAt,
      reviewedMerchant: reviewedMerchant,
      reviewRating: reviewRating,
      customerName: customerName,
      customerId: customerId,
      reviewText: reviewText,
      reviewId: reviewId,
    );
  }

  @override
  String toString() {
    return '''Review{orderID: $reviewRating,}''';
  }

  Map<String, dynamic> toMap() {
    return {
      'reviewedAt': reviewedAt,
      'reviewedMerchant': reviewedMerchant,
      'reviewRating': reviewRating,
      'customerName': customerName,
      'customerId': customerId,
      'reviewText': reviewText,
      'reviewId': reviewId,
    };
  }

  static Review fromEntity(ReviewEntity reviewEntity) {
    return Review(
      reviewedAt: reviewEntity.reviewedAt,
      reviewedMerchant: reviewEntity.reviewedMerchant,
      reviewRating: reviewEntity.reviewRating,
      customerName: reviewEntity.customerName,
      customerId: reviewEntity.customerId,
      reviewText: reviewEntity.reviewText,
      reviewId: reviewEntity.reviewId,
    );
  }
}
