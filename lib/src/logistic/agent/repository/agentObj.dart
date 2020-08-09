import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

@immutable
class Agent {
  final String agent;
  final String autoType;
  final String autoAssigned;
  final Timestamp agentCreatedAt;
  final String agentID;
  final String agentWorkPlace;
  final Timestamp startDate;
  final Timestamp endDate;
  final String agentBehaviour;
  final int agentStatus;
  final String workPlaceWallet;
  final String agentWallet;
  final int limit;
  final String name;
  final bool accepted;

  Agent(
      {this.agent,
      this.autoType,
      this.autoAssigned,
      this.agentCreatedAt,
      this.agentID,
      this.agentWorkPlace,
      this.startDate,
      this.endDate,
      this.agentBehaviour,
      this.agentStatus,
      this.workPlaceWallet,
      this.agentWallet,
      this.limit,
      this.name,
      this.accepted

      });

  Agent copyWith(
      {String agent,
      String autoType,
      String autoAssigned,
      Timestamp agentCreatedAt,
      String agentID,
      String agentWorkPlace,
      Timestamp startDate,
      Timestamp endDate,
      String agentBehaviour,
      int agentStatus,
      String workPlaceWallet,
      String agentWallet,
      int limit,
      String name,
      bool accepted,
      }) {
    return Agent(
        agent: agent ?? this.agent,
        autoType: autoType ?? this.autoType,
        autoAssigned: autoAssigned ?? this.autoAssigned,
        agentCreatedAt: agentCreatedAt ?? this.agentCreatedAt,
        agentID: agentID ?? this.agentID,
        agentWorkPlace: agentWorkPlace ?? this.agentWorkPlace,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        agentBehaviour: agentBehaviour ?? this.agentBehaviour,
        agentStatus: agentStatus ?? this.agentStatus,
        workPlaceWallet: workPlaceWallet??this.workPlaceWallet,
        agentWallet: agentWallet??this.agentWallet,
        limit: limit??this.limit,
        name: name ?? this.name,
        accepted: accepted ?? this.accepted,
    );
  }

  @override
  int get hashCode =>
      agent.hashCode ^
      autoType.hashCode ^
      autoAssigned.hashCode ^
      agentCreatedAt.hashCode ^
      agentID.hashCode ^
      agentWorkPlace.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      agentBehaviour.hashCode ^
      agentStatus.hashCode ^
      workPlaceWallet.hashCode ^
      agentWallet.hashCode ^
      limit.hashCode ^
      name.hashCode ^
      accepted.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Agent &&
          runtimeType == other.runtimeType &&
          agent == other.agent &&
          autoType == other.autoType &&
          autoAssigned == other.autoAssigned &&
          agentCreatedAt == other.agentCreatedAt &&
          agentID == other.agentID &&
          agentWorkPlace == other.agentWorkPlace &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          agentBehaviour == other.agentBehaviour &&
          agentStatus == other.agentStatus &&
          workPlaceWallet == other.workPlaceWallet &&
          agentWallet == other.agentWallet &&
          limit == other.limit &&
          name == other.name &&
          accepted==other.accepted;

  Agent update(
      {String agent,
      String autoType,
      String autoAssigned,
      Timestamp agentCreatedAt,
      String agentID,
      String agentWorkPlace,
      Timestamp startDate,
      Timestamp endDate,
      String agentBehaviour,
      int agentStatus,
      String workPlaceWallet,
      String agentWallet,
      int limit,
      String name,
      bool accepted
      }) {
    return copyWith(
        agent: agent,
        autoType: autoType,
        autoAssigned: autoAssigned,
        agentCreatedAt: agentCreatedAt,
        agentID: agentID,
        agentWorkPlace: agentWorkPlace,
        startDate: startDate,
        endDate: endDate,
        agentBehaviour: agentBehaviour,
        agentStatus: agentStatus,
        workPlaceWallet: workPlaceWallet,
        agentWallet: agentWallet,
        limit: limit,
       name: name,
      accepted: accepted
    );
  }

  @override
  String toString() {
    return '''Instance of Agent''';
  }

  Map<String, dynamic> toMap() {
    return {
      'agent': agent,
      'autoType': autoType,
      'autoAssigned': autoAssigned,
      'agentCreatedAt': agentCreatedAt,
      'agentID': agentID,
      'agentWorkPlace': agentWorkPlace,
      'startDate': startDate,
      'endDate': endDate,
      'agentBehaviour': agentBehaviour,
      'agentStatus': agentStatus,
      'workPlaceWallet':workPlaceWallet,
      'agentWallet':agentWallet,
      'limit':limit,
      'name':name,
      'hasEnded':false,
      'accepted':accepted
    };
  }

  static Agent fromSnap(DocumentSnapshot snap) {
    return Agent(
      agent: snap.data['agent'],
      autoType: snap.data['autoType'],
      autoAssigned: snap.data['autoAssigned'],
      agentCreatedAt: snap.data['agentCreatedAt'],
      agentID: snap.documentID,
      agentWorkPlace: snap.data['agentWorkPlace'],
      startDate: snap.data['startDate'],
      endDate: snap.data['endDate'],
      agentBehaviour: snap.data['agentBehaviour'],
      agentStatus: snap.data['agentStatus'],
      workPlaceWallet: snap.data['workPlaceWallet'],
      agentWallet: snap.data['agentWallet'],
      limit: snap.data['limit']??10000,
      name: snap.data['name'],
      accepted: snap.data['accepted'],
    );
  }

  static List<Agent> fromListSnap(List<DocumentSnapshot> snap) {
    List<Agent> collection = List();
    snap.forEach((element) {
      collection.add(Agent.fromSnap(element));
    });
    return collection;
  }
}
