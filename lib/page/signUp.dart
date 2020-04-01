import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flux_validator_dart/flux_validator_dart.dart';
import 'package:pocketshopping/component/psCard.dart';
import 'package:pocketshopping/firebase/BaseAuth.dart';
import 'package:pocketshopping/page/business.dart';
import 'package:pocketshopping/page/curvyPage.dart';
import 'package:pocketshopping/page/login.dart';
import 'package:pocketshopping/model/DataModel/userData.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/widget/bSheetTemplate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketshopping/component/psProvider.dart';

class SignUpPage extends StatefulWidget {
  static String tag = 'signUp-page';
  @override
  _SignUpPageState createState() => new _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  final _formKey = GlobalKey<FormState>();
  var _nameController = TextEditingController();
  var _emailController = TextEditingController();
  var _telephoneController  = TextEditingController();
  var _passwordController = TextEditingController();
  var _cpasswordController = TextEditingController();
  var _signup = FocusNode();
  var authHandler = new Auth();
  String errorText;
  bool timeout;
  bool _isLoading;
  String _isLoadingText;
  bool signup;
  bool agreed;
  String termsError;
  String ccode;
  bool _autoValidate;
  bool isNew;
  Locale myLocale;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading=false;
    errorText ='';
    timeout = false;
    signup=false;
    agreed=false;
    _autoValidate=false;
    termsError='';
    ccode ='+234';
    _isLoadingText='please wait';
    isNew=true;
    _emailController.addListener(() {
      if (!Validator.email(_emailController.text)) {
        UserData().IsNew(_emailController.text).then((value) => {
          print(value.toString()),
          if(!value)
            setState(() {
              isNew=false;
            })
        });

      }
    });
  }

  bool validateMobile(String value) {

    if (value.length<6) {
      return false;
    }
    else if (ccode == '+234'){
      if(value.length< 11)
          return false;
      else
        return true;
    }
    else{
      return true;
    }

  }

  @override
  Widget build(BuildContext context) {
    double marginLR =  MediaQuery.of(context).size.width;

    Widget showCircularProgress() {
      if (_isLoading) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,//.withOpacity(0.6),
          child: ListView(children:<Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/loader.gif',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height*0.6,
                fit: BoxFit.cover,),
              Text(_isLoadingText,style: TextStyle(
                color:Colors.black54,
                fontSize: marginLR*0.06,
                fontStyle: FontStyle.italic,),)
            ],
          )
            ]
          ),
        )

        ;
      }
      return Container(
        height: 0.0,
        width: 0.0,
      );
    }

    final name = TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return "can't be empty";
        }
        else if (value.length<3) {
          return 'Name should be valid  word';
        }
        else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
          return 'Enter a valid  name';
        }
        return null;
      },
      controller: _nameController,
      keyboardType: TextInputType.text,
      autofocus: false,
      style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
      cursorColor: Colors.black,
      decoration: InputDecoration(
        //filled: true,
        labelText: "Full Name",
        hintText: 'Full Name',
        border: InputBorder.none,
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
        else if(!isNew){
          return 'user already exist';
        }
        return null;
      },
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
      cursorColor: Colors.black,
      decoration: InputDecoration(
        //filled: true,
        labelText: "Email",
        hintText: 'Email',
        border: InputBorder.none,
      ),
    );

    final telephone = TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return "can't be empty";
        }
        else if (!validateMobile(value)) {
          return 'Enter a valid  telephone';
        }
        return null;
      },
      controller: _telephoneController,
      autofocus: false,
      keyboardType: TextInputType.phone,
      style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Telephone',
        hintText: 'Telephone',
        border: InputBorder.none,

      ),
    );

    final countryCodePicker= CountryCodePicker(
      onChanged: (value){setState(() {
        ccode=value.toString();
      }); print(value.code);},
      initialSelection: 'NG',
      favorite: ['+234','NG'],
      showCountryOnly: false,
      showOnlyCountryWhenClosed: false,
      alignLeft: true,
    );

    final terms = CheckboxListTile(
      title: GestureDetector(
        onTap: (){},
        child: Text(
            "I Agree to Terms and Conditions",
          style: TextStyle(
              color: Colors.blueAccent,

          ),

        ),
      ),
      value: this.agreed,
      onChanged: (bool value) {
        setState(() {
          this.agreed = value;
        });
        if (value){
          setState(() {
            termsError = "";
          });
        }
        else{
          setState(() {
            termsError = "You can not proceed with out accepting the terms and conditions";
          });
        }
      },
      controlAffinity: ListTileControlAffinity.leading,


    );

    final password = TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return "can't be empty";
        }
        else if (value.length<=6) {
          return 'Password must be more than 6 character long';
        }
        return null;
      },
      controller: _passwordController,
      autofocus: false,
      obscureText: true,
      style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Password',
        border: InputBorder.none,

      ),
    );

    final cpassword = TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return "Can't be empty";
        }
        else if (value != _passwordController.text) {
          return 'confirm password is not thesame with password';
        }
        return null;
      },
      controller: _cpasswordController,
      autofocus: false,
      obscureText: true,
      style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        hintText: 'Confirm Password',
        border: InputBorder.none,

      ),
    );



    final loginButton = RaisedButton(
        focusNode: _signup,
        onPressed: () {
          FocusScope.of(context).requestFocus(this._signup);
    if (_formKey.currentState.validate() ) {
      setState(() {
        myLocale=Localizations.localeOf(context);
      });
      if(agreed){
        setState(() {
          _isLoading=true;
          _isLoadingText='Creating account';
        });

        authHandler.signUp(_emailController.text.trim(), _passwordController.text.trim()).then((value) =>
        {
          psProvider.of(context).value['uid']=value,
          setState(() {
            _isLoadingText='Setting Up account';
          }),
          FirstTimer(),
          UserData(
            uid: value,
            role: 'user',
            fname: _nameController.text,
            email: _emailController.text,
            telephone: ccode+_telephoneController.text.substring(1),
            country: myLocale.countryCode
          ).save().then((data) =>{
            setState(() {
              _isLoading=false;
            }),
            //print(data),
            if(data.length>0){
              psProvider.of(context).value['user']=data,
            },
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BusinessSetUpPage())),
          }

          ),

        }).catchError((onError)=>{
          if(onError.toString().toUpperCase().contains("ERROR_WEAK_PASSWORD")){
            print('weak password')
          }
        });

      }
      else{
        setState(() {
          termsError = "You can not proceed with out accepting the terms and conditions";
        });
      }

    }
    else{
      setState(() {
        _autoValidate = true;
      });
    }
        },
        //padding: EdgeInsets.all(12),
        color: PRIMARYCOLOR,
        child: Text('SignUp', style: TextStyle(color: Colors.white)),
      );


  final fields=Container(
    padding: EdgeInsets.only(left: marginLR*0.01, right: marginLR*0.01),
    margin: EdgeInsets.only(top: marginLR*0.05),
      child:
      ListView(
        //crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
      psCard(
      color: PRIMARYCOLOR,
        title: 'SignUp',
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
          autovalidate: _autoValidate,
          child:
              Column(
                children:<Widget>[
                  SizedBox(height: 5,),
                  Center(
                    child: Image.asset(
                      //placeholder: kTransparentImage,
                      'assets/images/blogo.png',
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.height*0.15,

                    ),
                  ),
                 // Center(child: Text('SignUp',style: TextStyle(color:Colors.black54,fontSize: marginLR*0.08),),),
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
                    child: name,
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
                    child: Column(
                      children: <Widget>[
                        !isNew?Text("User already exist, head to login to access account",style: TextStyle(color: Colors.redAccent),):Container(),
                        email
                      ],
                    ),
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
                    child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: countryCodePicker,
                          ),
                        Expanded(
                          flex: 2,
                          child: telephone,
                        )

                        ]),
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
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide( //                   <--- left side
                          color: Colors.black12,
                          width: 1.0,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
                    child: cpassword,
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
                    child: Column(
                      children: <Widget>[
                        Text(termsError,style: TextStyle(color: Colors.redAccent),),
                        terms
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
                    child: loginButton,
                  ),

            //loginLabel
          ],
              ),
        ),
      ),
    ]
        ),


    );

  final form=  ListView(
    padding: EdgeInsets.only(left: 0, right: 0),
    scrollDirection: Axis.vertical,
    children: <Widget>[
      Container(
        height: MediaQuery.of(context).size.height*0.65,
        decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage('assets/images/signup_3.png'),
            fit: BoxFit.contain,
          ),
        ),
      ),
      ClipRRect(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30)
        ),
        child: Container(
            height: MediaQuery.of(context).size.height*0.35,
          //color: Colors.white.withOpacity(0.8),
          padding: EdgeInsets.only(top: marginLR*0.05,bottom: marginLR*0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 0,
                    child: FlatButton(
                      onPressed: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()));
                      },
                      child: Text("Pocketshopping: digitalizing your pocket",
                      style: TextStyle(color: PRIMARYCOLOR),),
                    ),
                  )
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 0,
                    child: FlatButton(
                      onPressed: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()));
                      },
                      color: PRIMARYCOLOR,
                      child: Container(
                          padding: EdgeInsets.only(left:marginLR*0.3,right: marginLR*0.3),
                          child: Text('Sign In',style: TextStyle(color: Colors.white),)
                      ),
                    ),
                  )
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 0,
                    child: Container(

                          decoration: BoxDecoration(
                              border: Border.all(width: 1,color: PRIMARYCOLOR)
                          ),
                        child:FlatButton(

                      onPressed: (){
                        setState(() {
                          signup=true;
                        });
                      },


                      //color: PRIMARYCOLOR,
                      child: Container(
                          padding: EdgeInsets.only(left:marginLR*0.3,right: marginLR*0.3),
                          child: Text('Sign Up',style: TextStyle(color: PRIMARYCOLOR),)
                      ),
                    )
              ),
                  )
                ],
              )
            ],
          )
          //fields,
        ),
      ),

    ],
  );

    return WillPopScope(
      onWillPop: _onWillPop,
      child:Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child:Stack(
          children: <Widget>[
            !signup?form:
            fields,
            showCircularProgress()
          ],
        ),
      ),
    ),
    );
  }

  Future<bool> _onWillPop() async {
    if(signup && !_isLoading)
    return Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignUpPage()));
    else if (signup && _isLoading)
      return false;
    else
      {
        return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Warning'),
            content: new Text('Do you want to exit the App'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
                child: new Text('Yes'),
              ),
            ],
          ),
        ));
      }
  }


  FirstTimer() async {
    print('am working over here');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uid', 'newUser');
  }
}
