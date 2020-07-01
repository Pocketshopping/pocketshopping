import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/review/repository/ReviewEntity.dart';
import 'package:pocketshopping/src/review/repository/reviewObj.dart';

class ReviewRepo {
  static final databaseReference = Firestore.instance;

  static Future<String> save(Review review) async {
    DocumentReference bid;
    bid = await databaseReference.collection("reviews").add(review.toMap());
    return bid.documentID;
  }

  static Future<Review> getOne(String rid) async {
    if(rid == null)
      return null;
    if(rid.isEmpty)
      return null;


    var doc = await databaseReference.collection("reviews").document(rid).get(source: Source.serverAndCache);
    return Review.fromEntity(ReviewEntity.fromSnapshot(doc));
  }
}
