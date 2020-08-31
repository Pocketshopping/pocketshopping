import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:pocketshopping/src/utility/utility.dart';

@immutable
class DeliveryRequest {
  final Timestamp insertedAt;
  final String agent;
  final GeoPoint cordinate;
  final int distance;
  final String orderId;
  final bool isMiss;

  DeliveryRequest({
    this.insertedAt,
    this.agent,
    this.cordinate,
    this.distance,
    this.orderId,
    this.isMiss,
  });

  DeliveryRequest copyWith({
     Timestamp insertedAt,
     String agent,
    GeoPoint cordinate,
     String orderId,
     bool isMiss,
  }) {
    return DeliveryRequest(
      insertedAt: insertedAt ?? this.insertedAt,
      agent: agent ?? this.agent,
      cordinate: cordinate,
      distance: distance ?? this.distance,
      orderId: orderId ?? this.orderId,
      isMiss: isMiss ?? this.isMiss,
    );
  }

  @override
  int get hashCode =>
      insertedAt.hashCode ^ agent.hashCode ^ cordinate.hashCode ^ distance.hashCode ^ orderId.hashCode ^ isMiss.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DeliveryRequest &&
              runtimeType == other.runtimeType &&
              insertedAt == other.insertedAt &&
              agent == other.agent &&
              cordinate == other.cordinate &&
              distance == other.distance &&
              orderId == other.orderId &&
              isMiss == other.isMiss;

  @override
  String toString() {
    return '''Instance of DeliveryRequest''';
  }

  Map<String, dynamic> toMap() {
    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint agentLocation = geo.point(latitude: cordinate.latitude, longitude: cordinate.longitude);
    return {
      'insertedAt': Timestamp.now(),
      'agent': this.agent,
      'cordinate': agentLocation.data,
      'distance': this.distance,
      'orderId': this.orderId,
      'isMiss': this.isMiss,
    };
  }

  static DeliveryRequest fromSnapshot(DocumentSnapshot request) {
    return DeliveryRequest(
      insertedAt: request.data()['insertedAt'],
      agent: request.data()['agent'],
      cordinate: (request.data()['cordinate'] as Map<String, dynamic>)['geopoint'],
      distance: request.data()['distance'],
      orderId: request.data()['orderId'],
      isMiss: request.data()['isMiss'],
    );
  }

  static List<DeliveryRequest> fromListSnapshot(List<DocumentSnapshot> snap) {
    List<DeliveryRequest> collection =[];
    snap.forEach((element) { collection.add(DeliveryRequest.fromSnapshot(element));});
    return collection;
  }

  static List<LatLng> toListLatLng(List<DeliveryRequest> deliveryRequest, String whichDay){
    List<LatLng> collection =[];
    deliveryRequest.forEach((element) {
      if(Utility.dayMaker(DateTime.parse((element.insertedAt).toDate().toString()), whichDay))
        collection.add(LatLng(element.cordinate.latitude, element.cordinate.longitude));

    });
    return collection;
  }
}
