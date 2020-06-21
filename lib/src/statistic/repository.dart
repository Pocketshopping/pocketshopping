import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pocketshopping/src/statistic/agentStatistic/agentStatistic.dart';
import 'package:pocketshopping/src/statistic/agentStatistic/deliveryRequest.dart';

class StatisticRepo {
  static final databaseReference = Firestore.instance;
  static final Geoflutterfire geo = Geoflutterfire();

  static Future<String> saveDeliveryRequest(DeliveryRequest deliveryRequest) async {
    DocumentReference bid;
    bid = await databaseReference.collection("deliveryRequest").add(deliveryRequest.toMap());
    return bid.documentID;
  }

/*  static Future<void> saveAgentStatistic(AgentStatistic agentStatistic) async {
    DocumentReference bid;
    var isExisting = await getAgentStatistic(agentStatistic.agent);

    if(isExisting == null)
    bid = await databaseReference.collection("agentStatistic").add(agentStatistic.toMap());

  }*/

  static Future<void> updateAgentStatistic(String id, {totalUnitUsed=0,totalOrderCount=0,totalDistance=0,totalCancelled=0,totalAmount=0}) async {
    AgentStatistic agentStatistic;
    AgentStatistic isExisting = await getAgentStatistic(id);

    if(isExisting == null){
      agentStatistic = AgentStatistic(
        agent: id,
        totalUnitUsed: totalUnitUsed,
        totalOrderCount: totalOrderCount,
        totalDistance: totalDistance,
        totalCancelled: totalCancelled,
        totalAmount: totalAmount,
      );
      await databaseReference.collection("agentStatistic").document(id).setData(
          agentStatistic.toMap());
    }
    else {
      agentStatistic = AgentStatistic(
        agent: id,
        totalUnitUsed: isExisting.totalUnitUsed + totalUnitUsed,
        totalOrderCount: isExisting.totalOrderCount + totalOrderCount,
        totalDistance: isExisting.totalDistance + totalDistance,
        totalCancelled: isExisting.totalCancelled + totalCancelled,
        totalAmount: isExisting.totalAmount + totalAmount,
      );
      await databaseReference.collection("agentStatistic").document(id).updateData(
          agentStatistic.toMap());
    }



  }

  static Future<List<LatLng>> getMissedDeliveryRequest(Position mpos,String whichDay) async {
    //var day = Utility.dayMaker(whichDay);
    final startAtTimestamp = Timestamp.fromMillisecondsSinceEpoch(
        DateTime.parse('2020-06-10 00:00').millisecondsSinceEpoch);
    final endAtTimestamp = Timestamp.fromMillisecondsSinceEpoch(
        DateTime.now().millisecondsSinceEpoch);
    //print(day);
    GeoFirePoint center =
    geo.point(latitude: mpos.latitude, longitude: mpos.longitude);
    var collectionReference = Firestore.instance
        .collection('deliveryRequest')
        .where('isMiss', isEqualTo: true)
        .limit(500);
    Stream<List<DocumentSnapshot>> alu = geo
        .collection(collectionRef: collectionReference)
        .within(
        center: center,
        radius: 100,
        field: 'cordinate',
        strictMode: true);
    var doc = await alu.first;


    return DeliveryRequest.toListLatLng(DeliveryRequest.fromListSnapshot(doc),whichDay);
  }

  static Future<AgentStatistic> getAgentStatistic(String agent) async {
    DocumentSnapshot doc;
    doc = await databaseReference.collection("agentStatistic").document(agent).get(source: Source.serverAndCache);
    return doc.exists?AgentStatistic.fromSnapshot(doc):null;
  }

}