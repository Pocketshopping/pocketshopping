import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketshopping/src/login/login.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';

class LoginScreen extends StatelessWidget {
  final UserRepository _userRepository;
  final bool fromSignup;
  final Uri linkdata;

  LoginScreen(
      {Key key,
      @required UserRepository userRepository,
      this.fromSignup = false,
      this.linkdata})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<LoginBloc>(
        create: (context) => LoginBloc(userRepository: _userRepository),
        child: LoginForm(
          userRepository: _userRepository,
          fromSignup: fromSignup,
          linkedData: linkdata,
        ),
      ),
    );
  }
}
