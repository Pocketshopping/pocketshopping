
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';

@immutable
class BusinessState {
  final bool isNameValid;
  final bool isAddressValid;
  final bool isTelephoneValid;
  final bool isCategoryValid;
  final bool isDeliveryValid;
  final bool isCaptureValid;
  final bool isSubmitting;
  final bool isUploading;
  final bool isSuccess;
  final bool isFailure;
  final String code;
  final Position position;
  final String isCapturing;
  final String delivery;
  final String category;



  bool get isFormValid => isAddressValid && isNameValid && isTelephoneValid
      && isDeliveryValid && isCaptureValid;

  BusinessState({
    @required this.isNameValid,
    @required this.isAddressValid,
    @required this.isTelephoneValid,
    @required this.isDeliveryValid,
    @required this.isCaptureValid,
    @required this.isCategoryValid,
    @required this.isUploading,
    @required this.isSubmitting,
    @required this.isSuccess,
    @required this.isFailure,
    @required this.code,
    @required this.category,
    this.position,
    this.isCapturing,
    this.delivery

  });

  factory BusinessState.empty() {
    return BusinessState(
      isNameValid:true,
      isTelephoneValid:true,
      isAddressValid: true,
      isCategoryValid: true,
      isCaptureValid: false,
      isDeliveryValid:true,
      code:'+234',
      position: null,
      isCapturing:'NO',
      delivery:'No',
      category: 'Restuarant',
      isUploading: false,
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,


    );
  }

  factory BusinessState.loading({
    bool isUploading,
    String code='+234',
    String delivery='No',
    String isCapturing='COMPLETED',
    Position position,
    String category='Restuarant'

  }) {
    return BusinessState(
      isNameValid:true,
      isTelephoneValid:true,
      isAddressValid: true,
      isCategoryValid: true,
      isCaptureValid: true,
      code:code,
      category: category,
      position: position,
      delivery: delivery,
      isCapturing:isCapturing,
      isDeliveryValid:true,
      isSubmitting: true,
      isUploading: isUploading,
      isSuccess: false,
      isFailure: false,
    );
  }


  factory BusinessState.failure(
      {

        bool isUploading,
        String code='+234',
        String delivery='No',
        String isCapturing='COMPLETED',
        Position position,
        String category='Restuarant'
      }
      ) {
    return BusinessState(
      isNameValid:true,
      isTelephoneValid:true,
      isAddressValid: true,
      isCategoryValid: true,
      isCaptureValid: true,
      code:code,
      category: category,
      position: position,
      delivery: delivery,
      isCapturing:isCapturing,
      isDeliveryValid:true,
      isSubmitting: false,
      isUploading: isUploading,
      isSuccess: false,
      isFailure: true,
    );
  }

  factory BusinessState.success(
  { String category='Restuarant'}
      ) {
    return BusinessState(
      isNameValid:true,
      isTelephoneValid:true,
      isAddressValid: true,
      isCategoryValid: true,
      isCaptureValid: true,
      isDeliveryValid:true,
      code:'+234',
      category: category,
      isCapturing:'COMPLETED',
      isSubmitting: false,
      isUploading: false,
      isSuccess: true,
      isFailure: false,
    );
  }

  BusinessState update({
    bool isAddressValid,
    bool isCategoryValid,
    bool isNameValid,
    bool isTelephoneValid,
    bool isDeliveryValid,
    bool isCaptureValid,
    String code,
    Position position,
    String password,
    bool isUploading,
    String isCapturing,
    String delivery,
    String category
  }) {
    return copyWith(
      isAddressValid: isAddressValid,
      isCategoryValid: isCategoryValid,
      isNameValid:isNameValid,
      isTelephoneValid:isTelephoneValid,
      isCaptureValid:isCaptureValid,
      isDeliveryValid:isDeliveryValid,
      code:code,
      category:category,
      delivery:delivery,
      isCapturing:isCapturing,
      position:position,
      isUploading: isUploading,
      password:password,
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  BusinessState copyWith({
    bool isAddressValid,
    bool isCategoryValid,
    bool isSubmitEnabled,
    bool isTelephoneValid,
    bool isDeliveryValid,
    bool isCaptureValid,
    bool isNameValid,
    String code,
    Position position,
    String password,
    bool isUploading,
    bool isSubmitting,
    bool isSuccess,
    bool isFailure,
    String isCapturing,
    String delivery,
    String category
  }) {
    return BusinessState(
      isAddressValid: isAddressValid ?? this.isAddressValid,
      isCategoryValid: isCategoryValid ?? this.isCategoryValid,
      isNameValid: isNameValid??this.isNameValid,
      isTelephoneValid:isTelephoneValid??this.isTelephoneValid,
      isDeliveryValid:isDeliveryValid??this.isDeliveryValid,
      isCaptureValid:isCaptureValid??this.isCaptureValid,
      code: code??this.code,
      category: category??this.category,
      delivery:delivery??this.delivery,
      isCapturing:isCapturing??this.isCapturing,
      position: position??this.position,
      isUploading: isUploading ?? this.isUploading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
    );
  }

  @override
  String toString() {
    return '''BusinessState {
    isTelephoneValid:$isTelephoneValid,
    isNameValid:$isNameValid
      isAddressValid: $isAddressValid,
      isCaptureValid,$isCaptureValid,
      isDeliveryValid: $isDeliveryValid,
      code: $code,
      delivery:$delivery,
      position:$position,
      isUploading: $isUploading,
      isCapturing:$isCapturing,
      isCategoryValid: $isCategoryValid,      
      isSubmitting: $isSubmitting,
      isSuccess: $isSuccess,
      isFailure: $isFailure,
    }''';
  }
}


class CCode extends BusinessState{
  final String code;

  CCode([this.code]);


  List<Object> get props => [code];

  @override
  String toString() => 'CountryCode { code: $code }';
}