import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/admin/staff/staffRepo/staffObj.dart';
import 'package:pocketshopping/src/admin/staff/staffRepo/staffPermission.dart';
import 'package:pocketshopping/src/admin/staff/staffRepo/staffRepo.dart';
import 'package:pocketshopping/src/request/repository/requestObject.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';

class StaffForm extends StatefulWidget {
  StaffForm({this.session});
  final Session session;

  @override
  State<StatefulWidget> createState() => _StaffFormState();
}

class _StaffFormState extends State<StaffForm> {
  final TextEditingController _staffController = TextEditingController();
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
                  if (!isSubmitting) Get.back(result: 'Done');
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
                                        child: TextFormField(
                                          controller: _staffController,
                                          decoration: InputDecoration(
                                              labelText: 'Enter User ID',
                                              hintText: 'Enter User ID',
                                              border: InputBorder.none),
                                          keyboardType: TextInputType.number,
                                          autovalidate: autoValidate,
                                          maxLength: 10,
                                          inputFormatters: <TextInputFormatter>[ WhitelistingTextInputFormatter.digitsOnly],
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'User ID can not be empty';
                                            } else if (value.length < 10) {
                                              return 'Enter a valid User ID';
                                            }
                                            return null;
                                          },
                                          onChanged: (value) {},
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
                                                onPressed: !isSubmitting ? () async{
                                                  if (_formKey.currentState.validate() && (sales || finances || logistic || products || managers)) {
                                                    setState(() {isSubmitting = true;});
                                                    Utility.bottomProgressLoader(title: 'Staff',body: 'Adding new Staff please wait');
                                                    User staff = await UserRepo.getUserUsingWallet(_staffController.text);

                                                    if(staff != null){
                                                      if(staff.role == 'user'){
                                                        bool result = await StaffRepo.save(
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
                                                            staffName: staff.fname,
                                                            staff: staff.uid,
                                                            parentAllowed: true,
                                                            staffWorkPlaceWallet: widget.session.merchant.bWallet,
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
                                                              requestInitiator: widget.session.merchant.bName,
                                                              //requestInitiatorID: widget.session.merchant.mID,
                                                              requestCreatedAt: Timestamp.now()
                                                          ),
                                                        );
                                                        if(result){
                                                          _staffController.clear();
                                                          setState(() {autoValidate = false;});
                                                          Get.back();
                                                          await respond(staff.notificationID);
                                                          setState(() {isSubmitting = false;});
                                                          Utility.bottomProgressSuccess(title: 'staff',body: 'Work request has been sent to ${staff.fname} once confirmed ${staff.fname} will be activated as a staff.',goBack: true);

                                                        }
                                                        else{
                                                          Get.back();
                                                          Utility.bottomProgressFailure(title: 'staff',body: 'Error adding ${staff.fname}, check your connection and try again');
                                                          setState(() {isSubmitting = false;});
                                                        }
                                                      }
                                                      else if(staff.role == 'rider'){
                                                        Get.back();
                                                        Utility.bottomProgressFailure(title: 'Rider',body: 'Sorry. ${staff.fname} is a rider of another organization.',duration: 5);
                                                        setState(() {isSubmitting = false;});
                                                      }
                                                      else if(staff.role == 'staff'){
                                                        Get.back();
                                                        Utility.bottomProgressFailure(title: 'staff',body: 'Sorry. ${staff.fname} is a staff of another organization.',duration: 5);
                                                        setState(() {isSubmitting = false;});
                                                      }
                                                      else{
                                                        Get.back();
                                                        Utility.bottomProgressFailure(title: 'Owner',body: 'Sorry. ${staff.fname} is  a business owner. Can not be added as a staff',duration: 5);
                                                        setState(() {isSubmitting = false;});
                                                      }
                                                    }
                                                    else{
                                                      Get.back();
                                                      Utility.bottomProgressFailure(title: 'Invalid User',body: 'The ID you entered is not a valid user ID check the ID and try again.',duration: 5);
                                                      setState(() {isSubmitting = false;});
                                                    }



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
    await Utility.pushNotifier(
      fcm: fcm,
      body: 'You have a request to attend to click for more information',
      title: 'Request',
      notificationType: 'WorkRequestResponse',
      data: {}
    );
  }



}
