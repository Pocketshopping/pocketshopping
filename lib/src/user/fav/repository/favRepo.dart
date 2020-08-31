import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';
import 'package:pocketshopping/src/user/fav/repository/favItem.dart';
import 'package:pocketshopping/src/user/fav/repository/favObj.dart';

class FavRepo {
  static final databaseReference = FirebaseFirestore.instance;

  static Future<void> save(String uid,String mid,String category) async {
    try{
      var fav = await getFavourite(uid, mid);
      if(fav.favourite.isEmpty)
      {
        await databaseReference.collection("favourite").add(
            FavItem(uid: uid,merchant: mid,fid: "",category: category).toMap()
        );
      }
      else
      {
        var data = fav.toFavItemMap(mid);
        await databaseReference.collection("favourite").doc(data['fid']).set(data)
            .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      }
    }
    catch(_){}
  }

  static Future<Favourite> getFavourites(String uid,String by,{int source=0,String category='merchant'}) async {
    try{
      if(source == 1)
        throw Exception;

      var doc = await databaseReference.collection("favourite")
          .where('uid',isEqualTo: uid)
          .where('category',isEqualTo: category)
          .orderBy(by,descending: true).get(GetOptions(source: Source.cache))
          .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
      if(doc.docs.isNotEmpty){
        return Favourite.fromSnap(doc.docs);
      }
      else
        throw Exception;
    }
    catch(_){
      var doc = await databaseReference.collection("favourite")
          .where('uid',isEqualTo: uid)
          .where('category',isEqualTo: category)
          .orderBy(by,descending: true).get(GetOptions(source: Source.serverAndCache))
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return Favourite.fromSnap(doc.docs);
    }
  }

  static Future<Favourite> getFavourite(String uid,String mid) async {
    var doc = await databaseReference.collection("favourite")
        .where('uid',isEqualTo: uid)
        .where('merchant',isEqualTo: mid)
        .orderBy('count',descending: true).get(GetOptions(source: Source.serverAndCache))
        .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});

    if(doc.docs.isNotEmpty)
      return Favourite.fromSnap(doc.docs);
    else
      return Favourite(favourite: {});
  }


}
