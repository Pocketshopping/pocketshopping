import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/review/repository/ReviewEntity.dart';
import 'package:pocketshopping/src/review/repository/rating.dart';
import 'package:pocketshopping/src/review/repository/reviewObj.dart';

class ReviewRepo {
  static final databaseReference = Firestore.instance;

  static Future<String> save(Review review,{Rating rating}) async {
    try{
      DocumentReference doc;
      doc = await databaseReference.collection("reviews").add(review.toMap());
      if(rating != null)
      await updateRating(rating);
      return doc.documentID;
    }
    catch(_){
      return "";
    }
  }


  static Future<bool> updateRating(Rating rating) async {

    try{
      Rating rate = await getRating(rating.id);
      if(rate != null)
      {
        rate=rate.update(
          rating: Rating.calculate(oldCount: rate.rating,newCount: rating.rating),
          neutral: Rating.calculate(oldCount: rate.neutral,newCount: rating.neutral),
          positive: Rating.calculate(oldCount: rate.positive,newCount: rating.positive),
          negative: Rating.calculate(oldCount: rate.negative,newCount: rating.negative),
        );

        await databaseReference.collection("rating").document(rating.id).updateData(rate.toMap());
      }
      else{
        await databaseReference.collection("rating").document(rating.id).setData(rating.toMap());
      }


      return true;
    }
    catch(_){
      return false;
    }
  }


  static Future<Rating> getRating(String rid) async {
    if(rid == null)
      return null;
    if(rid.isEmpty)
      return null;


    var doc = await databaseReference.collection("rating").document(rid).get(source: Source.server);
    return doc.exists?Rating.fromSnap(doc):null;
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
