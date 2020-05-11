import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketshopping/src/register/register.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';

class RegisterScreen extends StatelessWidget {
  final UserRepository _userRepository;
  final Uri linkdata;

  RegisterScreen({Key key, @required UserRepository userRepository,this.linkdata})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocProvider<RegisterBloc>(
          create: (context) => RegisterBloc(userRepository: _userRepository),
          child: RegisterForm(userRepository: _userRepository,linkdata: linkdata,),
        ),
      ),
    );
  }
}
