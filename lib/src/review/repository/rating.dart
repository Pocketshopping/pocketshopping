import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

@immutable
class Rating {
  final double rating;
  final double positive;
  final double neutral;
  final double negative;
  final String id;
  final Timestamp updatedAt;

  Rating(
      {
        this.rating=3.0,
        this.positive=1.0,
        this.neutral=0,
        this.negative=0,
        this.id,
        this.updatedAt,
      }
      );

  Rating copyWith(
      {
        double rating,
        double positive,
        double neutral,
        double negative,
        String id,
        Timestamp updatedAt,
      }) {
    return Rating(
        rating: rating ?? this.rating,
        positive: positive ?? this.positive,
        neutral: neutral ?? this.neutral,
        negative: negative ?? this.negative,
        id: id ?? this.id,
        updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  int get hashCode =>
      rating.hashCode ^
      positive.hashCode ^
      neutral.hashCode ^
      negative.hashCode ^
      id.hashCode ^
      updatedAt.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Rating &&
              runtimeType == other.runtimeType &&
              rating == other.rating &&
              positive == other.positive &&
              neutral == other.neutral &&
              negative == other.negative &&
              id == other.id &&
              updatedAt == other.updatedAt;

  Rating update(
      {
        double rating,
        double positive,
        double neutral,
        double negative,
        String id,
        Timestamp updatedAt,
      }) {
    return copyWith(
        rating: rating,
        positive: positive,
        neutral: neutral,
        negative: negative,
        id: id,
        updatedAt: updatedAt,

    );
  }

  static double calculate({double oldCount, double newCount }){
    return (((oldCount+newCount)/2).round())*1.0;
  }

  @override
  String toString() {
    return '''Instance of Rating''';
  }

  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      'positive': positive,
      'neutral': neutral,
      'negative': negative,
      'id': id,
      'updatedAt': Timestamp.now(),
    };
  }



  static Rating fromSnap(DocumentSnapshot snap) {
    return Rating(
      rating: (snap.data()['rating']),
      positive: (snap.data()['positive']),
      neutral: (snap.data()['neutral']),
      negative: (snap.data()['negative']),
      updatedAt: snap.data()['updatedAt'],
      id: snap.id,
    );

  }
}
