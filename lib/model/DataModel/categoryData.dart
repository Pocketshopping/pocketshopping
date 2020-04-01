import 'package:pocketshopping/model/DataModel/Data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';



class CategoryData extends Data{

  @override
  Future<List<String>> getAll()async {
    List<String> categories=[];
    /*SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('categories')){
      categories.addAll(prefs.getStringList('categories'));
    }
    else{*/
      var document = await Firestore.instance.collection('categories').orderBy('sort').getDocuments();
      document.documents.forEach((doc) {
        categories.add(doc.data['title']);
      });
      /*prefs.setStringList('categories', categories);
    }*/

    return categories;
  }

  Future<int> getLength()async{
    var document = await Firestore.instance.collection('categories').getDocuments();
    return document.documents.length;
  }

}

