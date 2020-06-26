import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

@immutable
class Request {
  final String requestAction;
  final String requestBody;
  final bool requestCleared;
  final Timestamp requestClearedAt;
  final Timestamp requestCreatedAt;
  final String requestInitiator;
  final String requestInitiatorID;
  final String requestID;
  final String requestReceiver;
  final String requestTitle;

  Request(
      {this.requestAction,
      this.requestBody,
      this.requestCleared,
      this.requestClearedAt,
      this.requestCreatedAt,
      this.requestInitiator,
      this.requestInitiatorID,
      this.requestID,
      this.requestReceiver,
      this.requestTitle});

  Request copyWith({
    String requestAction,
    String requestBody,
    bool requestCleared,
    Timestamp requestClearedAt,
    Timestamp requestCreatedAt,
    String requestInitiator,
    String requestInitiatorID,
    String requestID,
    String requestReceiver,
    String requestTitle,
  }) {
    return Request(
      requestAction: requestAction ?? this.requestAction,
      requestBody: requestBody ?? this.requestBody,
      requestCleared: requestCleared ?? this.requestCleared,
      requestCreatedAt: requestCreatedAt ?? this.requestCreatedAt,
      requestInitiator: requestInitiator ?? this.requestInitiator,
      requestInitiatorID: requestInitiatorID ?? this.requestInitiatorID,
      requestID: requestID ?? this.requestID,
      requestClearedAt: requestClearedAt ?? this.requestClearedAt,
      requestReceiver: requestReceiver ?? this.requestReceiver,
      requestTitle: requestTitle ?? this.requestTitle,
    );
  }

  @override
  int get hashCode =>
      requestAction.hashCode ^
      requestBody.hashCode ^
      requestCleared.hashCode ^
      requestClearedAt.hashCode ^
      requestCreatedAt.hashCode ^
      requestInitiator.hashCode ^
      requestInitiatorID.hashCode ^
      requestID.hashCode ^
      requestReceiver.hashCode ^
      requestTitle.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Request &&
          runtimeType == other.runtimeType &&
          requestAction == other.requestAction &&
          requestBody == other.requestBody &&
          requestCleared == other.requestCleared &&
          requestClearedAt == other.requestClearedAt &&
          requestCreatedAt == other.requestCreatedAt &&
          requestInitiator == other.requestInitiator &&
          requestInitiatorID == other.requestInitiatorID &&
          requestID == other.requestID &&
          requestReceiver == other.requestReceiver &&
          requestTitle == other.requestTitle;

  Request update({
    String requestAction,
    String requestBody,
    bool requestCleared,
    Timestamp requestClearedAt,
    Timestamp requestCreatedAt,
    String requestInitiator,
    String requestInitiatorID,
    String requestID,
    String requestReceiver,
    String requestTitle,
  }) {
    return copyWith(
      requestAction: requestAction,
      requestBody: requestBody,
      requestCleared: requestCleared,
      requestCreatedAt: requestCreatedAt,
      requestInitiator: requestInitiator,
      requestInitiatorID: requestInitiatorID,
      requestID: requestID,
      requestClearedAt: requestClearedAt,
      requestReceiver: requestReceiver,
      requestTitle: requestTitle,
    );
  }

  @override
  String toString() {
    return '''Instance of Request''';
  }

  Map<String, dynamic> toMap() {
    return {
      'requestAction': requestAction,
      'requestBody': requestBody,
      'requestCleared': requestCleared,
      'requestCreatedAt': Timestamp.now(),
      'requestInitiator': requestInitiator,
      'requestInitiatorID': requestInitiatorID,
      'requestID': requestID,
      'requestClearedAt': requestClearedAt,
      'requestReceiver': requestReceiver,
      'requestTitle': requestTitle,
    };
  }

  static Request fromSnap(DocumentSnapshot snap) {
    return Request(
        requestAction: (snap.data['requestAction']),
        requestBody: (snap.data['requestBody']),
        requestCleared: (snap.data['requestCleared']),
        requestCreatedAt: (snap.data['requestCreatedAt']),
        requestInitiator: snap.data['requestInitiator'],
        requestID: snap.documentID,
        requestInitiatorID: snap.data['requestInitiatorID'],
        requestClearedAt: snap.data['requestClearedAt'],
        requestReceiver: snap.data['requestReceiver'],
        requestTitle: snap.data['requestTitle']);
  }

  static List<Request> fromListSnap(List<DocumentSnapshot> snap) {
    List<Request> collection = List();
    snap.forEach((element) {
      collection.add(Request.fromSnap(element));
    });
    return collection;
  }
}
