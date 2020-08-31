import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/category/repository/merchatCategoryObj.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';

import 'mCategoryEntity.dart';

class CategoryRepo {
  static final databaseReference = FirebaseFirestore.instance;

  static Future<String> save(dynamic pcategory) async {
    DocumentReference bid;
    bid = await databaseReference.collection("category").add(pcategory.toMap());
    return bid.id;
  }

  static Future<List<MCategory>> getAll({int source=0}) async {
   try{
     if(source == 1)
       throw Exception;
     List<MCategory> categories = List();
     var docs = await databaseReference
         .collection("categories")
         .orderBy('categoryView', descending: true)
         .get(GetOptions(source: Source.cache)).timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
     if(docs.docs.isNotEmpty){
       //print('category cache');
       docs.docs.forEach((element) {categories.add(MCategory.fromEntity(MCategoryEntity.fromSnapshot(element)));});
       return categories;
     }
     else
       {throw Exception;}

   }
   catch(_){
     //print('category web');
     List<MCategory> categories = List();
     var docs = await databaseReference
         .collection("categories")
         .orderBy('categoryView', descending: true)
         .get(GetOptions(source: Source.serverAndCache));
     docs.docs.forEach((element) {
       categories.add(MCategory.fromEntity(MCategoryEntity.fromSnapshot(element)));
     });
     return categories;
   }
  }

  static Future<List<String>> categoria() async {
    List<MCategory> categories = List();
    categories = await getAll();
    List<String> cname = List();
    categories.forEach((element) {
      cname.add(element.categoryName);
    });
    return cname;
  }

  static Future<List<String>> deliveria() async {
    List<String> options = List();
    var docs = await databaseReference
        .collection("delivery")
        .orderBy('sort')
        .where('enable', isEqualTo: true)
        .get(GetOptions(source: Source.serverAndCache));
    docs.docs.forEach((element) {
      options.add(element.data()['key']);
    });
    return options;
  }
}
