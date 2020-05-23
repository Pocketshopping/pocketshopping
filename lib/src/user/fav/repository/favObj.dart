import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:pocketshopping/src/user/fav/repository/favItem.dart';

@immutable
class Favourite {
  final Map<String,FavItem> favourite;

  Favourite({this.favourite});

  Favourite copyWith({Map<String,FavItem> favourite}) {
    return Favourite(
      favourite: favourite ?? this.favourite,
    );
  }

  @override
  int get hashCode => favourite.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Favourite &&
              runtimeType == other.runtimeType &&
              favourite == other.favourite;

  Favourite update({
    Map<String,FavItem> favourite
  }) {
    return copyWith(
      favourite: favourite,
    );
  }

  @override
  String toString() {
    return '''Instance of  favourite''';
  }

  Map<String, dynamic> toMapAll() {
    return favourite;
  }

  Map<String, dynamic> toFavItemMap(String merchant) {
    return favourite[merchant].toMap();
  }

  static Favourite fromSnap(List<DocumentSnapshot> snap) {
    Map<String,FavItem> favourite={};
    snap.forEach(( value) {
      favourite[value.data['merchant']]=FavItem.fromSnap(value);
    });
    return Favourite(favourite: favourite,);
  }
}
