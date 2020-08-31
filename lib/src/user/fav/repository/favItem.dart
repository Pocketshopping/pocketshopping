import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';


@immutable
class FavItem {
  final int count;
  final Timestamp visitedAt;
  final String merchant;
  final String fid;
  final String uid;
  final String category;


  FavItem({

        this.count=0,
        this.visitedAt,
        this.merchant="",
        this.fid="",
        this.uid="",
        this.category=""
        });

  FavItem copyWith({
    Timestamp visitedAt,
    int count,
    String merchant,
    String fid,
    String uid,
    String category
  }) {
    return FavItem(
      visitedAt: visitedAt ?? this.visitedAt,
      count: count ?? this.count,
      merchant: merchant??this.merchant,
      fid: fid??this.fid,
      uid: uid??this.uid,
      category: category??this.category
    );
  }

  @override
  int get hashCode => visitedAt.hashCode ^ count.hashCode ^ merchant.hashCode ^ fid.hashCode ^ uid.hashCode ^category.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FavItem &&
              runtimeType == other.runtimeType &&
              visitedAt == other.visitedAt &&
              count == other.count &&
              merchant == other.merchant &&
              fid == other.fid &&
              uid == other.uid &&
              category == other.category;

  FavItem update({
    Timestamp visitedAt,
    int count,
    String merchant,
    String fid,
    String uid,
    String category
  }) {
    return copyWith(
      visitedAt: visitedAt,
      count: count,
      merchant: merchant,
      fid: fid,
      uid: uid,
      category: category

    );
  }

  @override
  String toString() {
    return '''Instance of FavItem''';
  }

  Map<String, dynamic> toMap() {
    return {
      'count':(count+1),
      'merchant':merchant,
      'visitedAt':Timestamp.now(),
      'fid':fid,
      'uid':uid,
      'category':category
    };
  }

  static FavItem fromSnap(DocumentSnapshot snap) {
    return FavItem(
        count: snap.data()['count'],
        visitedAt: snap.data()['visitedAt'],
        merchant: snap.data()['merchant'],
        uid: snap.data()['uid'],
        category: snap.data()['category'],
      fid: snap.id
    );
  }

}
