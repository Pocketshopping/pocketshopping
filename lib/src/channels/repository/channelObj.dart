import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';


@immutable
class Channels {
  final List<dynamic> oChannels;
  final List<dynamic> mChannels;
  final List<dynamic> dChannels;
  final List<dynamic> cChannels;

  Channels(
      {
        this.oChannels,
        this.mChannels,
        this.dChannels,
        this.cChannels
      });

  Channels copyWith(
      {
        List<dynamic> oChannels,
        List<dynamic> mChannels,
        List<dynamic> dChannels,
        List<dynamic> cChannels,
      }) {
    return Channels(
      oChannels: oChannels??this.oChannels,
      mChannels: mChannels??this.mChannels,
      dChannels: dChannels??this.dChannels,
      cChannels: cChannels??this.cChannels,
    );
  }

  @override
  int get hashCode =>
      oChannels.hashCode ^ mChannels.hashCode ^ dChannels.hashCode ^ cChannels.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Channels &&
              runtimeType == other.runtimeType &&
              oChannels == other.oChannels &&
              mChannels == other.mChannels &&
              dChannels == other.dChannels &&
              cChannels == other.cChannels;

  Channels update(
      {
        List<dynamic> oChannels,
        List<dynamic> mChannels,
        List<dynamic> dChannels,
        List<dynamic> cChannels,
      }) {
    return copyWith(
      oChannels: oChannels,
      mChannels: mChannels,
      dChannels: dChannels,
      cChannels: cChannels,
    );
  }

  @override
  String toString() {
    return '''Channels ${oChannels.isNotEmpty && mChannels.isNotEmpty && dChannels.isNotEmpty && cChannels.isNotEmpty}''';
  }

  static List<String> oChannelsToList(Map<String,dynamic> channel){
    return channel.values.toList();
  }

  //Map<String, dynamic> toMap() {
    //return {
      //'categoryId':categoryId,
      //'categoryName':categoryName,
      //'categoryURI':categoryURI,
      //'categoryView':categoryView
    //};
  //}

  static Map<String,dynamic> toUpdate(DocumentSnapshot snap,String uid, String newToken) {
    Map<String,dynamic> Ordering={};
    Map<String,dynamic> Messaging={};
    Map<String,dynamic> Delivery={};
    Map<String,dynamic> Cashier={};
    bool shouldUpdateOrdering=false;
    bool shouldUpdateMessaging=false;
    bool shouldUpdateDelivery=false;
    bool shouldUpdateCashier = false;
    Map<String,dynamic> toUpdate={};

    Ordering = snap.data['Ordering'] as Map<String,dynamic> ;
    Messaging = snap.data['Messaging'] as Map<String,dynamic>;
    Delivery = snap.data['Delivery&Pickup'] as Map<String,dynamic>;
    Cashier = snap.data['Cashier'] as Map<String,dynamic>;

    if(Ordering.containsKey(uid)){
      Ordering.update(uid, (value) => newToken);
      shouldUpdateOrdering = true;
    }
    if(Messaging.containsKey(uid)){
      Messaging.update(uid, (value) => newToken);
      shouldUpdateMessaging = true;
    }
    if(Delivery.containsKey(uid)){
      Delivery.update(uid, (value) => newToken);
      shouldUpdateDelivery = true;
    }
    if(Cashier.containsKey(uid)){
      Cashier.update(uid, (value) => newToken);
      shouldUpdateCashier = true;
    }

    if(shouldUpdateOrdering)
      toUpdate['Ordering']=Ordering;
    if(shouldUpdateMessaging)
      toUpdate['Messaging']=Messaging;
    if(shouldUpdateDelivery)
      toUpdate['Delivery&Pickup']=Delivery;
    if(shouldUpdateCashier)
      toUpdate['Cashier']=Cashier;

    return toUpdate;




  }



  static Channels fromSnap(DocumentSnapshot snap) {
    return Channels(
      oChannels: (snap.data['Ordering'] as Map<String,dynamic>).values.toList(),
      mChannels: (snap.data['Messaging'] as Map<String,dynamic>).values.toList(),
      dChannels: (snap.data['Delivery&Pickup'] as Map<String,dynamic>).values.toList(),
      cChannels: (snap.data['Cashier'] as Map<String,dynamic>).values.toList()

    );
  }
}
