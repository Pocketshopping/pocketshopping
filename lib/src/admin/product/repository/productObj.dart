import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:pocketshopping/src/admin/product/product.dart';

@immutable
class Product {
  final String pID;
  final DocumentReference mID;
  final String pName;
  final double pPrice;
  final String pCategory;
  final String pDesc;
  final List<dynamic> pPhoto;
  final String pGroup;
  final int pStockCount;
  final String pQRCode;
  final String pUploader;
  final String pUnit;
  final Timestamp pCreatedAt;
  final int status;
  final int availability;
  final dynamic geoPoint;
  final bool isManaging;

  Product(
      {this.pID,
      this.mID,
      this.pName,
      this.pPrice,
      this.pCategory,
      this.pDesc,
      this.pPhoto,
      this.pGroup,
      this.pStockCount,
      this.pQRCode,
      this.pUploader,
      this.pUnit,
      this.pCreatedAt,
      this.status,
      this.availability,
      this.geoPoint,
      this.isManaging
      });

  Product copyWith(
      {String pID,
      DocumentReference mID,
      String pName,
      double pPrice,
      String pCategory,
      String pDesc,
      List<dynamic> pPhoto,
      String pGroup,
      int pStockCount,
      String pQRCode,
      String pUploader,
      String pUnit,
      Timestamp pCreatedAt,
      int status,
      int availability,
      dynamic geoPoint,
      bool isManaging,
      }) {
    return Product(
        pID: pID ?? this.pID,
        mID: mID ?? this.mID,
        pPrice: pPrice ?? this.pPrice,
        pCategory: pCategory ?? this.pCategory,
        pDesc: pDesc ?? this.pDesc,
        pPhoto: pPhoto ?? this.pPhoto,
        pGroup: pGroup ?? this.pGroup,
        pStockCount: pStockCount ?? this.pStockCount,
        pQRCode: pQRCode ?? this.pQRCode,
        pUploader: pUploader ?? this.pUploader,
        pUnit: pUnit ?? this.pUnit,
        pCreatedAt: pCreatedAt ?? this.pCreatedAt,
        pName: pName ?? this.pName,
        status: status??this.status,
        availability: availability??this.availability,
        geoPoint: geoPoint??this.geoPoint,
      isManaging: isManaging??this.isManaging,
    );
  }

  @override
  int get hashCode =>
      pID.hashCode ^
      mID.hashCode ^
      pName.hashCode ^
      pPrice.hashCode ^
      pCategory.hashCode ^
      pDesc.hashCode ^
      pPhoto.hashCode ^
      pGroup.hashCode ^
      pStockCount.hashCode ^
      pQRCode.hashCode ^
      pUploader.hashCode ^
      pUnit.hashCode ^
      pCreatedAt.hashCode ^
      status.hashCode ^
      availability.hashCode ^
      geoPoint.hashCode ^
      isManaging.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          pID == other.pID &&
          mID == other.mID &&
          pName == other.pName &&
          pPrice == other.pPrice &&
          pCategory == other.pCategory &&
          pDesc == other.pDesc &&
          pPhoto == other.pPhoto &&
          pGroup == other.pGroup &&
          pStockCount == other.pStockCount &&
          pQRCode == other.pQRCode &&
          pUploader == other.pUploader &&
          pUnit == other.pUnit &&
          pCreatedAt == other.pCreatedAt &&
          status == other.status &&
          availability == other.availability &&
          geoPoint == other.geoPoint && isManaging == other.isManaging;

  @override
  String toString() {
    return '''Instance of Product ''';
  }

  ProductEntity toEntity() {
    return ProductEntity(pID, mID, pName, pPrice, pCategory, pDesc, pPhoto,
        pGroup, pStockCount, pQRCode, pUploader, pUnit, pCreatedAt,status,availability,geoPoint,isManaging);
  }

  static Product fromEntity(ProductEntity product) {
    return Product(
      pID: product.pID ?? '',
      mID: product.mID ?? '',
      pName: product.pName ?? '',
      pPrice: product.pPrice ?? 0.0,
      pCategory: product.pCategory ?? '',
      pDesc: product.pDesc ?? '',
      pPhoto: product.pPhoto,
      pGroup: product.pGroup ?? '',
      pStockCount: product.pStockCount ?? 1,
      pQRCode: product.pQRCode ?? '',
      pUploader: product.pUploader ?? '',
      pUnit: product.pUnit ?? '',
      pCreatedAt: product.pCreatedAt,
      status: product.status,
      availability: product.availability,
      geoPoint: product.geoPoint,
      isManaging: product.isManaging
    );
  }

  List<dynamic> toList(Product product) {
    List<dynamic> snap = List();
    snap.add(product.mID);
    snap.add(product.pName);
    snap.add(product.pPrice);
    snap.add(product.pCategory);
    snap.add(product.pDesc);
    snap.add(product.pPhoto);
    snap.add(product.pGroup);
    snap.add(product.pStockCount);
    snap.add(product.pQRCode);
    snap.add(product.pUploader.toString());
    snap.add(product.pUnit);
    snap.add(product.pCreatedAt);
    snap.add(product.status);
    snap.add(product.availability);
    snap.add(product.geoPoint);
    snap.add(product.isManaging);
    return snap;
  }

  static List<Product> fromListEntity(List<ProductEntity> product) {
    return product.map((e) => Product.fromEntity(e)).toList();
  }
}
