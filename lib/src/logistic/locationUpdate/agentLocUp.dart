import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

@immutable
class AgentLocUp {
  final String agent;
  final String agentAutomobile;
  final Timestamp agentUpdateAt;
  final GeoPoint agentLocation;
  final String agentName;
  final String agentTelephone;
  final bool availability;
  final String device;

  AgentLocUp({
    this.agent,
    this.agentAutomobile,
    this.agentUpdateAt,
    this.agentLocation,
    this.agentName,
    this.agentTelephone,
    this.availability,
    this.device,
  });

  AgentLocUp copyWith({
    String agent,
    String agentAutomobile,
    Timestamp agentUpdateAt,
    GeoPoint agentLocation,
    String agentName,
    String agentTelephone,
    bool availability,
    String device,
  }) {
    return AgentLocUp(
      agent: agent ?? this.agent,
      agentAutomobile: agentAutomobile ?? this.agentAutomobile,
      agentUpdateAt: agentUpdateAt ?? this.agentUpdateAt,
      agentLocation: agentLocation ?? this.agentLocation,
      agentName: agentName ?? this.agentName,
      agentTelephone: agentTelephone ?? this.agentTelephone,
      availability: availability ?? this.availability,
      device: device ?? this.device,
    );
  }

  @override
  int get hashCode =>
      agent.hashCode ^
      agentAutomobile.hashCode ^
      agentUpdateAt.hashCode ^
      agentLocation.hashCode ^
      agentName.hashCode ^
      agentTelephone.hashCode ^
      availability.hashCode ^
      device.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentLocUp &&
          runtimeType == other.runtimeType &&
          agent == other.agent &&
          agentAutomobile == other.agentAutomobile &&
          agentUpdateAt == other.agentUpdateAt &&
          agentLocation == other.agentLocation &&
          agentName == other.agentName &&
          agentTelephone == other.agentTelephone &&
          availability == other.availability &&
          device == other.device;

  AgentLocUpupdate({
    String agent,
    String agentAutomobile,
    Timestamp agentUpdateAt,
    GeoPoint agentLocation,
    String agentName,
    String agentTelephone,
    bool availability,
    String device,
  }) {
    return copyWith(
      agent: agent,
      agentAutomobile: agentAutomobile,
      agentUpdateAt: agentUpdateAt,
      agentLocation: agentLocation,
      agentName: agentName,
      agentTelephone: agentTelephone,
      availability: availability,
      device: device,
    );
  }

  @override
  String toString() {
    return '''AgentLocUp{AgentID: $agent,}''';
  }

  Map<String, dynamic> toMap() {
    return {
      'agent': agent,
      'agentAutomobile': agentAutomobile,
      'agentUpdateAt': agentUpdateAt,
      'agentLocation': agentLocation,
      'agentName': agentName,
      'agentTelephone': agentTelephone,
      'availability': availability,
      'device': device,
    };
  }

  static AgentLocUp fromSnap(DocumentSnapshot snap) {
    return AgentLocUp(
      agentAutomobile: snap.data['agentAutomobile'],
      agentUpdateAt: snap.data['agentUpdateAt'],
      agentLocation:
          (snap.data['agentLocation'] as Map<String, dynamic>)['geopoint'],
      agent: snap.documentID,
      agentName: snap.data['agentName'],
      agentTelephone: snap.data['agentTelephone'],
      availability: snap.data['availability'],
      device: snap.data['device'],
    );
  }

  static List<AgentLocUp> fromListSnap(List<DocumentSnapshot> snap) {
    List<AgentLocUp> collection = List();
    snap.forEach((element) {
      collection.add(AgentLocUp.fromSnap(element));
    });
    return collection;
  }

  static List<String> getDeviceToken(List<AgentLocUp> alu) {
    List<String> collection = List();
    alu.forEach((element) {
      collection.add(element.device);
    });
    return collection;
  }
}
