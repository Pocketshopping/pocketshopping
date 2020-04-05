import 'dart:async';
import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flux_validator_dart/flux_validator_dart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/constants/ui_constants.dart';
import 'package:pocketshopping/page/businessLoader.dart';
import 'package:pocketshopping/widget/bSheetTemplate.dart';
import 'package:pocketshopping/widget/template.dart';
import 'package:pocketshopping/component/psCard.dart';
import 'package:pocketshopping/model/DataModel/merchantData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/component/psProvider.dart';





class BusinessSetUpSecondPage extends StatefulWidget {
  BusinessSetUpSecondPage({
    this.coverUrl=PocketShoppingDefaultCover,
    this.color=PRIMARYCOLOR,
    this.data,
    this.fieldData,
    this.backFlag='double',


  });
  final String coverUrl;
  final Color color;
  MerchantDataModel data;
  Map<String,dynamic> fieldData;
  String backFlag;
  @override
  State<StatefulWidget> createState() => _SetupBusinessState();
}

class _SetupBusinessState extends State<BusinessSetUpSecondPage> {

  final _formKey = GlobalKey<FormState>();
  Map formType;
  String btype;
  var _telephone2Controller = TextEditingController();
  var _telephoneController = TextEditingController();
  var _emailController= TextEditingController();
  var _openingController = TextEditingController();
  var _closingController = TextEditingController();

  final FocusNode _telephoneFocus = FocusNode();
  final FocusNode _telephone2Focus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _capture = FocusNode();



  dynamic camresult;
  String bcategory='Restuarant';
  String delivery ='No';
  final format = DateFormat("HH:mm");
  Geolocator geolocator = Geolocator();
  Position userLocation;
  double accuracy;
  String fetching;
  String ccode;
  String ccode2;
  bool _autovalidate;
  Locale myLocale;
  bool agreed;
  String termsError;







  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //Navigator.pop(context);
    formType = {'REST':'Item','STORE':'Product','BAR':'Item'};
    btype='REST';
    camresult = null;
    accuracy=0.0;
    fetching="start";
    ccode ='+234';
    ccode2 ='+234';
    _autovalidate=false;
    agreed=false;
    termsError="You can not proceed with out accepting the terms and conditions";
    //myLocale=Localizations.localeOf(context);


  }

  bool validateMobile(String value,String codex) {

    if (value.length<6) {
      return false;
    }
    else if (codex == '+234'){
      if(value.length< 11)
        return false;
      else
        return true;
    }
    else{
      return true;
    }

  }

  void checkPermission() {
    geolocator.checkGeolocationPermissionStatus().then((status) { print('status: $status'); });
    geolocator.checkGeolocationPermissionStatus(locationPermission: GeolocationPermission.locationAlways).then((status) { print('always status: $status'); });
    geolocator.checkGeolocationPermissionStatus(locationPermission: GeolocationPermission.locationWhenInUse)..then((status) { print('whenInUse status: $status'); });
  }

  Future getItemImageFromLib()async{
    camresult = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

 int getDifference(){
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String today = formatter.format(now);
    String startDateTime = "${today} ${_openingController.text}";
    String endDateTime = "${today} ${_closingController.text}";
    var parsedstartDateTime = DateTime.parse(startDateTime);
    var parsedendDateTime = DateTime.parse(endDateTime);
    Duration difference = parsedendDateTime .difference(parsedstartDateTime);
    print(difference.inHours.toString());
   return difference.inHours;
  }

  @override
  Widget build(BuildContext context) {



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
      value: agreed,
      onChanged: (bool value) {
        setState(() {
          agreed = value;
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

    final opening = DateTimeField(
      controller: _openingController,
      validator: (value) {
        if (value == null ) {
          return 'Enter  Business Opening Time';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText:"Business Opening Time",
        hintText: 'Business Opening Time',
        border: InputBorder.none,
      ),

      format: format,
      onShowPicker: (context,currentValue)async{
        final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(currentValue??DateTime.now()));
        return DateTimeField.convert(time);
      },
    );
    final closing = DateTimeField(
      controller: _closingController,
      validator: (value) {
        if (value == null) {
          return 'Enter  Business Closing Time';
        }
        else if(getDifference()<1){
          return 'Closing time can not be less or equal Opening time ';
        }

        return null;
      },
      decoration: InputDecoration(
        labelText:"Business Closing Time",
        hintText: 'Business Closing Time',
        border: InputBorder.none,
      ),

      format: format,
      onShowPicker: (context,currentValue)async{
        final time = await showTimePicker(

            context: context,
            initialTime: TimeOfDay.fromDateTime(currentValue??DateTime.now()),

        );
        return DateTimeField.convert(time);
      },
    );



    final telephone = TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return 'Enter a Business Telephone';
        }
        else if (!validateMobile(value,ccode)) {
          return 'Enter a valid Business Telephone';
        }
        return null;
      },
      controller: this._telephoneController,
      textInputAction: TextInputAction.next,
    focusNode: this._telephoneFocus,
    onFieldSubmitted: (term){
    _telephoneFocus.unfocus();
    FocusScope.of(context).requestFocus(this._telephone2Focus);
    },
      keyboardType: TextInputType.phone,
      autofocus: false,

      decoration: InputDecoration(
        labelText:"Business Telephone",
        hintText: 'Telephone',
        border: InputBorder.none,
      ),
    );

    final email = TextFormField(
      validator: (value) {
        if (value.isNotEmpty && !Validator.email(value)) {
          return 'Enter a valid Business Email';
        }
        return null;
      },
      controller: this._emailController,
      textInputAction: TextInputAction.next,
      focusNode: this._emailFocus,
      onFieldSubmitted: (term){
        _emailFocus.unfocus();
        FocusScope.of(context).requestFocus(this._telephoneFocus);
      },
      keyboardType: TextInputType.emailAddress,
      autofocus: false,

      decoration: InputDecoration(
        labelText:"Business Email(Optional)",
        hintText: 'Email(Optional)',
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
    final countryCodePicker2= CountryCodePicker(
      onChanged: (value){setState(() {
        ccode2=value.toString();
      }); print(value.code);},
      initialSelection: 'NG',
      favorite: ['+234','NG'],
      showCountryOnly: false,
      showOnlyCountryWhenClosed: false,
      alignLeft: true,
    );

    final telephone2 = TextFormField(
      validator: (value) {
        if (value.isNotEmpty && validateMobile(value,ccode2)) {
          return 'Enter a valid Business Telephone2';
        }
        return null;
      },
      controller: this._telephone2Controller,
      //textInputAction: TextInputAction.next,
      focusNode: this._telephone2Focus,
      onFieldSubmitted: (term){
        _telephone2Focus.unfocus();
       // FocusScope.of(context).requestFocus(this._pricehtFocus);
      },
      keyboardType: TextInputType.phone,
      autofocus: false,

      decoration: InputDecoration(
        labelText:"Business Telephone 2 (Optional)",
        hintText: 'Telephone 2(Optional)',
        border: InputBorder.none,
      ),
    );
    return WillPopScope(
        onWillPop: _onWillPop,
        child:Scaffold(
      backgroundColor: Colors.white,

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.1), // here the desired height
        child: AppBar(
          centerTitle: true,
          elevation:0.0,
          backgroundColor: Colors.white,
          leading: IconButton(

            icon: Icon(Icons.arrow_back_ios,color:PRIMARYCOLOR,
            ),
            onPressed: (){
              int count = 0;
              if(widget.backFlag == 'double')
                Navigator.popUntil(context, (route) {
                  return count++ == 2;
                });
              else
                Navigator.pop(context);
            },
          ) ,
          title:Text("Business Setup",style: TextStyle(color: PRIMARYCOLOR),),

          automaticallyImplyLeading: false,
        ),
      ),

      body: Builder(
          builder: (ctx) => CustomScrollView(
          slivers: <Widget>[SliverList(
          delegate: SliverChildListDelegate(
            [
              Container(height: MediaQuery.of(context).size.height*0.02,),
              psCard(
                color: widget.color,
                title: 'Setup Contd',
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    //offset: Offset(1.0, 0), //(x,y)
                    blurRadius: 6.0,
                  ),
                ],
                child: Form(
                    key: _formKey,
                    autovalidate: _autovalidate,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
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
                            child: opening,
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
                            child: closing,
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
                            child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: countryCodePicker2,
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: telephone2,
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
                            child: Column(
                              children: <Widget>[
                                Text("Business Premises Cordinate",style: TextStyle(color: Colors.black54),),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Center(
                                      child: FlatButton(
                                        onPressed: (){

                                          //_telephoneFocus.unfocus();
                                          FocusScope.of(context).requestFocus(this._capture);
                                          if(_formKey.currentState.validate())
                                            {
                                              if(fetching == 'start'){
                                                showModalBottomSheet(
                                                  context: context,
                                                  builder: (context) =>
                                                      BottomSheetTemplate(
                                                        height: MediaQuery.of(context).size.height*0.6,
                                                        opacity: 0.2,
                                                        child: Container(
                                                          padding: EdgeInsets.all(
                                                            MediaQuery.of(context).size.width*0.05,
                                                          ),
                                                          child: Column(
                                                            children: <Widget>[

                                                              Column(
                                                                children: <Widget>[


                                                                  Text("please note this is a very important "
                                                                      " stage of your business setup ensure "
                                                                      "you follow the steps stated below."
                                                                      "the visibility of your business depends on the "
                                                                      "success of this stage."),
                                                                  SizedBox(height: 20,),
                                                                  Row(
                                                                    children: <Widget>[
                                                                      Expanded(
                                                                        flex:0,
                                                                        child: Text("1."),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child: Text("Ensure your GPS is enabled and ensure to grant "
                                                                            "permission to pockeshopping"),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  SizedBox(height: 10,),
                                                                  Row(
                                                                    children: <Widget>[
                                                                      Expanded(
                                                                        flex:0,
                                                                        child: Text("2."),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child: Text("Move outside to the front of"
                                                                            " your business premises, about 0.5meters "
                                                                            "away from the door"),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  SizedBox(height: 10,),
                                                                  Row(
                                                                    children: <Widget>[
                                                                      Expanded(
                                                                        flex:0,
                                                                        child: Text("3."),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child: Text("Click on the location button below to start capturing, this will only take 15 seconds"),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  SizedBox(height: 20,),
                                                                  Center(
                                                                    child: FlatButton(
                                                                      onPressed: (){
                                                                        _getUpdateLocation();
                                                                        setState(() {
                                                                          fetching="fetching";
                                                                        });
                                                                        LocationTimer();
                                                                        Navigator.pop(context);
                                                                      },
                                                                      child: Column(
                                                                        children: <Widget>[
                                                                          Icon(Icons.add_location,
                                                                            size: MediaQuery.of(context).size.height*0.1,
                                                                            color: Colors.greenAccent,),
                                                                          Text("Click to start"),


                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )

                                                            ],

                                                          ),
                                                        ),
                                                      ),
                                                  isScrollControlled: true,
                                                );
                                              }
                                              else if(fetching == 'fetching'){
                                                Scaffold.of(ctx).showSnackBar(new SnackBar(content: new Text("Am Working please hold on for a few sec.")));
                                              }
                                              else{
                                                Scaffold.of(ctx).showSnackBar(new SnackBar(content: new Text("Cordinate Captured please continue with business setup")));
                                              }
                                            }
                                          else{
                                            setState(() {
                                              _autovalidate=true;
                                            });
                                            Scaffold.of(ctx).showSnackBar(new SnackBar(content: new Text("You have to fill other fields before you can start capturing cordinate")));
                                          }

                                        },
                                        child: Column(
                                          children: <Widget>[

                                            fetching == 'start'?
                                                Column(
                                                  children: <Widget>[
                                                    Icon(Icons.add_location,
                                                      color: Colors.black54,
                                                      size: MediaQuery.of(context).size.height*0.05,),
                                                    FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: Text("Pick Cordinate*",
                                                          style: TextStyle(color: Colors.black54)),
                                                    ),
                                                  ],
                                                )
                                            :fetching=="fetching"?Center(
                                                child: Column(
                                                  children: <Widget>[
                                                    Container(height: 10,),
                                                    CircularProgressIndicator(),
                                                    Text("fetching Cordinate, please wait",style: TextStyle(color: Colors.black54),)
                                                  ],
                                                )
                                            ):fetching == "done"?
                                                Center(
                                                  child: Column(
                                                    children: <Widget>[
                                                      Container(height: 10,),
                                                      Icon(Icons.check,
                                                        color: Colors.green,
                                                        size: MediaQuery.of(context).size.height*0.05,
                                                      ),
                                                      //Text("Lat: "+userLocation.latitude.toString()),
                                                      //Text('Long: '+userLocation.longitude.toString()),
                                                      //Text('Acc: '+userLocation.accuracy.toString()),
                                                      Text("fetching Complete, you can now continue",style: TextStyle(color: Colors.black54),)
                                                    ],
                                                  ),
                                                )
                                                :
                                                Container(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                            child: terms,
                          ),
                          Container(
                            padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: FlatButton(
                                focusNode: this._capture,
                                color: widget.color,
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    setState(() {
                                      myLocale=Localizations.localeOf(context);
                                    });
                                    if( fetching == "done") {
                                      if(agreed){
                                      getDifference();
                                      widget.data.bOpenTime = _openingController.text.trim();
                                      widget.data.bCloseTime = _closingController.text.trim();
                                      widget.data.bSocial={};
                                      widget.data.bStatus='pending';
                                      widget.data.bCountry=myLocale.countryCode;
                                      widget.data.bTelephone = ccode+(_telephoneController.text.trim().substring(1));
                                      if (_emailController.text.isNotEmpty)
                                        widget.data.bEmail = _emailController.text.trim();
                                      if (_telephone2Controller.text
                                          .trim()
                                          .isNotEmpty)
                                        widget.data.bTelephone2 = ccode2+(_telephone2Controller.text.trim().substring(1));

                                      widget.data.bGeopint = GeoPoint(userLocation.latitude, userLocation.longitude);
                                      widget.data.uid= psProvider.of(context).value['uid'];
                                      widget.data.bID = "";
                                      if(widget.fieldData.isNotEmpty){
                                        print(widget.fieldData);
                                        widget.data.isBranch=true;
                                        widget.data.bParent=widget.fieldData['merchantID'];
                                      }
                                      else{
                                        widget.data.isBranch=false;
                                        widget.data.bParent='';

                                      }
                                      //widget.data.uid=

                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => BusinesSetupLoader(data: widget.data,)));
                                      //print(widget.data.bCroppedPhoto);
                                      }else{
                                        Scaffold.of(ctx).showSnackBar(new SnackBar(content: new Text(termsError)));
                                      }
                                    }
                                    else{


                                     if(fetching=='done'){
                                       Scaffold.of(ctx).showSnackBar(new SnackBar(content: new Text("Am Working please hold on for a few sec.")));
                                     }
                                     else{
                                       Scaffold.of(ctx).showSnackBar(new SnackBar(content: new Text("You can not proceed without capturing cordination")));
                                     }
                                    }
                                  }
                                  else{
                                    setState(() {
                                      _autovalidate=true;
                                    });
                                  }

                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text('Submit',style: TextStyle(color: Colors.white),)
                                  ],),
                              ),
                            )

                          ),

                        ]
                    )
                ),
              ),




            ],
          )
      ),
    ]
      )
    )
        )
    );
  }

 LocationTimer()async{
   await Future.delayed(Duration(seconds: 15),() {
     setState(() {
       fetching="done";
     });

   });
 }

  Future<Position> _getUpdateLocation() async {
    var currentLocation;
    try {
      geolocator
          .getPositionStream(LocationOptions(
          accuracy: LocationAccuracy.bestForNavigation, timeInterval: 1000))
          .listen((position) {

        if (accuracy == 0.0){
          setState(() {
            accuracy = position.accuracy;
            userLocation=position;
          });
        }
        else{
           if(position.accuracy < accuracy && fetching == "fetching"){
            print("accuracy from < accuracy "+position.accuracy.toString()+' meters');
            setState(() {
              accuracy = position.accuracy;
              userLocation=position;
            });
          }
        }

      });
    } catch (e) {
      currentLocation = null;
    }

    return currentLocation;
  }

  Future<bool> _onWillPop() async {
    int count = 0;
    if(widget.backFlag == 'double')
    Navigator.popUntil(context, (route) {
      return count++ == 2;
    });
    else
      Navigator.pop(context);
  }

}




