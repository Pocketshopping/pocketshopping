import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

@immutable
class AgentStatistic {
  final Timestamp updatedAt;
  final String agent;
  final int totalUnitUsed;
  final int totalAmount;
  final int totalDistance;
  final int totalOrderCount;
  final int totalCancelled;

  AgentStatistic({
    this.updatedAt,
    this.agent,
    this.totalUnitUsed,
    this.totalAmount,
    this.totalDistance,
    this.totalOrderCount,
    this.totalCancelled,
  });

  AgentStatistic copyWith({
    Timestamp updatedAt,
    String agent,
    int totalUnitUsed,
    int totalAmount,
    int totalDistance,
    int totalOrderCount,
    int totalCancelled,
  }) {
    return AgentStatistic(
      updatedAt: updatedAt ?? this.updatedAt,
      agent: agent ?? this.agent,
      totalUnitUsed: totalUnitUsed ?? this.totalUnitUsed,
      totalAmount: totalAmount ?? this.totalAmount,
      totalDistance: totalDistance ?? this.totalDistance,
      totalOrderCount: totalOrderCount ?? this.totalOrderCount,
      totalCancelled: totalCancelled ?? this.totalCancelled,
    );
  }

  @override
  int get hashCode =>
      updatedAt.hashCode ^ agent.hashCode ^ totalUnitUsed.hashCode ^ totalAmount.hashCode ^ totalDistance.hashCode ^ totalOrderCount.hashCode ^ totalCancelled.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AgentStatistic &&
              runtimeType == other.runtimeType &&
              updatedAt == other.updatedAt &&
              agent == other.agent &&
              totalUnitUsed == other.totalUnitUsed &&
              totalAmount == other.totalAmount &&
              totalDistance == other.totalDistance &&
              totalOrderCount == other.totalOrderCount &&
              totalCancelled == other.totalCancelled;

  @override
  String toString() {
    return '''Instance of AgentStatistic''';
  }

  Map<String, dynamic> toMap() {
    return {
      'updatedAt': Timestamp.now(),
      'agent': this.agent,
      'totalUnitUsed': this.totalUnitUsed,
      'totalAmount': this.totalAmount,
      'totalDistance': this.totalDistance,
      'totalOrderCount': this.totalOrderCount,
      'totalCancelled': this.totalCancelled,
    };
  }

  static AgentStatistic fromSnapshot(DocumentSnapshot request) {
    return AgentStatistic(
      updatedAt: request.data['updatedAt'],
      agent: request.data['agent'],
      totalUnitUsed: request.data['totalUnitUsed'],
      totalAmount: request.data['totalAmount'],
      totalDistance: request.data['totalDistance'],
      totalOrderCount: request.data['totalOrderCount'],
      totalCancelled: request.data['totalCancelled'],
    );
  }

  static List<AgentStatistic> fromListSnapshot(List<DocumentSnapshot> snap) {
    List<AgentStatistic> collection =[];
    snap.forEach((element) { collection.add(AgentStatistic.fromSnapshot(element));});
    return collection;
  }
}
