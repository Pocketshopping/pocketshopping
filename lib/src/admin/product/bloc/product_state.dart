import 'dart:io';

import 'package:meta/meta.dart';

@immutable
class ProductState {
  final bool isNameValid;
  final bool isPriceValid;
  final bool isCategoryValid;
  final List<File> croppedImage;
  final String barCode;
  final bool isUploading;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;
  final int count;

  bool get isFormValid => isPriceValid && isNameValid && isCategoryValid;

  ProductState({
    @required this.isNameValid,
    @required this.isPriceValid,
    @required this.isCategoryValid,
    @required this.isUploading,
    @required this.isSubmitting,
    @required this.isSuccess,
    @required this.isFailure,
    this.croppedImage,
    this.barCode,
    this.count,
  });

  factory ProductState.empty() {
    return ProductState(
      isNameValid: true,
      isPriceValid: true,
      isCategoryValid: true,
      croppedImage: [],
      barCode: '',
      count: 0,
      isUploading: false,
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory ProductState.loading({
    bool isUploading,
    List<File> croppedImage,
    String barCode = "",
    int count = 0,
  }) {
    return ProductState(
      isNameValid: true,
      isPriceValid: true,
      isCategoryValid: true,
      croppedImage: croppedImage,
      barCode: barCode,
      count: count,
      isSubmitting: true,
      isUploading: isUploading,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory ProductState.failure({
    bool isUploading,
    List<File> croppedImage,
    String barCode = "",
    int count = 0,
  }) {
    return ProductState(
      isNameValid: true,
      isPriceValid: true,
      isCategoryValid: true,
      croppedImage: croppedImage,
      barCode: barCode,
      count: count,
      isSubmitting: false,
      isUploading: isUploading,
      isSuccess: false,
      isFailure: true,
    );
  }

  factory ProductState.success() {
    return ProductState(
      croppedImage: [],
      barCode: "",
      count: 0,
      isNameValid: true,
      isPriceValid: true,
      isCategoryValid: true,
      isSubmitting: false,
      isUploading: false,
      isSuccess: true,
      isFailure: false,
    );
  }

  ProductState update({
    bool isPriceValid,
    bool isCategoryValid,
    bool isNameValid,
    List<File> croppedImage,
    bool isUploading,
    String barCode,
    int count,
  }) {
    return copyWith(
      isPriceValid: isPriceValid,
      isCategoryValid: isCategoryValid,
      isNameValid: isNameValid,
      croppedImage: croppedImage,
      barCode: barCode,
      count: count,
      isUploading: isUploading,
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  ProductState copyWith({
    bool isPriceValid,
    bool isCategoryValid,
    bool isSubmitEnabled,
    bool isNameValid,
    List<File> croppedImage,
    String barCode,
    int count,
    bool isUploading,
    bool isSubmitting,
    bool isSuccess,
    bool isFailure,
  }) {
    return ProductState(
      isPriceValid: isPriceValid ?? this.isPriceValid,
      isCategoryValid: isCategoryValid ?? this.isCategoryValid,
      isNameValid: isNameValid ?? this.isNameValid,
      croppedImage: croppedImage ?? this.croppedImage,
      barCode: barCode ?? this.barCode,
      count: count ?? this.count,
      isUploading: isUploading ?? this.isUploading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
    );
  }

  @override
  String toString() {
    return ''' Instance of <ProductState>''';
  }
}
