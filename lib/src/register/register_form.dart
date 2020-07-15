import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';
import 'package:pocketshopping/src/login/login.dart' as login;
import 'package:pocketshopping/src/register/register.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';
import 'package:pocketshopping/src/ui/shared/psCard.dart';
import 'package:progress_indicators/progress_indicators.dart';

class RegisterForm extends StatefulWidget {
  final UserRepository _userRepository;
  final Uri linkdata;

  RegisterForm(
      {Key key, @required UserRepository userRepository, this.linkdata})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  RegisterBloc _registerBloc;

  bool get isPopulated =>
      _emailController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _nameController.text.isNotEmpty &&
      _telephoneController.text.isNotEmpty &&
      _confirmPasswordController.text.isNotEmpty;

  UserRepository get _userRepository => widget._userRepository;

  bool isRegisterButtonEnabled(RegisterState state) {
    return state.isFormValid && isPopulated && !state.isSubmitting;
  }

  @override
  void initState() {
    super.initState();
    _registerBloc = BlocProvider.of<RegisterBloc>(context);
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
    _nameController.addListener((_onNameChanged));
    _telephoneController.addListener((_onTelephoneChanged));
    _confirmPasswordController.addListener((_onConfirmPasswordChanged));
    //print(widget.linkdata.queryParameters['referralID']);
  }

  @override
  Widget build(BuildContext context) {
    double marginLR = MediaQuery.of(context).size.width;
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
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
                      'Registering...',
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
          if (widget.linkdata != null) {
            if (widget.linkdata.queryParameters.containsKey('referralID')) {
              BlocProvider.of<AuthenticationBloc>(context).add(Verify());
              Get.back();
            } else {
              BlocProvider.of<AuthenticationBloc>(context).add(DeepLink(widget.linkdata));
              Get.back();
            }
          } else {
            BlocProvider.of<AuthenticationBloc>(context).add(Verify());
            Get.back();
          }
        }
        if (state.isFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Registration Failure'),
                    Icon(Icons.error),
                  ],
                ),
                backgroundColor: Colors.red,
              ),
            );
        }
      },
      child: BlocBuilder<RegisterBloc, RegisterState>(
        builder: (context, state) {
          return Container(
            padding:
                EdgeInsets.only(left: marginLR * 0.01, right: marginLR * 0.01),
            margin: EdgeInsets.only(top: marginLR * 0.05),
            child: ListView(
              //crossAxisAlignment: CrossAxisAlignment.center,
              //mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                    child: psCard(
                        color: PRIMARYCOLOR,
                        title: 'SignUp',
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            //offset: Offset(1.0, 0), //(x,y)
                            blurRadius: 6.0,
                          ),
                        ],
                        child: Form(
                            child: Column(children: <Widget>[
                          SizedBox(
                            height: 5,
                          ),
                          Center(
                            child: Image.asset(
                              //placeholder: kTransparentImage,
                              'assets/images/blogo.png',
                              fit: BoxFit.cover,
                              height: MediaQuery.of(context).size.height * 0.1,
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
                              controller: _nameController,
                              decoration: InputDecoration(
                                  hintText: 'Full Name',
                                  border: InputBorder.none),
                              keyboardType: TextInputType.text,
                              autocorrect: false,
                              autovalidate: true,
                              validator: (_) {
                                return !state.isNameValid
                                    ? 'Invalid Name'
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
                              controller: _emailController,
                              decoration: InputDecoration(
                                  hintText: 'Email', border: InputBorder.none),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              autovalidate: true,
                              validator: (_) {
                                return state.isNewUser
                                    ? !state.isEmailValid
                                        ? 'Invalid Email'
                                        : null
                                    : 'User already Exist';
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
                              child: Row(children: <Widget>[
                                Expanded(
                                  child: CountryCodePicker(
                                    onChanged: (value) {
                                      _registerBloc.add(
                                        CountryCodeChanged(
                                            country: value.dialCode),
                                      );
                                      print(' Country ${value.dialCode}');
                                    },
                                    initialSelection: 'NG',
                                    favorite: ['+234', 'NG'],
                                    showCountryOnly: false,
                                    showOnlyCountryWhenClosed: false,
                                    alignLeft: true,
                                  ),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: _telephoneController,
                                    decoration: InputDecoration(
                                        hintText: 'Telephone',
                                        border: InputBorder.none),
                                    keyboardType: TextInputType.phone,
                                    autocorrect: false,
                                    autovalidate: true,
                                    validator: (_) {
                                      return !state.isTelephoneValid
                                          ? 'Invalid Telephone'
                                          : null;
                                    },
                                  ),
                                )
                              ])),
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
                                  border: InputBorder.none),
                              obscureText: true,
                              autocorrect: false,
                              autovalidate: true,
                              validator: (_) {
                                return !state.isPasswordValid
                                    ? 'Weak Password'
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
                              controller: _confirmPasswordController,
                              decoration: InputDecoration(
                                  hintText: 'Confirm Password',
                                  border: InputBorder.none),
                              obscureText: true,
                              autocorrect: false,
                              autovalidate: true,
                              validator: (_) {
                                return !state.isConfirmPasswordValid
                                    ? 'Confirm Password not thesame with password'
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
                            child: CheckboxListTile(
                              title: GestureDetector(
                                onTap: () {
                                  if (!Get.isBottomSheetOpen)
                                    Get.bottomSheet(
                                      builder: (_) {
                                        return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.8,
                                          color: Colors.white,
                                          child: Text('dfdfdf'),
                                        );
                                      },
                                      isScrollControlled: true,
                                    );
                                },
                                child: Text(
                                  "I Agree to Terms and Conditions",
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                              value: state.isAgreedValid,
                              onChanged: (bool value) {
                                _registerBloc.add(
                                  AgreedChanged(agreed: value),
                                );
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ),
                          Container(
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: marginLR * 0.008,
                                    horizontal: marginLR * 0.08),
                                child: RaisedButton(
                                  onPressed: isRegisterButtonEnabled(state)
                                      ? _onFormSubmitted
                                      : null,
                                  padding: EdgeInsets.all(12),
                                  color: Color.fromRGBO(0, 21, 64, 1),
                                  child: Center(
                                    child: Text(state.isSubmitting?'Please wait..':'Sign Up',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                )),
                          ),
                          Container(
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: marginLR * 0.008,
                                    horizontal: marginLR * 0.08),
                                child: FlatButton(
                                  onPressed: () {
                                    FocusScope.of(context).requestFocus(FocusNode());
                                    Get.off(
                                      login.LoginScreen(
                                        userRepository: _userRepository,
                                        fromSignup: true,
                                      ),
                                    );
                                  },
                                  padding: EdgeInsets.all(12),
                                  child: Center(
                                    child: Text('Have an account! Sign In',
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                )),
                          ),
                        ]))))
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    _registerBloc.add(
      EmailChanged(email: _emailController.text),
    );
  }

  void _onPasswordChanged() {
    _registerBloc.add(
      PasswordChanged(password: _passwordController.text),
    );
  }

  void _onNameChanged() {
    _registerBloc.add(
      NameChanged(name: _nameController.text),
    );
  }

  void _onTelephoneChanged() {
    _registerBloc.add(
      TelephoneChanged(telephone: _telephoneController.text),
    );
  }

  void _onConfirmPasswordChanged() {
    _registerBloc.add(
      ConfirmPasswordChanged(confirmpassword: _confirmPasswordController.text),
    );
  }

  void _onFormSubmitted() {
    _registerBloc.add(
      Submitted(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        telephone: _telephoneController.text,
        referral: widget.linkdata != null
            ? widget.linkdata.queryParameters.containsKey('referralID')
                ? widget.linkdata.queryParameters['referralID']
                : ''
            : '',
      ),
    );
  }
}
