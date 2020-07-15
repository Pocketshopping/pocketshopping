import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';
import 'package:pocketshopping/src/login/login.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';
import 'package:pocketshopping/src/ui/shared/psCard.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/validators.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:recase/recase.dart';

class LoginForm extends StatefulWidget {
  final UserRepository _userRepository;
  final bool fromSignup;
  final Uri linkedData;

  LoginForm(
      {Key key,
      @required UserRepository userRepository,
      this.fromSignup = false,
      this.linkedData})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginBloc _loginBloc;

  UserRepository get _userRepository => widget._userRepository;

  bool get isPopulated =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  bool isLoginButtonEnabled(LoginState state) {
    return state.isFormValid && isPopulated && !state.isSubmitting;
  }

  @override
  void initState() {
    super.initState();
    _loginBloc = BlocProvider.of<LoginBloc>(context);
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  Widget build(BuildContext context) {
    double marginLR = MediaQuery.of(context).size.width;
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.isFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text(state.errorMessage), Icon(Icons.error)],
                ),
                backgroundColor: Colors.red,
              ),
            );
        }
        if (state.isSubmitting) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                backgroundColor: PRIMARYCOLOR,
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Logging In...',
                      style: TextStyle(color: Colors.white),
                    ),
                    JumpingDotsProgressIndicator(
                      fontSize: MediaQuery.of(context).size.height * 0.05,
                      color: Colors.white,
                    )
                  ],
                ),
                duration: Duration(days: 365),
              ),
            );
        }
        if (state.isSuccess) {
          BlocProvider.of<AuthenticationBloc>(context).add(LoggedIn());
          if (widget.fromSignup) Get.back();
          //Navigator.pop(context);
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return ListView(
            padding: EdgeInsets.only(left: 0, right: 0),
            children: <Widget>[
              Center(
                  child: Container(
                      padding: EdgeInsets.only(
                          left: marginLR * 0.02, right: marginLR * 0.02),
                      margin: EdgeInsets.only(top: marginLR * 0.1),
                      child: psCard(
                          color: PRIMARYCOLOR,
                          title: 'Sign In',
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              //offset: Offset(1.0, 0), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ],
                          child: Form(
                              child: Column(children: <Widget>[
                                if(state.errorMessage == 'Email address has not been verified.')
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          //                   <--- left side
                                          color: Colors.black12,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    padding: EdgeInsets.all(
                                        MediaQuery.of(context).size.width * 0.02),
                                    child:
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text('Email address has not been verified. Click  Resend to get verification email.'),),
                                        Expanded(flex: 0,child: FlatButton(
                                          onPressed: (){},
                                          color: PRIMARYCOLOR,
                                          child: Text('Resend',style: TextStyle(color: Colors.white),),
                                        ),)
                                      ],
                                    )
                                  ),
                                ),
                              ),
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: Image.asset(
                                //placeholder: kTransparentImage,
                                'assets/images/blogo.png',
                                fit: BoxFit.cover,
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    //                   <--- left side
                                    color: Colors.black12,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width * 0.02),
                              child: TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  border: InputBorder.none,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                autovalidate: true,
                                autocorrect: false,
                                validator: (_) {
                                  return !state.isEmailValid
                                      ? 'Invalid Email'
                                      : null;
                                },
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    //                   <--- left side
                                    color: Colors.black12,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width * 0.02),
                              child: TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  border: InputBorder.none,
                                ),
                                obscureText: true,
                                autovalidate: true,
                                autocorrect: false,
                              ),
                            ),
                            Container(
                              child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: marginLR * 0.008,
                                      horizontal: marginLR * 0.08),
                                  child: RaisedButton(
                                    onPressed: isLoginButtonEnabled(state)
                                        ? _onFormSubmitted
                                        : null,
                                    padding: EdgeInsets.all(12),
                                    color: Color.fromRGBO(0, 21, 64, 1),
                                    child: Center(
                                      child: Text(state.isSubmitting?'Please wait...':'Sign In',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  )),
                            ),
                            Container(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    FlatButton(
                                      child: Text(
                                        'Reset Password',
                                      ),
                                      onPressed: () async{
                                        if(_emailController.text.isNotEmpty)
                                        {
                                          if(Validators.isValidEmail(_emailController.text))
                                          {
                                            Utility.bottomProgressLoader(title: 'Resetting Password',body: 'Please wait...'.sentenceCase);
                                            var result =await  _userRepository.passwordReset(_emailController.text);
                                            if(result == 1)
                                            {
                                              Get.back();
                                              Utility.bottomProgressSuccess(title: 'Password Reset',body: 'Check your mailbox for password reset link'.sentenceCase,duration: 5);
                                            }
                                            else if(result == 2)
                                            {
                                              Get.back();
                                              Utility.bottomProgressFailure(title: 'User Not Found.', body: 'No User With this email'.sentenceCase,duration: 5);
                                            }
                                            else
                                            {
                                              Get.back();
                                              Utility.bottomProgressFailure(title: 'Password Reset', body: 'Error resetting password, check your internet connection and try again'.sentenceCase,duration: 5);
                                            }
                                          }
                                          else{
                                            Utility.bottomProgressFailure(title: 'Email Address', body: 'Enter a Valid Email Address'.sentenceCase,duration: 3);
                                          }
                                        }
                                        else
                                          {
                                            Utility.bottomProgressFailure(title: 'Email Address', body: 'Enter Your Email Address'.sentenceCase,duration: 3);

                                          }

                                      },
                                    )
                                  ],
                                ),
                              ),
                            ),
                                Container(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        CreateAccountButton(
                                            userRepository: _userRepository),
                                      ],
                                    ),
                                  ),
                                ),
                          ]))))),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    _loginBloc.add(
      EmailChanged(email: _emailController.text),
    );
  }

  void _onPasswordChanged() {
    _loginBloc.add(
      PasswordChanged(password: _passwordController.text),
    );
  }

  void _onFormSubmitted() {
    _loginBloc.add(
      LoginWithCredentialsPressed(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }
}
