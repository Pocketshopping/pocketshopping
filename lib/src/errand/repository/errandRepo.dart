import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pocketshopping/src/logistic/locationUpdate/agentLocUp.dart';

class ErrandRepo {
  static final databaseReference = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  static final Geoflutterfire geo = Geoflutterfire();
  static final double radius = 10;
  static final String field = 'agentLocation';



  static Stream<List<AgentLocUp>> getNearByErrandRider(Position pos,) async* {
    GeoFirePoint center = geo.point(latitude: pos.latitude, longitude: pos.longitude);
    var collectionReference = Firestore.instance
        .collection('agentLocationUpdate')
        .where('availability', isEqualTo: true)
        .where('pocket', isEqualTo: true)
        .where('parent', isEqualTo: true)
        .where('remitted', isEqualTo: true)
        .where('busy', isEqualTo: false)
        .where('autoAssigned', isEqualTo: true)
        .limit(5);
    Stream<List<DocumentSnapshot>> alu = geo
        .collection(collectionRef: collectionReference)
        .within(
        center: center,
        radius: radius,
        field: field,
        strictMode: true);
    yield* alu.map((event) => AgentLocUp.fromListSnap(event));
  }


}