import 'package:pocketshopping/model/DataModel/Data.dart';

class LoginDataModel extends Data {
  final String email;
  final String password;

  LoginDataModel({this.email = '', this.password = ''});

  String getEmail() {
    return email.trim();
  }

  String getPassword() {
    return password.trim();
  }

  @override
  save() {
    // TODO: implement save
    return true;
  }
}
