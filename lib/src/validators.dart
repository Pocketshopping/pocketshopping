import 'package:flux_validator_dart/flux_validator_dart.dart';

class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );
  static final RegExp _passwordRegExp = RegExp(
    r"/^[a-zA-Z0-9!@#$%^&*()_+\-=\[\]{};':\\|,.<>\/?]*$/"
  );

  static isValidEmail(String email) {
    return !Validator.email(email);
  }

  static isValidPrice(double price) {
    return !Validator.number(price);
  }

  static isValidAmount(String price) {
    return !Validator.number(price);
  }

  static isValidPassword(String password) {
    return true;
    //return _passwordRegExp.hasMatch(password);
  }

  static isValidConfirmPassword(String password, String cpassword) {
    return password == cpassword;
  }

  static isValidName(String name) {
    return RegExp(r'^[a-zA-Z\s.-]+$').hasMatch(name);
  }

  static isValidAddress(String name) {
    return RegExp(r'^[a-zA-Z0-9,\s]+$').hasMatch(name);
  }

  static isValidTelephone(String telephone, {String ccode}) {
    //print('validator ccode $ccode');
    String code = ccode ?? '+234';
    if (code.toString() == '+234') {
      if (telephone.length < 11)
        return false;
      else
        return true;
    } else {
      if (telephone.length < 6)
        return false;
      else
        return true;
    }
  }
}
