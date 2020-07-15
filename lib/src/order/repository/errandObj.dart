import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

@immutable
class ErrandObj {
  final GeoPoint source;
  final GeoPoint destination;
  final String destinationContact;
  final String destinationName;
  final String comment;
  final String sourceAddress;
  final String destinationAddress;

  ErrandObj({
    this.destinationContact,
    this.destinationName,
    this.source,
    this.destination,
    this.comment,
    this.sourceAddress,
    this.destinationAddress,
  });

  ErrandObj copyWith({
    String destinationContact,
    String destinationName,
    GeoPoint source,
    GeoPoint destination,
    String comment,
    String sourceAddress,
    String destinationAddress


  }) {
    return ErrandObj(
        destinationContact: destinationContact ?? this.destinationContact,
        destinationName: destinationName ?? this.destinationName,
        source: source ?? this.source,
        destination: destination ?? this.destination,
        comment: comment??this.comment,
        sourceAddress: sourceAddress ?? this.sourceAddress,
        destinationAddress: destinationAddress ?? this.destinationAddress
    );
  }

  @override
  int get hashCode =>
      destinationContact.hashCode ^
      destinationName.hashCode ^
      source.hashCode ^
      destination.hashCode ^
      comment.hashCode ^
      sourceAddress.hashCode ^
      destinationAddress.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ErrandObj &&
              runtimeType == other.runtimeType &&
              destinationContact == other.destinationContact &&
              destinationName == other.destinationName &&
              source == other.source &&
              destination == other.destination &&
              comment == other.comment &&
              sourceAddress == other.sourceAddress &&
              destinationAddress == other.destinationAddress;

  @override
  String toString() {
    return '''Instance of ErrandObj''';
  }

  Map<String, dynamic> toMap() {
    return {
      'destinationContact': destinationContact??'',
      'destinationName': destinationName??'',
      'source': source??null,
      'destination': destination??null,
      'comment':comment??'',
      'sourceAddress':sourceAddress??'',
      'destinationAddress':destinationAddress??''

    };
  }

  static ErrandObj fromMap(Map<String, dynamic> errand) {
    return ErrandObj(
      destinationContact: errand['destinationContact']??'',
      destinationName: errand['destinationName']??'',
      source: errand['source']??null,
      destination: errand['destination']??null,
      comment: errand['comment']??'',
      sourceAddress: errand['sourceAddress'],
      destinationAddress: errand['destinationAddress']
    );
  }
}
