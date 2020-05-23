import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/review/repository/ReviewEntity.dart';
import 'package:pocketshopping/src/review/repository/reviewObj.dart';
import 'package:pocketshopping/src/user/fav/repository/favItem.dart';
import 'package:pocketshopping/src/user/fav/repository/favObj.dart';

class FavRepo {
  static final databaseReference = Firestore.instance;

  static Future<void> save(String uid,String mid) async {
    var fav = await getFavourite(uid, mid);
    if(fav.favourite.isEmpty)
      {
        await databaseReference.collection("favourite").add(
          FavItem(uid: uid,merchant: mid,fid: "").toMap()
        );
      }
    else
      {
        var data = fav.toFavItemMap(mid);
        await databaseReference.collection("favourite").document(data['fid']).setData(data);
      }
  }

  static Future<Favourite> getFavourites(String uid,String by) async {
    var doc = await databaseReference.collection("favourite")
        .where('uid',isEqualTo: uid)
        .orderBy(by,descending: true).getDocuments();
    return Favourite.fromSnap(doc.documents);
  }

  static Future<Favourite> getFavourite(String uid,String mid) async {
    var doc = await databaseReference.collection("favourite")
        .where('uid',isEqualTo: uid)
        .where('merchant',isEqualTo: mid)
        .orderBy('count',descending: true).getDocuments();

    if(doc.documents.isNotEmpty)
      return Favourite.fromSnap(doc.documents);
    else
      return Favourite(favourite: {});
  }


}
