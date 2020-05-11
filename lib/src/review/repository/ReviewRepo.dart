import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/order/repository/confirmation.dart';
import 'package:pocketshopping/src/order/repository/order.dart';
import 'package:pocketshopping/src/order/repository/orderEntity.dart';
import 'package:pocketshopping/src/review/repository/reviewObj.dart';
import 'package:pocketshopping/src/review/repository/ReviewEntity.dart';

class ReviewRepo {
  static final databaseReference = Firestore.instance;

  static Future<String> save(Review review) async {
    DocumentReference bid;
    bid = await databaseReference.collection("reviews").add(review.toMap());
    return bid.documentID;
  }

  static Future<Review> getOne(String rid)async{
    var doc = await databaseReference.collection("reviews").document(rid).get();
    return Review.fromEntity(ReviewEntity.fromSnapshot(doc));
  }

}