import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:pocketshopping/src/utility/utility.dart';


@immutable
class Stock {
  final String productID;
  final String restockedBy;
  final bool isManaging;
  final Timestamp restockedAt;
  final String company;
  final int stockCount;
  final int lastRestockCount;
  final int frequency;
  final String product;

  Stock(
      {this.productID,
        this.restockedBy,
        this.isManaging,
        this.restockedAt,
        this.company,
        this.stockCount,
        this.lastRestockCount,
        this.frequency,
        this.product,

      });

  Stock copyWith({
    String productID,
    String restockedBy,
    bool isManaging,
    Timestamp restockedAt,
    String company,
    int stockCount,
    int lastRestockCount,
    int frequency,
    String product
  }) {
    return Stock(
      productID: productID ?? this.productID,
      restockedBy: restockedBy ?? this.restockedBy,
      isManaging: isManaging ?? this.isManaging,
      restockedAt: restockedAt ?? this.restockedAt,
      company: company ?? this.company,
      stockCount: stockCount ?? this.stockCount,
      lastRestockCount: lastRestockCount ?? this.lastRestockCount,
      frequency: frequency ?? this.frequency,
      product: product??this.product
    );
  }

  @override
  int get hashCode =>
      productID.hashCode ^
      restockedBy.hashCode ^
      isManaging.hashCode ^
      restockedAt.hashCode ^
      company.hashCode ^
      stockCount.hashCode ^
      lastRestockCount.hashCode ^
      frequency.hashCode ^
      product.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Stock &&
              runtimeType == other.runtimeType &&
              productID == other.productID &&
              restockedBy == other.restockedBy &&
              isManaging == other.isManaging &&
              restockedAt == other.restockedAt &&
              company == other.company &&
              stockCount == other.stockCount &&
              lastRestockCount == other.lastRestockCount &&
              frequency == other.frequency &&
              product == other.product;

  Stock update({
    String productID,
    String restockedBy,
    bool isManaging,
    Timestamp restockedAt,
    String company,
    int stockCount,
    int lastRestockCount,
    int frequency,
    String product,
  }) {
    return copyWith(
      productID: productID,
      restockedBy: restockedBy,
      isManaging: isManaging,
      restockedAt: restockedAt,
      company: company,
      stockCount: stockCount,
      lastRestockCount: lastRestockCount,
      frequency: frequency,
      product: product
    );
  }

  @override
  String toString() {
    return '''Instance of Stock''';
  }

  Map<String, dynamic> toMap() {
    return {
      'productID': productID,
      'restockedBy': restockedBy,
      'isManaging': isManaging,
      'restockedAt': Timestamp.now(),
      'company': company,
      'stockCount': stockCount,
      'lastRestockCount': lastRestockCount,
      'frequency': frequency,
      'product':product,
      'index':Utility.makeIndexList(product)
    };
  }

  static Stock fromSnap(DocumentSnapshot snap) {
    return Stock(
        productID: snap.data['productID'],
        restockedBy: snap.data['restockedBy'],
        isManaging: snap.data['isManaging'],
        restockedAt: snap.data['restockedAt'],
        company: snap.data['company'],
        lastRestockCount: snap.data['lastRestockCount'],
        stockCount: snap.data['stockCount'],
        frequency: snap.data['frequency'],
      product: snap.data['product'],
    );
  }

  static List<Stock> fromListSnap(List<DocumentSnapshot> snap) {
    List<Stock> collection = List();
    snap.forEach((element) {
      collection.add(Stock.fromSnap(element));
    });
    return collection;
  }
}
