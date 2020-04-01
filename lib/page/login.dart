import 'package:flutter/material.dart';
import 'package:flux_validator_dart/flux_validator_dart.dart';
import 'package:pocketshopping/component/psCard.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/model/DataModel/userData.dart';
import 'package:pocketshopping/page/admin.dart';
import 'package:pocketshopping/page/curvyPage.dart';
import 'package:pocketshopping/page/signUp.dart';
import 'package:pocketshopping/firebase/BaseAuth.dart';
import 'package:pocketshopping/page/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/component/psProvider.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool _isLoading;
  final _formKey = GlobalKey<FormState>();
  var authHandler = new Auth();
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();
  String errorText;
  bool timeout;
  bool _autovalidate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading=false;
    errorText ='';
    timeout = false;
    _autovalidate=false;
  }
  
  @override
  Widget build(BuildContext context) {
    double marginLR =  MediaQuery.of(context).size.width;

    Widget showCircularProgress() {
      if (_isLoading) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black.withOpacity(0.6),
          child: Center(
              child:
          Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height*0.3,
            width: MediaQuery.of(context).size.width*0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                Text("Please wait",style: TextStyle(
                  color:Colors.black54,
                  fontStyle: FontStyle.italic,),)
              ],
            ),
          )
          ),
        )

        ;
      }
      return Container(
        height: 0.0,
        width: 0.0,
      );
    }

    final error=Text(errorText,style: TextStyle(
      color: Colors.redAccent
    ),

    );
    
    final email = TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return "can't be empty";
        }
        else if (Validator.email(value)) {
          return 'Enter a valid  email';
        }
        return null;
      },
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      style: TextStyle(color: Colors.black),
      cursorColor: Colors.black,
      decoration: InputDecoration(

        hintText: 'Email',
        border: InputBorder.none,
      ),
    );

    final password = TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return "can't be empty";
        }
        else if (value.length<=2) {
          return 'Enter a valid  name';
        }
        return null;
      },
      controller: _passwordController,
      autofocus: false,
      obscureText: true,
      style: TextStyle(color: Colors.black),
      cursorColor: Colors.black,
      decoration: InputDecoration(

        hintText: 'Password',

        border: InputBorder.none,
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: marginLR*0.008),
      child: RaisedButton(

        onPressed: () {
          if(_formKey.currentState.validate()) {
            setState(() {
              _isLoading = true;
              timeout = true;
            });
            //forceful timeout
            Future.delayed(Duration(seconds: 15), () =>
            {
              if(timeout)
                setState(() {
                  _isLoading = false;
                  timeout = false;
                  errorText =
                  "Error in network connection, check your network connection and try again.";
                })
            });

            authHandler.signIn(_emailController.text.trim(),
                _passwordController.text.trim()).then((value) =>
            {
              psProvider.of(context).value['uid']=value,
              UserData(uid: value).getOne().then((data) => {
                psProvider.of(context).value['user']=data,
                UserData(uid: value,notificationID: 'fcm').upDate().then((value) => null),
                //UserData(uid: value,role: 'admin').upDate().then((value) => null),
                if(data['role']=='admin'){

                 // if(data['business'].toString().isNotEmpty){
               //data['business'].get().then((value)=>print(value.data)),
                 // },
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminPage()))
                }
                else if(data['role']=='user'){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserPage()))
                }

              })

            }
            ).catchError((error, stackTrace) =>
            {
              print(error),

              if(error.toString().toUpperCase().contains(
                  "ERROR_USER_NOT_FOUND")){
                // print(true),
                setState(() {
                  _isLoading = false;
                  timeout = false;
                  errorText =
                  "No account associated with this email, check the email or create new account.";
                })
              }
              else
                if(error.toString().toUpperCase().contains(
                    "ERROR_NETWORK_REQUEST_FAILED,"))
                  {
                    if(timeout)
                      setState(() {
                        _isLoading = false;
                        timeout = false;
                        errorText =
                        "Error in network connection, check your network connection and try again.";
                      })
                  }
                else
                  if(error.toString().toUpperCase().contains(
                      "ERROR_WRONG_PASSWORD")){
                    if(timeout)
                      setState(() {
                        _isLoading = false;
                        timeout = false;
                        errorText =
                        "Wrong password. chack you password and try again";
                      })
                  }
                  else
                    {
                      if(timeout)
                        setState(() {
                          _isLoading = false;
                          timeout = false;
                          errorText = "Error Reaching server, Try again.";
                        })
                    }
            });
            //Navigator.push(
          } //  context,
          else{
            setState(() {
              _autovalidate=true;
            });
          }
              //MaterialPageRoute(builder: (context) => AdminPage()));
        },
        padding: EdgeInsets.all(12),
        color: Color.fromRGBO(0, 21, 64, 1),
        child: Text('Sign In', style: TextStyle(color: Colors.white)),
      ),
    );
 
    final forgotLabel = FlatButton(
      child: Text(
        'Forgot password?',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {},
    );

    final signUpLabel = FlatButton(
      child: Text(
        'SignUp Now?',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {

        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignUpPage()));
      },
    );

final fields=Container(
      padding: EdgeInsets.only(left: marginLR*0.02, right: marginLR*0.02),
      margin: EdgeInsets.only(top: marginLR*0.3),
      child:
      psCard(
        color: PRIMARYCOLOR,
        title: 'Sign In',
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            //offset: Offset(1.0, 0), //(x,y)
            blurRadius: 6.0,
          ),
        ],
        child:
        Form(
          key: _formKey,
          autovalidate: _autovalidate,
          //autovalidate: true,
          child:
      Column(
          children: <Widget>[
            SizedBox(height: 10,),
            Center(
              child: Image.asset(
                //placeholder: kTransparentImage,
                'assets/images/blogo.png',
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height*0.15,

              ),
            ),
            //Center(child: Text('Sign In',style: TextStyle(color:Colors.black54,fontSize: marginLR*0.08),),),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
              child: Center(child: error),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide( //                   <--- left side
                    color: Colors.black12,
                    width: 1.0,
                  ),
                ),
              ),
              padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
              child: email,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide( //                   <--- left side
                    color: Colors.black12,
                    width: 1.0,
                  ),
                ),
              ),
              padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
              child: password,
            ),
            Container(
              child: loginButton,
            ),
            forgotLabel,
            signUpLabel,
          ],
        ),
      ),
      ),

    );

    final form = ListView(
      padding: EdgeInsets.only(left: 0, right: 0),
      children: <Widget>[
                Center(child: fields,),
      ],
    );

    return WillPopScope(
        onWillPop: _onWillPop,
        child:Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child:Stack(
          children: <Widget>[
            form,
            showCircularProgress(),
          ],
        )
      )
        )
      );

  }

  Future<bool> _onWillPop() async {
      return Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignUpPage()));


  }
}

