import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/review/repository/ReviewEntity.dart';
import 'package:pocketshopping/src/review/repository/rating.dart';
import 'package:pocketshopping/src/review/repository/reviewObj.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';

class ReviewRepo {
  static final databaseReference = FirebaseFirestore.instance;

  static Future<String> save(Review review,{Rating rating}) async {
    try{
      DocumentReference doc;
      doc = await databaseReference.collection("reviews").add(review.toMap())
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      if(rating != null)
      await updateRating(rating);
      return doc.id;
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

        await databaseReference.collection("rating").doc(rating.id).update(rate.toMap())
            .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      }
      else{
        await databaseReference.collection("rating").doc(rating.id).set(rating.toMap())
            .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
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


    var doc = await databaseReference.collection("rating").doc(rid).get(GetOptions(source: Source.server))
        .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
    return doc.exists?Rating.fromSnap(doc):null;
  }

  static Future<Review> getOne(String rid,{int source=0}) async {
    if(rid == null)
      return null;
    if(rid.isEmpty)
      return null;
   try{
     try{
       if(source == 1)throw Exception;
       var doc = await databaseReference.collection("reviews").doc(rid).get(GetOptions(source: Source.serverAndCache))
           .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
       if(!doc.exists)throw Exception;
       return Review.fromEntity(ReviewEntity.fromSnapshot(doc));
     }
     catch(_){
       var doc = await databaseReference.collection("reviews").doc(rid).get(GetOptions(source: Source.serverAndCache))
           .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
       return Review.fromEntity(ReviewEntity.fromSnapshot(doc));
     }
   }
   catch(_){
     return null;
   }
  }
}
