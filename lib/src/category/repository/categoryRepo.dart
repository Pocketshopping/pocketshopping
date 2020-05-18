import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/category/repository/merchatCategoryObj.dart';

import 'mCategoryEntity.dart';

class CategoryRepo {
  static final databaseReference = Firestore.instance;

  static Future<String> save(dynamic pcategory) async {
    DocumentReference bid;
    bid = await databaseReference.collection("category").add(pcategory.toMap());
    return bid.documentID;
  }

  static Future<List<MCategory>> getAll() async {
    List<MCategory> categories = List();
    var docs = await databaseReference
        .collection("categories")
        .orderBy('categoryView', descending: true)
        .getDocuments();
    docs.documents.forEach((element) {
      categories
          .add(MCategory.fromEntity(MCategoryEntity.fromSnapshot(element)));
    });
    return categories;
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
        .getDocuments();
    docs.documents.forEach((element) {
      options.add(element.data['key']);
    });
    return options;
  }
}
