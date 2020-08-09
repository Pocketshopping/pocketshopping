import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';
import 'package:pocketshopping/src/user/fav/repository/favItem.dart';
import 'package:pocketshopping/src/user/fav/repository/favObj.dart';

class FavRepo {
  static final databaseReference = Firestore.instance;

  static Future<void> save(String uid,String mid) async {
    try{
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
        await databaseReference.collection("favourite").document(data['fid']).setData(data)
            .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      }
    }
    catch(_){}
  }

  static Future<Favourite> getFavourites(String uid,String by,{int source=0}) async {
    try{
      if(source == 1)
        throw Exception;

      var doc = await databaseReference.collection("favourite")
          .where('uid',isEqualTo: uid)
          .orderBy(by,descending: true).getDocuments(source: Source.cache)
          .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
      print('cache');
      if(doc.documents.isNotEmpty){
        return Favourite.fromSnap(doc.documents);
      }
      else
        throw Exception;
    }
    catch(_){
      print('web');
      var doc = await databaseReference.collection("favourite")
          .where('uid',isEqualTo: uid)
          .orderBy(by,descending: true).getDocuments(source: Source.serverAndCache)
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return Favourite.fromSnap(doc.documents);
    }
  }

  static Future<Favourite> getFavourite(String uid,String mid) async {
    var doc = await databaseReference.collection("favourite")
        .where('uid',isEqualTo: uid)
        .where('merchant',isEqualTo: mid)
        .orderBy('count',descending: true).getDocuments(source: Source.serverAndCache)
        .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});

    if(doc.documents.isNotEmpty)
      return Favourite.fromSnap(doc.documents);
    else
      return Favourite(favourite: {});
  }


}
