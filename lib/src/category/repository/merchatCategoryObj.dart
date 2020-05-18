import 'package:meta/meta.dart';

import 'mCategoryEntity.dart';

@immutable
class MCategory {
  final String categoryName;
  final String categoryURI;
  final int categoryView;
  final String categoryId;

  MCategory({
    this.categoryName,
    this.categoryURI,
    this.categoryView,
    this.categoryId,
  });

  MCategory copyWith({
    String categoryName,
    String categoryURI,
    int categoryView,
    String categoryId,
  }) {
    return MCategory(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryURI: categoryURI ?? this.categoryURI,
      categoryView: categoryView ?? this.categoryView,
    );
  }

  @override
  int get hashCode =>
      categoryView.hashCode ^
      categoryURI.hashCode ^
      categoryName.hashCode ^
      categoryId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MCategory &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId &&
          categoryName == other.categoryName &&
          categoryURI == other.categoryURI &&
          categoryView == other.categoryView;

  MCategory update({
    String categoryName,
    String categoryURI,
    int categoryView,
    String categoryId,
  }) {
    return copyWith(
      categoryView: categoryView,
      categoryURI: categoryURI,
      categoryName: categoryName,
      categoryId: categoryId,
    );
  }

  @override
  String toString() {
    return '''MCategory {MCategoryID: $categoryId,}''';
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryURI': categoryURI,
      'categoryView': categoryView
    };
  }

  static MCategory fromEntity(MCategoryEntity mCategoryEntity) {
    return MCategory(
      categoryId: mCategoryEntity.categoryId,
      categoryName: mCategoryEntity.categoryName,
      categoryURI: mCategoryEntity.categoryURI,
      categoryView: mCategoryEntity.categoryView,
    );
  }
}
