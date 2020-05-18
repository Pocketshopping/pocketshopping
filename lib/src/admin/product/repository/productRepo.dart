import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:recase/recase.dart';

class ProductRepo {
  final databaseReference = Firestore.instance;

  Future<String> save({
    String mID,
    String pName,
    double pPrice,
    String pCategory,
    String pDesc,
    List<String> pPhoto,
    String pGroup,
    int pStockCount,
    String pQRCode,
    String pUploader,
    String pUnit,
  }) async {
    var bid = await databaseReference.collection("products").add({
      'productMerchant': databaseReference.document('merchants/$mID'),
      'productName': pName.sentenceCase,
      'productPrice': pPrice,
      'productCategory': pCategory.sentenceCase,
      'productDesc': pDesc.sentenceCase,
      'productPhoto': pPhoto,
      'productGroup': pGroup,
      'productStockCount': pStockCount,
      'productQRCode': pQRCode,
      'productUploader': pUploader,
      'productUnit': pUnit.toUpperCase(),
      'productCreatedAt': DateTime.now(),
      'index': makeIndexList(pName),
    });

    await saveCategory(pCategory, mID);
    await saveProductStock(bid.documentID, pUploader, pStockCount);

    return bid.documentID;
  }

  Future<String> saveCategory(String pCategory, String mid) async {
    String bid = "";
    //var cat= await databaseReference.collection("productsCategory").document(pCategory).get(source: Source.server);

    //if(cat.data.length>0){
    await databaseReference
        .collection("productsCategory")
        .document(pCategory)
        .setData({
      'productCategory': pCategory,
      'updatedAt': DateTime.now(),
      'productMerchant': [mid],
    }, merge: true);
    /*}
    else{
      await databaseReference.collection("productsCategory").document(pCategory)
          .setData({
        'productCategory':pCategory,
        'updatedAt':DateTime.now(),
        'productMerchant':[mid],

      });
    }*/

    return bid;
  }

  Future<String> saveProductStock(
    String pid,
    String pUploader,
    int pStockCount,
  ) async {
    String bid = "";
    await databaseReference.collection("productStock").add({
      'productID': databaseReference.document('products/$pid'),
      'restockedBy': pUploader,
      'restockCount': pStockCount,
      'oldStockCount': 0,
      'StockCount': pStockCount,
      'restockedAt': DateTime.now(),
    }).then((value) => bid = value.documentID.toString());

    return bid;
  }

  List<String> makeIndexList(String pName) {
    List<String> indexList = [];
    var temp = pName.split(' ');
    for (int i = 0; i < temp.length; i++) {
      for (int y = 1; y < temp[i].length + 1; y++) {
        indexList.add(temp[i].substring(0, y).toLowerCase());
      }
    }
    return indexList;
  }

  Future<Map<String, dynamic>> getOne(String pID) async {
    var document =
        await Firestore.instance.collection('products').document(pID).get();
    return document.data;
  }

  Stream<int> getCount(String mID) {
    var businessRef = databaseReference.document('merchants/$mID');
    return Firestore.instance
        .collection('products')
        .where('productMerchant', isEqualTo: businessRef)
        .snapshots()
        .map((element) {
      return element.documents.length;
    });
  }

  Future<List<String>> getCategory(String pCategory) async {
    List<String> suggestion = List();
    var document = await Firestore.instance
        .collection('productsCategory')
        .where('productCategory', isGreaterThanOrEqualTo: pCategory)
        .where('productCategory', isLessThan: pCategory + 'z')
        .getDocuments();
    document.documents.forEach((element) {
      suggestion.add(element.documentID);
    });
    // print(suggestion);
    return suggestion;
  }

  Future<List<Product>> fetchProduct(
      String mID, dynamic lastDoc, String category) async {
    var mRef = Firestore.instance.document('merchants/$mID');
    List<Product> tmp = List();
    var document;

    if (lastDoc == null) {
      document = await Firestore.instance
          .collection('products')
          .orderBy('productCreatedAt', descending: true)
          .where('productMerchant', isEqualTo: mRef)
          .where('productCategory', isEqualTo: category)
          .limit(10)
          .getDocuments();
    } else {
      //print(lastDoc !=null ?DateTime.parse(lastDoc.pCreatedAt.toDate().toString()):'');
      document = await Firestore.instance
          .collection('products')
          .orderBy('productCreatedAt', descending: true)
          .where('productMerchant', isEqualTo: mRef)
          .where('productCategory', isEqualTo: category)
          .startAfter([DateTime.parse(lastDoc.pCreatedAt.toDate().toString())])
          .limit(10)
          .getDocuments();
    }

    document.documents.forEach((element) {
      tmp.add(Product.fromEntity(ProductEntity.fromSnapshot(element)));
    });
    print(tmp.length);

    return tmp;
  }

  Future<List<Product>> SearchProduct(
      String mID, dynamic lastDoc, String search) async {
    var mRef = Firestore.instance.document('merchants/$mID');
    List<Product> tmp = List();
    var document;

    if (lastDoc == null) {
      document = await Firestore.instance
          .collection('products')
          .where('productMerchant', isEqualTo: mRef)
          .where('index', arrayContains: search.toLowerCase())
          .limit(10)
          .getDocuments();
    } else {
      print(lastDoc != null
          ? DateTime.parse(lastDoc.pCreatedAt.toDate().toString())
          : '');
      document = await Firestore.instance
          .collection('products')
          .where('productMerchant', isEqualTo: mRef)
          .where('index', arrayContains: search.toLowerCase())
          .startAfter([DateTime.parse(lastDoc.pCreatedAt.toDate().toString())])
          .limit(10)
          .getDocuments();
      print('length: ${document.documents.length}');
    }

    document.documents.forEach((element) {
      tmp.add(Product.fromEntity(ProductEntity.fromSnapshot(element)));
    });
    print(tmp.length);

    return tmp;
  }
}
