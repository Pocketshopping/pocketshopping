import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';


@immutable
class Otp {
  final String id;
  final Timestamp insertedAt;
  final String otp;
  final bool isNew;


  Otp(
      {this.id,
        this.insertedAt,
        this.otp,
        this.isNew,
      });

  Otp copyWith({
    String id,
    Timestamp insertedAt,
    String otp,
    bool isNew,
  }) {
    return Otp(
        id: id ?? this.id,
        otp: otp ?? this.otp,
        isNew: isNew ?? this.isNew,
        insertedAt: insertedAt ?? this.insertedAt,
    );
  }

  @override
  int get hashCode =>
      id.hashCode ^
      insertedAt.hashCode ^
      otp.hashCode ^
      isNew.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Otp &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              insertedAt == other.insertedAt &&
              otp == other.otp &&
              isNew == other.isNew;

  Otp update({
    String id,
    Timestamp insertedAt,
    String otp,
    bool isNew,
  }) {
    return copyWith(
        id: id,
        otp: otp,
        isNew: isNew,
        insertedAt: insertedAt,
    );
  }

  @override
  String toString() {
    return '''Instance of Otp''';
  }

  Map<String,dynamic> toMap(){
    return {
      'id': id,
      'otp': otp,
      'isNew': isNew,
      'insertedAt': insertedAt,
    };
  }


  static Otp fromMap(DocumentSnapshot snap) {
    return Otp(
      id: snap.id,
      otp: snap.data()['otp'],
      insertedAt: snap.data()['insertedAt'],
      isNew: snap.data()['isNew'],

    );
  }
}
