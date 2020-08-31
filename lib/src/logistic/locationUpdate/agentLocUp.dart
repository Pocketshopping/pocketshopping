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
  final Timestamp startedAt;
  final String profile;
  final String address;
  final String wallet;
  final String workPlaceWallet;
  final int limit;
  final bool autoAssigned;
  final bool accepted;
  final bool busy;

  AgentLocUp({
    this.agent,
    this.agentAutomobile,
    this.agentUpdateAt,
    this.agentLocation,
    this.agentName,
    this.agentTelephone,
    this.availability,
    this.device,
    this.startedAt,
    this.profile,
    this.address,
    this.wallet,
    this.workPlaceWallet,
    this.limit,
    this.autoAssigned,
    this.accepted,
    this.busy,

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
    Timestamp startedAt,
    String profile,
    String address,
    String wallet,
    String workPlaceWallet,
    int limit,
    bool autoAssigned,
    bool accepted,
    bool busy

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
      startedAt: startedAt??this.startedAt,
      profile: profile??this.profile,
      address: address??this.address,
      wallet: wallet??this.wallet,
      workPlaceWallet: workPlaceWallet??this.workPlaceWallet,
      limit: limit??this.limit,
      autoAssigned: autoAssigned ?? this.autoAssigned,
      accepted: accepted?? this.accepted,
      busy: busy??this.busy
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
      device.hashCode ^
      startedAt.hashCode ^
      profile.hashCode ^
      address.hashCode ^
      wallet.hashCode ^
      workPlaceWallet.hashCode ^
      limit.hashCode ^
      autoAssigned.hashCode ^ accepted.hashCode ^ busy.hashCode;

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
          device == other.device &&
          startedAt == other.startedAt &&
          profile == other.profile &&
          address==other.address &&
          wallet == other.wallet &&
          workPlaceWallet == other.workPlaceWallet &&
          limit == other.limit &&
          autoAssigned == other.autoAssigned && accepted == other.accepted && busy == other.busy;

  AgentLocUp update({
    String agent,
    String agentAutomobile,
    Timestamp agentUpdateAt,
    GeoPoint agentLocation,
    String agentName,
    String agentTelephone,
    bool availability,
    Timestamp startedAt,
    String device,
    String profile,
    String address,
    String wallet,
    String workPlaceWallet,
    int limit,
    bool autoAssigned,
    bool accepted,
    bool busy
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
      startedAt: startedAt,
      profile: profile,
      address: address,
      workPlaceWallet: workPlaceWallet,
      wallet: wallet,
      limit: limit,
      autoAssigned: autoAssigned,
      accepted: accepted,
      busy: busy
    );
  }

  @override
  String toString() {
    return '''Instance of AgentLocUp''';
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
      'startedAt':startedAt,
      'profile':profile,
      'address':address,
      'wallet':wallet,
      'workPlaceWallet':workPlaceWallet,
      'limit':limit,
      'autoAssigned':autoAssigned,
      'accepted':accepted,
      'busy':busy??false,
    };
  }

  static AgentLocUp fromSnap(DocumentSnapshot snap) {
    return AgentLocUp(
      agentAutomobile: snap.data()['agentAutomobile'],
      agentUpdateAt: snap.data()['UpdatedAt'],
      agentLocation: (snap.data()['agentLocation'] as Map<String, dynamic>)['geopoint'],
      agent: snap.id,
      agentName: snap.data()['agentName'],
      agentTelephone: snap.data()['agentTelephone'],
      availability: snap.data()['availability'],
      device: snap.data()['device'],
      startedAt: snap.data()['startedAt'],
      profile: snap.data()['profile'],
      address: snap.data()['address'],
      wallet: snap.data()['wallet'],
      workPlaceWallet: snap.data()['workPlaceWallet'],
      limit: snap.data()['limit'],
      autoAssigned: snap.data()['autoAssigned'],
      accepted: snap.data()['accepted']??false,
      busy: snap.data()['busy']??false,

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

  static List<String> getAgent(List<AgentLocUp> alu) {
    List<String> collection = List();
    alu.forEach((element) {
      collection.add(element.agent);
    });
    return collection;
  }
}
