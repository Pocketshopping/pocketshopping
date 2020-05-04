import 'dart:async';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:recase/recase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';

class BusinessSetupForm extends StatefulWidget {
  BusinessSetupForm({this.data});

  final Map<String, dynamic> data;

  @override
  State<StatefulWidget> createState() => _BusinessSetupFormState();
}

class _BusinessSetupFormState extends State<BusinessSetupForm> {
  BusinessBloc _businessBloc;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  //final TextEditingController _categoryController = TextEditingController();
  FirebaseUser CurrentUser;
  Timer _timer;
  int _start = 15;

  bool get isPopulated =>
      _addressController.text.isNotEmpty &&
      _nameController.text.isNotEmpty &&
      _telephoneController.text.isNotEmpty;

  bool isRegisterButtonEnabled(BusinessState state) {
    return state.isFormValid && isPopulated && !state.isSubmitting;
  }

  @override
  void initState() {
    super.initState();
    _businessBloc = BlocProvider.of<BusinessBloc>(context);
    _nameController.addListener(_onNameChanged);
    _telephoneController.addListener(_onTelephoneChanged);
    _addressController.addListener(_onAddressChanged);
    CurrentUser = BlocProvider.of<AuthenticationBloc>(context).state.props[0];
  }

  @override
  Widget build(BuildContext context) {
    double marginLR = MediaQuery.of(context).size.width;
    return BlocListener<BusinessBloc, BusinessState>(
        listener: (context, state) {
      if (state.isSubmitting) {
        if (state.isUploading) {
          print('uploading ${state.isUploading}');
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                backgroundColor: Colors.white,
                content: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.1),
                    child: Center(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/images/cloud-upload.gif',
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.4,
                          fit: BoxFit.cover,
                        ),
                        Text(
                          "Loading",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    )),
                  ),
                ),
                duration: Duration(days: 365),
              ),
            );
        } else {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                backgroundColor: Colors.white,
                content: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.1),
                    child: Center(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/images/working.gif',
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.4,
                          fit: BoxFit.cover,
                        ),
                        Text(
                          "Loading",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    )),
                  ),
                ),
                duration: Duration(days: 365),
              ),
            );
        }
      }
      if (state.isSuccess) {
        Scaffold.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: Colors.white,
              content: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.1),
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.height * 0.05,
                            right: MediaQuery.of(context).size.height * 0.05,
                          ),
                          child: Center(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                'assets/images/completed.gif',
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                fit: BoxFit.cover,
                              ),
                              Text(
                                "Your business setup is complete",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black54),
                              ),
                              Container(
                                height: 10,
                              ),
                              Center(
                                  child: Text(
                                "Note your business will be activated once you add atleast one product "
                                "so head straight to your dashboard and start adding product."
                                "",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black54),
                              )),
                              Container(
                                height: 10,
                              ),
                              FlatButton(
                                onPressed: () {
                                  BlocProvider.of<AuthenticationBloc>(context)
                                      .add(LoggedIn());
                                  Navigator.of(context).pop();
                                },
                                color: PRIMARYCOLOR,
                                child: Padding(
                                  padding: EdgeInsets.all(
                                      MediaQuery.of(context).size.height *
                                          0.02),
                                  child: Text(
                                    "DashBoard",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          )),
                        ),

                        // Progress bar
                      ],
                    ),
                  )),
              duration: Duration(days: 365),
            ),
          );
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
    }, child:
            BlocBuilder<BusinessBloc, BusinessState>(builder: (context, state) {
      return WillPopScope(
          onWillPop: () async {
            if (state.isSubmitting)
              return false;
            else {
              return true;
            }
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Container(
                padding: EdgeInsets.only(
                    left: marginLR * 0.01, right: marginLR * 0.01),
                margin: EdgeInsets.only(top: marginLR * 0.05),
                child: Center(
                  child: ListView(
                      //crossAxisAlignment: CrossAxisAlignment.center,
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        psCard(
                          color: PRIMARYCOLOR,
                          title: 'Business SetUp',
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              //offset: Offset(1.0, 0), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ],
                          child: Form(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
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
                                        hintText: 'Business Name',
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
                                        MediaQuery.of(context).size.width *
                                            0.02),
                                    child: Row(children: <Widget>[
                                      Expanded(
                                        child: CountryCodePicker(
                                          onChanged: (value) {
                                            _businessBloc.add(
                                              CountryCodeChanged(
                                                  country: value.dialCode),
                                            );
                                            print('Country ${value.dialCode}');
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
                                              hintText: 'Business Telephone',
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
                                    controller: _addressController,
                                    decoration: InputDecoration(
                                        hintText: 'Business Address',
                                        border: InputBorder.none),
                                    keyboardType: TextInputType.text,
                                    autocorrect: false,
                                    autovalidate: true,
                                    validator: (_) {
                                      return !state.isAddressValid
                                          ? 'Invalid Address'
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
                                        MediaQuery.of(context).size.width *
                                            0.02),
                                    child:
                                        /*TypeAheadFormField(
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: this._categoryController,
                                  decoration: InputDecoration(
                                    labelText: 'Business Category',
                                    border: InputBorder.none,

                                  ),
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.text,
                                  autocorrect: true,
                                ),

                                suggestionsCallback: (pattern)async {
                                  List<String> data=List();
                                  if(pattern.isNotEmpty){
                                    data = await MerchantRepo().getCategory(pattern.sentenceCase);
                                    return data;
                                  }
                                  else{
                                    return data;
                                  }

                                },
                                itemBuilder: (context,suggestion){
                                  return ListTile(
                                    title: Text(suggestion),
                                  );
                                },
                                transitionBuilder: (context,suggestionBox,controller){
                                  return suggestionBox;
                                },
                                onSuggestionSelected: (suggestion){
                                  this._categoryController.text=suggestion;
                                },
                                autovalidate: true,
                                validator: (_) {
                                  return !state.isCategoryValid ? 'Invalid Category' : null;
                                },
                                suggestionsBoxDecoration: SuggestionsBoxDecoration(
                                  constraints: BoxConstraints(
                                    maxHeight: MediaQuery.of(context).size.height*0.2,
                                  ),
                                ),
                                autoFlipDirection: true,
                                hideOnEmpty: true,

                              )*/
                                        Column(
                                      children: <Widget>[
                                        Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Business Category",
                                              style: TextStyle(
                                                  color: Colors.black54),
                                            )),
                                        DropdownButtonFormField<String>(
                                          value: state.category,
                                          items: [
                                            'Restuarant',
                                            'Store',
                                            'Super Market',
                                            'Bar',
                                            'Park'
                                          ]
                                              .map((label) => DropdownMenuItem(
                                                    child: Text(
                                                      label,
                                                      style: TextStyle(
                                                          color:
                                                              Colors.black54),
                                                    ),
                                                    value: label,
                                                  ))
                                              .toList(),
                                          isExpanded: true,
                                          hint: Text('Category'),
                                          decoration: InputDecoration(
                                              border: InputBorder.none),
                                          onChanged: (value) {
                                            _businessBloc.add(CategoryChanged(
                                                category: value));
                                          },
                                        )
                                      ],
                                    )),
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
                                  child: Column(
                                    children: <Widget>[
                                      Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Will you offer delivery service",
                                            style: TextStyle(
                                                color: Colors.black54),
                                          )),
                                      DropdownButtonFormField<String>(
                                        value: state.delivery,
                                        items: [
                                          'No',
                                          'Yes, I have my own delivery service',
                                          'Yes, Use pocketshooping logistic(only in Abuja and lagos)'
                                        ]
                                            .map((label) => DropdownMenuItem(
                                                  child: Text(
                                                    label,
                                                    style: TextStyle(
                                                        color: Colors.black54),
                                                  ),
                                                  value: label,
                                                ))
                                            .toList(),
                                        isExpanded: true,
                                        hint: Text('Rating'),
                                        decoration: InputDecoration(
                                            border: InputBorder.none),
                                        onChanged: (value) {
                                          _businessBloc.add(
                                              DeliveryChanged(delivery: value));
                                        },
                                      )
                                    ],
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Center(
                                        child: Text(
                                          "Capture Business Premise Cordinate",
                                          style:
                                              TextStyle(color: Colors.black54),
                                        ),
                                      ),
                                      state.isCapturing == "NO" ||
                                              state.isCapturing == "FAIL"
                                          ? Column(children: <Widget>[
                                              FlatButton(
                                                onPressed: startCapture,
                                                child: Center(
                                                    child: Icon(
                                                  Icons.location_on,
                                                  color: PRIMARYCOLOR,
                                                  size: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.2,
                                                )),
                                              ),
                                              Center(
                                                child: Text(
                                                    "Click the button above to start capturing",
                                                    style: TextStyle(
                                                        color: Colors.black54)),
                                              ),
                                            ])
                                          : state.isCapturing == "YES"
                                              ? Column(
                                                  children: <Widget>[
                                                    Image.asset(
                                                      'assets/images/place.gif',
                                                      //color: PRIMARYCOLOR,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.4,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.2,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    Center(
                                                      child: Text(
                                                          "Capturing Please wait...$_start",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black54)),
                                                    ),
                                                  ],
                                                )
                                              : state.isCapturing == "COMPLETED"
                                                  ? Column(children: <Widget>[
                                                      Center(
                                                          child: Icon(
                                                        Icons.check,
                                                        color: Colors.green,
                                                        size: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                      )),
                                                      Center(
                                                        child: Text(
                                                            "Cordinate successfully captured",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black54)),
                                                      ),
                                                    ])
                                                  : Container(),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(
                                      MediaQuery.of(context).size.width * 0.02),
                                  child: !state.isSuccess
                                      ? Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: marginLR * 0.008,
                                              horizontal: marginLR * 0.08),
                                          child: RaisedButton(
                                            onPressed:
                                                isRegisterButtonEnabled(state)
                                                    ? _onFormSubmitted
                                                    : null,
                                            padding: EdgeInsets.all(12),
                                            color: Color.fromRGBO(0, 21, 64, 1),
                                            child: Center(
                                              child: Text('Submit',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ))
                                      : Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: marginLR * 0.008,
                                              horizontal: marginLR * 0.08),
                                          child: FlatButton(
                                            onPressed: () {
                                              BlocProvider.of<
                                                          AuthenticationBloc>(
                                                      context)
                                                  .add(LoggedIn());
                                              Navigator.of(context).pop();
                                            },
                                            color: PRIMARYCOLOR,
                                            child: Center(
                                                child: Text(
                                              'Go to Dashboard',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )),
                                          ),
                                        ),
                                ),
                              ])),
                        ),
                      ]),
                )),
          ));
    }));
  }

  void startCapture() {
    showModalBottomSheet(
        context: context,
        builder: (context) => BottomSheetTemplate(
              height: MediaQuery.of(context).size.height * 0.6,
              opacity: 0.2,
              child: Container(
                padding: EdgeInsets.all(
                  MediaQuery.of(context).size.width * 0.05,
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
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 0,
                              child: Text("1."),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                  "Ensure your GPS is enabled and ensure to grant "
                                  "permission to pockeshopping"),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 0,
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
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 0,
                              child: Text("3."),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                  "Click on the location button below to start capturing, this will only take 15 seconds"),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: FlatButton(
                            onPressed: () {
                              _businessBloc.add(CaptureCordinate());
                              startTimer();
                              Navigator.pop(context);
                            },
                            child: Column(
                              children: <Widget>[
                                Icon(
                                  Icons.add_location,
                                  size:
                                      MediaQuery.of(context).size.height * 0.1,
                                  color: Colors.greenAccent,
                                ),
                                Text("start Capturing"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ));
  }

  void _onTelephoneChanged() {
    _businessBloc.add(
      TelephoneChanged(telephone: _telephoneController.text),
    );
  }

  void _onAddressChanged() {
    _businessBloc.add(
      AddressChanged(address: _addressController.text),
    );
  }

  void _onNameChanged() {
    _businessBloc.add(
      NameChanged(name: _nameController.text),
    );
  }

  void _onFormSubmitted() {
    _businessBloc.add(
      Submitted(
        address: _addressController.text,
        //category: _categoryController.text,
        name: _nameController.text,
        telephone: _telephoneController.text,
        user: CurrentUser,
      ),
    );
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    //_categoryController.dispose();
    _nameController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }
}
