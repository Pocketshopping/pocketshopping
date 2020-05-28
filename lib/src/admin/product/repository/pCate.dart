import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

@immutable
class ProductCategory {
  final String mid;
  final List<String> productCategory;
  final Timestamp productInsertedAt;


  ProductCategory({
        this.mid,
        this.productCategory,
        this.productInsertedAt,
        });

  ProductCategory copyWith({
        String mid,
        List<String> productCategory,
        Timestamp productInsertedAt,
        }) {
    return ProductCategory(
        mid: mid ?? this.mid,
        productCategory: productCategory ?? this.productCategory,
        productInsertedAt: productInsertedAt ?? this.productInsertedAt,
    );
  }

  @override
  int get hashCode =>
      mid.hashCode ^
      productCategory.hashCode ^
      productInsertedAt.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ProductCategory &&
              runtimeType == other.runtimeType &&
              mid == other.mid &&
              productCategory == other.productCategory &&
              productInsertedAt == other.productInsertedAt;

  ProductCategory update(
      {

        String mid,
        List<String> productCategory,
        Timestamp productInsertedAt,
}) {
    return copyWith(
        mid: mid,
        productCategory: productCategory,
        productInsertedAt: productInsertedAt,
        );
  }

  @override
  String toString() {
    return '''Instance of ProductCategory''';
  }

  Map<String, dynamic> toMap(String category) {
    productCategory.add(category);
    var data = productCategory.toSet();
    return {
      'mid': mid,
      'productCategory': data.toList(),
      'productInsertedAt': Timestamp.now(),
    };
  }

  static ProductCategory fromSnap(DocumentSnapshot snap) {
    return ProductCategory(
      mid: snap.documentID??'',
      productCategory: (snap.data['productCategory'] as List<String>)??[],
      productInsertedAt: snap.data['productInsertedAt'],
    );
  }
}
