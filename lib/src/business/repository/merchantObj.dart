import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:pocketshopping/src/business/business.dart';


@immutable
class Merchant {

  final String bName;
  final String bEmail;
  final String bTelephone;
  final String bTelephone2;
  final String bUnique;
  final String bAddress;
  final Map<String,dynamic> bSocial;
  final String bDelivery;
  final String bCategory;
  final String bDescription;
  final dynamic bGeoPoint;
  final String bID;
  final String mID;
  final String bClose;
  final String bOpen;
  final DocumentReference bCreator;
  final DocumentReference bParent;
  final bool bIsBranch;
  final String bPhoto;
  final String bStatus;
  final Timestamp bCreatedAt;
  final String bCountry;




  Merchant( {
    this.bName = "",
    this.bEmail="",
    this.bTelephone="",
    this.bTelephone2="",
    this.bPhoto="",
    this.bAddress="",
    this.bCategory,
    this.mID="",
    this.bParent,
    this.bCountry,
    this.bID,
    this.bStatus,
    this.bSocial,
    this.bDescription,
    this.bDelivery,
    this.bClose,
    this.bCreatedAt,
    this.bCreator,
    this.bGeoPoint,
    this.bIsBranch,
    this.bOpen,
    this.bUnique
  });

  Merchant copyWith({
    String bName,
    String bEmail,
    String bTelephone,
    String bTelephone2,
    String bUnique,
    String bAddress,
    Map<String,dynamic> bSocial,
    String bDelivery,
    String bCategory,
    String bDescription,
    dynamic bGeoPoint,
    String bID,
    String mID,
    String bClose,
    String bOpen,
    DocumentReference bCreator,
    DocumentReference bParent,
    bool bIsBranch,
    String bPhoto,
    String bStatus,
    Timestamp bCreatedAt,
    String bCountry,

  }) {
    return Merchant(
      bName:bName??this.bName,
      bEmail:bEmail??this.bEmail,
      bTelephone:bTelephone??this.bTelephone,
      bTelephone2:bTelephone2??this.bTelephone2,
      bUnique:bUnique??this.bUnique,
      bAddress:bAddress??this.bAddress,
      bSocial:bSocial??this.bSocial,
      bDelivery:bDelivery??this.bDelivery,
      bCategory:bCategory??this.bCategory,
      bDescription:bDescription??this.bDescription,
      bGeoPoint:bGeoPoint??this.bGeoPoint,
      bID:bID??this.bID,
      mID:mID??this.mID,
      bClose:bClose??this.bClose,
      bOpen:bOpen??this.bOpen,
      bCreator:bCreator??this.bCreator,
      bParent:bParent??this.bParent,
      bIsBranch:bIsBranch??this.bIsBranch,
      bPhoto:bPhoto??this.bPhoto,
      bStatus:bStatus??this.bStatus,
      bCreatedAt:bCreatedAt??this.bCreatedAt,
      bCountry:bCountry??this.bCountry,
    );
  }


  @override
  int get hashCode =>
      bUnique.hashCode ^ bOpen.hashCode ^ bIsBranch.hashCode ^ bGeoPoint.hashCode ^ bCreator.hashCode ^
      bCreatedAt.hashCode ^ bClose.hashCode ^ bDelivery.hashCode ^ bDescription.hashCode ^ bSocial.hashCode ^
      bStatus.hashCode ^ bID.hashCode ^ bCountry.hashCode ^ bParent.hashCode ^ bTelephone2.hashCode ^
      bTelephone.hashCode ^ bName.hashCode ^ bAddress.hashCode ^ bOpen.hashCode ^ mID.hashCode ^ bCategory.hashCode
       ^ bPhoto.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Merchant &&
              runtimeType == other.runtimeType &&
              bName==other.bName &&
              bEmail==other.bEmail &&
              bTelephone==other.bTelephone &&
              bTelephone2==other.bTelephone2 &&
              bUnique==other.bUnique &&
              bAddress==other.bAddress &&
              bSocial==other.bSocial &&
              bDelivery==other.bDelivery &&
              bCategory==other.bCategory &&
              bDescription==other.bCategory &&
              bGeoPoint==other.bGeoPoint &&
              bID==other.bID &&
              mID==other.mID &&
              bClose==other.bClose &&
              bOpen==other.bOpen &&
              bCreator==other.bCreator &&
              bParent==other.bParent &&
              bIsBranch==other.bIsBranch &&
              bPhoto==other.bPhoto &&
              bStatus==other.bStatus &&
              bCreatedAt==other.bCreatedAt &&
              bCountry==other.bCountry;


  @override
  String toString() {
    return '''Merchnant   {
    bName:$bName ,
  bEmail:$bEmail ,
  bTelephone:$bTelephone ,
  bTelephone2:$bTelephone2 ,
  bUnique:$bUnique ,
  bAddress:$bAddress ,
  bSocial:$bSocial ,
  bDelivery:$bDelivery ,
  bCategory:$bCategory ,
  bDescription:$bDescription ,
  bGeoPoint:$bGeoPoint ,
  bID:$bID ,
  mID:$mID ,
  bClose:$bClose ,
  bOpen:$bOpen ,
  bCreator:$bCreator ,
  bParent:$bParent ,
  bIsBranch:$bIsBranch ,
  bPhoto:$bPhoto ,
  bStatus:$bStatus ,
  bCreatedAt:$bCreatedAt ,
  bCountry:$bCountry} ''';
  }

  MerchantEntity toEntity() {
    return MerchantEntity(
        bName,
        bEmail,
        bTelephone,
        bTelephone2,
        bPhoto,
        bAddress,
        bCategory,
        mID,
        bParent,
        bCountry,
        bID,
        bStatus,
        bSocial,
        bDescription,
        bDelivery,
        bClose,
        bCreatedAt,
        bCreator,
        bGeoPoint,
        bIsBranch,
        bOpen,
        bUnique
    );
  }

  static Merchant fromEntity(MerchantEntity merchant) {
    return Merchant(
      bName:merchant.bName??'',
      bEmail:merchant.bEmail??'',
      bTelephone:merchant.bTelephone??'',
      bTelephone2:merchant.bTelephone2??'',
      bUnique:merchant.bUnique??'',
      bAddress:merchant.bAddress??'',
      bSocial:merchant.bSocial??{},
      bDelivery:merchant.bDelivery??'',
      bCategory:merchant.bCategory??'',
      bDescription:merchant.bDescription??'',
      bGeoPoint:merchant.bGeoPoint,
      bID:merchant.bID??'',
      mID:merchant.mID??'',
      bClose:merchant.bClose??'',
      bOpen:merchant.bOpen??'',
      bCreator:merchant.bCreator,
      bParent:merchant.bParent,
      bIsBranch:merchant.bIsBranch??false,
      bPhoto:merchant.bPhoto??'',
      bStatus:merchant.bStatus??'',
      bCreatedAt:merchant.bCreatedAt,
      bCountry:merchant.bCountry??'',
    );
  }


}