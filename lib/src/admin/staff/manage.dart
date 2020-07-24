import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pocketshopping/src/admin/staff/staffRepo/staffObj.dart';
import 'package:pocketshopping/src/admin/staff/staffRepo/staffPermission.dart';
import 'package:pocketshopping/src/admin/staff/staffRepo/staffRepo.dart';
import 'package:pocketshopping/src/request/repository/requestObject.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';

class ManageStaff extends StatefulWidget {
  ManageStaff({this.session,this.staff});
  final Session session;
  final Staff staff;

  @override
  State<StatefulWidget> createState() => _ManageStaffState();
}

class _ManageStaffState extends State<ManageStaff> {
  final TextEditingController _staffController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseMessaging _fcm = FirebaseMessaging();

  Session currentUser;
  bool isSubmitting;
  String assigned;
  bool autoValidate;
  bool assigning;
  bool hasNotSelected;
  bool editRole;


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
    hasNotSelected = !widget.staff.staffPermissions.sales && !widget.staff.staffPermissions.logistic && !widget.staff.staffPermissions.products &&
        !widget.staff.staffPermissions.finances && !widget.staff.staffPermissions.managers;
    editRole = false;

    sales = widget.staff.staffPermissions.sales;
    logistic = widget.staff.staffPermissions.logistic;
    products = widget.staff.staffPermissions.products;
    finances = widget.staff.staffPermissions.finances;
    managers = widget.staff.staffPermissions.managers;
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
                'Staff',
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
                            title: 'Staff',
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                //offset: Offset(1.0, 0), //(x,y)
                                blurRadius: 6.0,
                              ),
                            ],
                            child: FutureBuilder(
                              future: UserRepo.getOneUsingUID(widget.staff.staff),
                              builder: (context,AsyncSnapshot<User>staff){

                                return Column(
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
                                              if(staff.hasData)
                                              Center(
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  radius: 50,
                                                  backgroundImage: staff.hasData
                                                      ? staff.data.profile.isNotEmpty
                                                      ? NetworkImage(
                                                      staff.data.profile)
                                                      : NetworkImage(
                                                      PocketShoppingDefaultAvatar)
                                                      : NetworkImage(
                                                      PocketShoppingDefaultAvatar),
                                                ),
                                              ),
                                              Center(
                                                child: Text(
                                                    '${widget.staff.staffName}',style: TextStyle(fontSize: 18),),
                                              ),
                                              if(widget.staff.startDate == null)
                                                Center(
                                                  child: Text('User has not yet accepted the job offer',style: TextStyle(color: Colors.red),),
                                                ),
                                              SizedBox(
                                                height: 20,
                                              ),
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
                                          child:Center(child: Text('Staff Previledge(s)'),)),
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

                                          onChanged: editRole?(bool value) {
                                            setState(() {
                                              this.sales = value;
                                              hasNotSelected = !finances && !managers && !products && !sales && !logistic;
                                            });
                                          }:null,
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
                                            onChanged:editRole? (bool value) {
                                              setState(() {
                                                this.logistic = value;
                                                hasNotSelected = !finances && !managers && !products && !sales && !logistic;
                                              });
                                            }:null,
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
                                            onChanged: editRole?(bool value) {
                                              setState(() {
                                                this.products = value;
                                                hasNotSelected = !finances && !managers && !products && !sales && !logistic;
                                              });
                                            }:null,
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
                                            onChanged: editRole?(bool value) {
                                              setState(() {
                                                this.finances = value;
                                                hasNotSelected = !finances && !managers && !products && !sales && !logistic;
                                              });
                                            }:null,
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
                                            onChanged: editRole?(bool value) {
                                              setState(() {
                                                this.managers = value;
                                                sales = value;
                                                logistic = value;
                                                products = value;
                                                finances = value;
                                                hasNotSelected = !finances && !managers && !products && !sales && !logistic;
                                              });
                                            }:null,
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
                                            child:Text("Select staff Previledge(s).",style: TextStyle(color: Colors.red),)
                                        ),
                                      if(editRole)
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
                                                      ? () async{
                                                    setState(() {
                                                      hasNotSelected = !finances && !managers && !products && !sales && !logistic;
                                                    });

                                                    if(!hasNotSelected){
                                                      Utility.bottomProgressLoader(title: 'Updating Staff',body: 'Updating staff please wait');
                                                      Permission permission = Permission(
                                                          managers: managers,
                                                          sales: sales,
                                                          finances: finances,
                                                          logistic: logistic,
                                                          products: products
                                                      );
                                                      bool result = await StaffRepo.updateStaff(widget.staff.staffID, {'staffPermissions':permission.toMap()});
                                                      Get.back();
                                                      if(result)
                                                        {
                                                          Utility.bottomProgressSuccess(title: 'Staff Updated',body: 'Staff previledges has been updated');
                                                          setState(() {
                                                            editRole = false;
                                                          });
                                                          if(widget.staff.startDate != null)
                                                          Utility.pushNotifier(
                                                            fcm: staff.data.notificationID,
                                                            body: 'Your previledge(s) at your ${widget.session.merchant.bName} hass been changed',
                                                            title: '${widget.session.merchant.bName}',
                                                            notificationType: '',
                                                            data: {}
                                                          );
                                                        }
                                                      else
                                                        Utility.bottomProgressFailure(title: 'Error Updating',body: "Error updating staff. check interent and tr again");

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
                                      if(!editRole)
                                        Container(
                                          padding: EdgeInsets.all(
                                              MediaQuery.of(context).size.width *
                                                  0.02),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child:  FlatButton(
                                                  onPressed: (){
                                                    Get.defaultDialog(
                                                      title: 'Confirmation',
                                                      content: Text('Are you sure you want to remove this staff'),
                                                      cancel: FlatButton(
                                                        onPressed: (){Get.back();},
                                                        child: Text('No'),
                                                      ),
                                                      confirm: FlatButton(
                                                        onPressed: ()async{
                                                          Get.back();
                                                          Utility.bottomProgressLoader(title: 'Removing Staff',body: 'Removing staff please wait');
                                                          bool result = await StaffRepo.delete(widget.staff,
                                                            staff.data,
                                                              Request(
                                                                  requestCleared: false,
                                                                  requestClearedAt: null,
                                                                  requestReceiver: staff.data.uid,
                                                                  requestTitle: 'Work',
                                                                  requestAction: 'REMOVEWORK',
                                                                  requestBody: 'The Management of ${widget.session.merchant.bName} has removed your account from list of their staffs. Contact ${widget.session.merchant.bName} for more infomation',
                                                                  requestInitiatorID: widget.session.merchant.mID,
                                                                  requestInitiator: widget.session.merchant.bName,
                                                                  requestCreatedAt: Timestamp.now()
                                                              ),
                                                            merchant: widget.session.merchant.bName,
                                                          );
                                                          Get.back();
                                                          if(result)
                                                          {
                                                            Utility.bottomProgressSuccess(title: 'Staff Removed',body: 'Staff has been removed',goBack: true);
                                                            if(widget.staff.startDate != null)
                                                            await Utility.pushMessage(
                                                                fcm: staff.data.notificationID,
                                                                body: 'You have a request to attend to click for more information',
                                                                title: 'Request',
                                                                notificationType: 'WorkRequestCancelResponse',
                                                                data: {}
                                                            );
                                                          }
                                                          else
                                                            Utility.bottomProgressFailure(title: 'Error Removing staff',body: "Error removing staff. check interent and tr again");

                                                        },
                                                        child: Text('Yes'),
                                                      )
                                                    );
                                                  },
                                                  color: Colors.redAccent,
                                                  child: Center(
                                                    child:
                                                    widget.staff.startDate != null?
                                                    Text('Remove Staff',style: TextStyle(color: Colors.white),):
                                                    Text('Delete Request',style: TextStyle(color: Colors.white),),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 0,
                                                child: const SizedBox(width: 10,),
                                              ),
                                              Expanded(
                                                child: FlatButton(
                                                  onPressed: (){
                                                    setState(() {
                                                      editRole = true;
                                                    });
                                                  },
                                                  color: Colors.green,
                                                  child: Center(child: Text('Edit Previledge(s)',style: TextStyle(color: Colors.white),),),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),




                                    ]);
                              },
                            ),
                          ),
                          ),
                        ),
                  ]))
            ])));
  }

  @override
  void dispose() {
    _staffController.dispose();
    super.dispose();
  }


}
