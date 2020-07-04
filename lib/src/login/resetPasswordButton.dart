import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/register/register.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';

class ResetPasswordButton extends StatelessWidget {
  final UserRepository _userRepository;

  ResetPasswordButton({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(
        'Reset Password',
      ),
      onPressed: () {
        Get.to(RegisterScreen(userRepository: _userRepository));
      },
    );
  }
}
