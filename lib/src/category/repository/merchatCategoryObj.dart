import 'package:meta/meta.dart';

import 'mCategoryEntity.dart';

@immutable
class MCategory {
  final String categoryName;
  final String categoryURI;
  final int categoryView;
  final String categoryId;
  final String desc;

  MCategory({
    this.categoryName,
    this.categoryURI,
    this.categoryView,
    this.categoryId,
    this.desc
  });

  MCategory copyWith({
    String categoryName,
    String categoryURI,
    int categoryView,
    String categoryId,
    String desc
  }) {
    return MCategory(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryURI: categoryURI ?? this.categoryURI,
      categoryView: categoryView ?? this.categoryView,
      desc: desc??this.desc
    );
  }

  @override
  int get hashCode =>
      categoryView.hashCode ^
      categoryURI.hashCode ^
      categoryName.hashCode ^
      categoryId.hashCode ^
      desc.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MCategory &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId &&
          categoryName == other.categoryName &&
          categoryURI == other.categoryURI &&
          categoryView == other.categoryView &&
          desc == other.desc;

  MCategory update({
    String categoryName,
    String categoryURI,
    int categoryView,
    String categoryId,
    String desc
  }) {
    return copyWith(
      categoryView: categoryView,
      categoryURI: categoryURI,
      categoryName: categoryName,
      categoryId: categoryId,
      desc: desc
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
      'categoryView': categoryView,
      'desc':desc
    };
  }

  static MCategory fromEntity(MCategoryEntity mCategoryEntity) {
    return MCategory(
      categoryId: mCategoryEntity.categoryId,
      categoryName: mCategoryEntity.categoryName,
      categoryURI: mCategoryEntity.categoryURI,
      categoryView: mCategoryEntity.categoryView,
      desc: mCategoryEntity.desc,
    );
  }
}
