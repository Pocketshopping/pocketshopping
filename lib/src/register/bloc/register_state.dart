import 'package:meta/meta.dart';

@immutable
class RegisterState {
  final bool isNameValid;
  final bool isEmailValid;
  final bool isTelephoneValid;
  final bool isPasswordValid;
  final bool isConfirmPasswordValid;
  final bool isAgreedValid;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;
  final bool isNewUser;
  final String code;
  final String password;

  bool get isFormValid => isEmailValid && isPasswordValid && isNameValid && isTelephoneValid
  && isConfirmPasswordValid && isAgreedValid && isNewUser;

  RegisterState({
    @required this.isNameValid,
    @required this.isEmailValid,
    @required this.isTelephoneValid,
    @required this.isConfirmPasswordValid,
    @required this.isAgreedValid,
    @required this.isPasswordValid,
    @required this.isSubmitting,
    @required this.isSuccess,
    @required this.isFailure,
    @required this.isNewUser,
    @required this.code,
    @required this.password,
  });

  factory RegisterState.empty() {
    return RegisterState(
      isNameValid:true,
      isTelephoneValid:true,
      isEmailValid: true,
      isPasswordValid: true,
      isAgreedValid: false,
      isConfirmPasswordValid:true,
      code:'+234',
      password:'',
      isNewUser:true,
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,


    );
  }

  factory RegisterState.loading(
        {
    String code='+234'
}
      ) {
    return RegisterState(
      isNameValid:true,
      isTelephoneValid:true,
      isEmailValid: true,
      isPasswordValid: true,
      isAgreedValid: true,
      code:code,
      password:'',
      isConfirmPasswordValid:true,
      isNewUser:true,
      isSubmitting: true,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory RegisterState.failure(
      {
        String code='+234'
      }
      ) {
    return RegisterState(
      isNameValid:true,
      isTelephoneValid:true,
      isEmailValid: true,
      isPasswordValid: true,
      isAgreedValid: true,
      code:code,
      password:'',
      isConfirmPasswordValid:true,
      isNewUser:true,
      isSubmitting: false,
      isSuccess: false,
      isFailure: true,
    );
  }

  factory RegisterState.success() {
    return RegisterState(
      isNameValid:true,
      isTelephoneValid:true,
      isEmailValid: true,
      isPasswordValid: true,
      isAgreedValid: true,
      isConfirmPasswordValid:true,
      isNewUser:true,
      code:'+234',
      password:'',
      isSubmitting: false,
      isSuccess: true,
      isFailure: false,
    );
  }

  RegisterState update({
    bool isEmailValid,
    bool isPasswordValid,
    bool isNameValid,
    bool isTelephoneValid,
    bool isConfirmPasswordValid,
    bool isAgreedValid,
    bool isNewUser,
    String code,
    String password,
  }) {
    return copyWith(
      isEmailValid: isEmailValid,
      isPasswordValid: isPasswordValid,
      isNameValid:isNameValid,
      isTelephoneValid:isTelephoneValid,
      isAgreedValid:isAgreedValid,
      isConfirmPasswordValid:isConfirmPasswordValid,
      isNewUser:isNewUser,
      code:code,
      password:password,
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  RegisterState copyWith({
    bool isEmailValid,
    bool isPasswordValid,
    bool isSubmitEnabled,
    bool isTelephoneValid,
    bool isConfirmPasswordValid,
    bool isAgreedValid,
    bool isNameValid,
    String code,
    String password,
    bool isNewUser,
    bool isSubmitting,
    bool isSuccess,
    bool isFailure,
  }) {
    return RegisterState(
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isNameValid: isNameValid??this.isNameValid,
      isTelephoneValid:isTelephoneValid??this.isTelephoneValid,
      isConfirmPasswordValid:isConfirmPasswordValid??this.isConfirmPasswordValid,
      isAgreedValid:isAgreedValid??this.isAgreedValid,
      isNewUser:isNewUser??this.isNewUser,
      code: code??this.code,
      password:password??this.password,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
    );
  }

  @override
  String toString() {
    return '''RegisterState {
    isTelephoneValid:$isTelephoneValid,
    isNameValid:$isNameValid
      isEmailValid: $isEmailValid,
      isAgreedValid,$isAgreedValid,
      isConfirmPasswordValid: $isConfirmPasswordValid,
      isNewUser:$isNewUser,
      code: $code,
      isPasswordValid: $isPasswordValid,      
      isSubmitting: $isSubmitting,
      isSuccess: $isSuccess,
      isFailure: $isFailure,
    }''';
  }
  }


class CCode extends RegisterState{
  final String code;

   CCode([this.code]);


  List<Object> get props => [code];

  @override
  String toString() => 'CountryCode { code: $code }';
}