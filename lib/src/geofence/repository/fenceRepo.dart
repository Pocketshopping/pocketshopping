import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/business/business.dart';

class FenceRepo {
  static final databaseReference = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  static final Geoflutterfire geo = Geoflutterfire();
  static final double radius = 50;
  static final String field = 'businessGeopint';
  static final String pfield = 'productGeoPoint';


  static Stream<List<Merchant>> nearByMerchants(Position position,String category)async* {
    List<Merchant> data = List();
    GeoFirePoint center = geo.point(
        latitude: position.latitude, longitude: position.longitude);
    var collectionReference = databaseReference
        .collection('merchants')
        .where('businessActive', isEqualTo: true)
        .where('index',arrayContains: category)
        .limit(20);
    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: field, strictMode: true);

   /* stream.listen((event) {
      data.addAll(Merchant.fromListEntity(MerchantEntity.fromListSnapshot(event)));
    }
      );*/
    yield* stream.map((event) => Merchant.fromListEntity(MerchantEntity.fromListSnapshot(event)));
    //return data;

  }


  static Future<List<Merchant>> nearByLogistic(Position position,Merchant last,{bool onlyLogistic=true})async {
    List<Merchant> data = List();
    GeoFirePoint center = geo.point(latitude: position.latitude, longitude: position.longitude);
    var collectionReference;

    if(onlyLogistic){
      collectionReference = databaseReference
          .collection('merchants')
          .where('businessActive', isEqualTo: true)
          .where('businessCategory',isEqualTo: "Logistic")
          .limit(50);
    }
    else{
      collectionReference = databaseReference
          .collection('merchants')
          .where('businessActive', isEqualTo: true)
          .where('index',arrayContains: "Logistic".toLowerCase())
          .limit(50);
    }

    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: 50, field: field, strictMode: true);
    data.addAll(Merchant.fromListEntity(MerchantEntity.fromListSnapshot(await stream.first)));
    return data;



  }

  static Future<List<Merchant>> searchNearByLogistic(Position position,String keyword,)async {
    List<Merchant> data = List();
    GeoFirePoint center = geo.point(
        latitude: position.latitude, longitude: position.longitude);
      var collectionReference = databaseReference
          .collection('merchants')
          .where('businessActive', isEqualTo: true)
          .where('businessCategory',isEqualTo: "Logistic")
          .where('index',arrayContains: keyword)
          .limit(50);
    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: 50, field: field, strictMode: true);
    data.addAll(Merchant.fromListEntity(MerchantEntity.fromListSnapshot(await stream.first)));
    return data;

  }

  static Stream<List<Product>> nearByProduct(Position position,String category)async* {
    List<Product> data = List();
    GeoFirePoint center = geo.point(latitude: position.latitude, longitude: position.longitude);
    var pcollectionReference = databaseReference
        .collection('products')
        .where('productAvailability', isEqualTo: 1)
        .where('productStatus', isEqualTo: 1)
        .where('index',arrayContains: category)
        .limit(20);
    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: pcollectionReference)
        .within(center: center, radius: radius, field: pfield, strictMode: true);

    /*stream.listen((event) {

      data.addAll(Product.fromListEntity(ProductEntity.fromListSnapshot(event)));
    }
    );*/

    yield* stream.map((event) => Product.fromListEntity(ProductEntity.fromListSnapshot(event)));
    //return data;

  }


}