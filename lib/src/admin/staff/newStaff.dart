import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/admin/staff/staffRepo/staffObj.dart';
import 'package:pocketshopping/src/admin/staff/staffRepo/staffPermission.dart';
import 'package:pocketshopping/src/admin/staff/staffRepo/staffRepo.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/logistic/vehicle/repository/vehicleObj.dart';
import 'package:pocketshopping/src/request/repository/requestObject.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class StaffForm extends StatefulWidget {
  StaffForm({this.session});
  final Session session;

  @override
  State<StatefulWidget> createState() => _StaffFormState();
}

class _StaffFormState extends State<StaffForm> {
  final TextEditingController _staffController = TextEditingController();
  final TextEditingController _limitController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseMessaging _fcm = FirebaseMessaging();

  Session currentUser;
  bool isSubmitting;
  String assigned;
  bool autoValidate;
  bool assigning;
  bool hasNotSelected;
  dynamic staff;


  bool sales;
  bool logistic;
  bool products;
  bool finances;
  bool managers;
  Map<String, dynamic> permissions;


  @override
  void initState() {
    assigning = false;
    autoValidate = false;
    isSubmitting = false;
    hasNotSelected = false;

    sales = false;
    logistic = false;
    products = false;
    finances = false;
    managers = false;
    permissions = {};


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double marginLR = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: () async {
          if (isSubmitting)
            return false;
          else {
            return true;
          }
        },
        child: Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              centerTitle: true,
              backgroundColor: Color.fromRGBO(255, 255, 255, 1),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.grey,
                ),
                onPressed: () {
                  if (!isSubmitting) Get.back();
                },
              ),
              title: Text(
                'New Staff',
                style: TextStyle(color: PRIMARYCOLOR),
              ),
              automaticallyImplyLeading: false,
            ),
            backgroundColor: Colors.white,
            body: CustomScrollView(slivers: <Widget>[
              SliverList(
                  delegate: SliverChildListDelegate([
                    Container(
                        padding: EdgeInsets.only(
                            left: marginLR * 0.01, right: marginLR * 0.01),
                        margin: EdgeInsets.only(top: marginLR * 0.01),
                        child: Center(
                          child: psCard(
                            color: PRIMARYCOLOR,
                            title: 'New Staff',
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                //offset: Offset(1.0, 0), //(x,y)
                                blurRadius: 6.0,
                              ),
                            ],
                            child: Form(
                                key: _formKey,
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 10,
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
                                          child: Column(
                                            children: [
                                              Center(
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  radius: 50,
                                                  backgroundImage: staff != null
                                                      ? staff.runtimeType != String
                                                      ? staff.profile.isNotEmpty
                                                      ? NetworkImage(
                                                      staff.profile)
                                                      : NetworkImage(
                                                      PocketShoppingDefaultAvatar)
                                                      : NetworkImage(
                                                      PocketShoppingDefaultAvatar)
                                                      : NetworkImage(
                                                      PocketShoppingDefaultAvatar),
                                                ),
                                              ),
                                              Center(
                                                child: Text(
                                                    '${staff != null ? staff.runtimeType != String ? staff.fname : 'Staff' : 'Staff'}'),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              staff != null
                                                  ? staff.runtimeType == String
                                                  ? Center(
                                                  child: Text(
                                                    'This user can not be a staff, because the account is registered as ${staff=='admin'?' a business owner':' a staff'}',
                                                    style: TextStyle(
                                                        color: Colors.red),textAlign: TextAlign.center,
                                                  ))
                                                  : Container()
                                                  : _staffController.text.isNotEmpty?Center(
                                                  child: Text(
                                                    'No Staff with this ID',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  )):const SizedBox.shrink(),
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
                                            MediaQuery.of(context).size.width *
                                                0.02),
                                        child: TextFormField(
                                          controller: _staffController,
                                          decoration: InputDecoration(
                                              labelText: 'Staff ID',
                                              hintText: 'Staff ID',
                                              border: InputBorder.none),
                                          keyboardType: TextInputType.text,
                                          autocorrect: false,
                                          autovalidate: autoValidate,
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Staff ID can not be empty';
                                            } else if (staff == null) {
                                              return 'No Staff with this ID';
                                            } else if (staff.runtimeType ==
                                                String) {
                                              return 'This user can not be a Staff, because the account is registered as $staff';
                                            }
                                            return null;
                                          },
                                          onChanged: (value) {
                                            if (value.length > 6) {
                                              UserRepo()
                                                  .getOneUsingWallet(value)
                                                  .then((value) => setState(() {
                                                staff = value;
                                                //autoValidate=true;
                                              }));
                                            }
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
                                    child:Center(child: Text('Select Staff Previledge(s)'),)),
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
                                        child: CheckboxListTile(
                                          title: Text(
                                              "Manages Sales."),
                                          value: this.sales,
                                          onChanged: (bool value) {
                                            setState(() {
                                              this.sales = value;
                                            });
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
                                        child: CheckboxListTile(
                                          title: Text(
                                              "Manages Logistics."),
                                          value: this.logistic,
                                          onChanged: (bool value) {
                                            setState(() {
                                              this.logistic = value;
                                            });
                                          },
                                        )
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
                                          child: CheckboxListTile(
                                            title: Text(
                                                "Manages Product."),
                                            value: this.products,
                                            onChanged: (bool value) {
                                              setState(() {
                                                this.products = value;
                                              });
                                            },
                                          )
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
                                          child: CheckboxListTile(
                                            title: Text(
                                                "Manages Financial Statistic."),
                                            value: this.finances,
                                            onChanged: (bool value) {
                                              setState(() {
                                                this.finances = value;
                                              });
                                            },
                                          )
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
                                          child: CheckboxListTile(

                                            title: Text(
                                                "Managerial Role. Reserve all permission"),
                                            value: this.managers,
                                            onChanged: (bool value) {
                                              setState(() {
                                                this.managers = value;
                                                sales = value;
                                                logistic = value;
                                                products = value;
                                                finances = value;
                                              });
                                            },
                                          )
                                      ),
                                if(hasNotSelected)
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
                                    child:Text("Select staff permission.",style: TextStyle(color: Colors.red),)
                                ),
                                      Container(
                                          padding: EdgeInsets.all(
                                              MediaQuery.of(context).size.width *
                                                  0.02),
                                          child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: marginLR * 0.008,
                                                  horizontal: marginLR * 0.08),
                                              child: RaisedButton(
                                                onPressed: !isSubmitting
                                                    ? () {
                                                  if (_formKey.currentState
                                                      .validate() && (sales || finances || logistic || products || managers)) {
                                                    setState(() {
                                                      isSubmitting = true;
                                                    });
                                                    GetBar(
                                                      title: 'Staff',
                                                      messageText: Text(
                                                        'Adding new Staff please wait',
                                                        style: TextStyle(
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      duration:
                                                      Duration(days: 365),
                                                      snackPosition:
                                                      SnackPosition
                                                          .BOTTOM,
                                                      backgroundColor:
                                                      PRIMARYCOLOR,
                                                      showProgressIndicator:
                                                      true,
                                                      progressIndicatorValueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                          Colors.white),
                                                    ).show();
                                                    StaffRepo.save(
                                                      Staff(
                                                        staffPermissions: Permission(
                                                          managers: managers,
                                                          sales: sales,
                                                          finances: finances,
                                                          logistic: logistic,
                                                          products: products
                                                        ),
                                                        staffBehaviour: '',
                                                        staffWorkPlace: widget.session.merchant.mID,
                                                        staffJobTitle: 'Staff',
                                                        staffStatus: 1,
                                                        endDate: null,
                                                        staffID: '',
                                                        staffName: (staff as User).fname,
                                                        staff: (staff as User).uid,


                                                      ),
                                                      Request(
                                                        requestTitle:
                                                        'Work Request',
                                                        requestReceiver:
                                                        staff.uid,
                                                        requestClearedAt:
                                                        null,
                                                        requestAction:
                                                        'STAFFWORKREQUEST',
                                                        requestBody:
                                                        'You are requested to be a staff of ${widget.session.merchant.bName} do you want to accept it.',
                                                        requestCleared: false,
                                                        requestID: '',
                                                      ),
                                                    )
                                                        .then((value)  {
                                                      if (Get
                                                          .isSnackbarOpen)
                                                      {
                                                        Get.back();
                                                        respond(staff.notificationID);
                                                        GetBar(
                                                          title:
                                                          'staff',
                                                          messageText:
                                                          Text(
                                                            'Work request has been sent to the staff once confirmed the staff will be activated.',
                                                            style: TextStyle(
                                                                color:
                                                                Colors.white),
                                                          ),
                                                          duration: Duration(
                                                              seconds:
                                                              5),
                                                          snackPosition:
                                                          SnackPosition
                                                              .BOTTOM,
                                                          backgroundColor:
                                                          PRIMARYCOLOR,
                                                          icon:
                                                          Icon(
                                                            Icons
                                                                .check,
                                                            color: Colors
                                                                .white,
                                                          ),
                                                        ).show();
                                                        _staffController
                                                            .clear();
                                                        setState(
                                                                () {
                                                              autoValidate =
                                                              false;
                                                              staff =
                                                              null;
                                                            });
                                                      }
                                                      setState(() {
                                                        isSubmitting =
                                                        false;
                                                      });
                                                    })
                                                        .catchError((_) {
                                                      if (Get
                                                          .isSnackbarOpen) {
                                                        Get.back();
                                                        GetBar(
                                                          title: 'staff',
                                                          messageText: Text(
                                                            'Error adding Staff, check your connection and try again',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          duration: Duration(
                                                              seconds: 3),
                                                          snackPosition:
                                                          SnackPosition
                                                              .BOTTOM,
                                                          backgroundColor:
                                                          Colors.red,
                                                          icon: Icon(
                                                            Icons.check,
                                                            color:
                                                            Colors.white,
                                                          ),
                                                        ).show();
                                                        setState(() {
                                                          isSubmitting =
                                                          false;
                                                        });
                                                      }
                                                    });
                                                  } else {
                                                    setState(() {
                                                      autoValidate = true;
                                                      if(!(sales || finances || logistic || products || managers))
                                                        hasNotSelected= true;
                                                      else
                                                        hasNotSelected=false;
                                                    });
                                                  }
                                                }
                                                    : null,
                                                padding: EdgeInsets.all(12),
                                                color: Color.fromRGBO(0, 21, 64, 1),
                                                child: Center(
                                                  child: Text('Submit',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              ))),
                                    ])),
                          ),
                        )),
                  ]))
            ])));
  }

  @override
  void dispose() {
    _staffController.dispose();
    super.dispose();
  }



  Future<void> respond(String fcm) async {
    //print('team meeting');
    await _fcm.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: false),
    );
    await http.post('https://fcm.googleapis.com/fcm/send',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken'
        },
        body: jsonEncode(<String, dynamic>{
          'notification': <String, dynamic>{
            'body':  'You have a request to attend to click for more information',
            'title': 'Request'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'payload': {
              'NotificationType': 'WorkRequestResponse',
            }
          },
          'to': fcm,
        }));
  }



}
