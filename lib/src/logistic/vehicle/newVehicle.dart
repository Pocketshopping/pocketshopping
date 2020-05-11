import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:recase/recase.dart';
import 'package:get/get.dart';

class VehicleForm extends StatefulWidget {
  VehicleForm({this.session});
  final Session session;

  @override
  State<StatefulWidget> createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Session CurrentUser;
  bool isSubmitting;
  String type;
  bool autoValidate;



  @override
  void initState() {
    isSubmitting = false;
    type='MotorBike';
    autoValidate=false;
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
                  Get.back();
                },
              ),
              title: Text(
                'New Automobile',
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
                            title: 'New Automobile',
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
                                      SizedBox(height: 10,),
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
                                          controller: _plateController,
                                          decoration: InputDecoration(
                                              labelText: 'Plate Number',
                                              hintText: 'Plate Number',
                                              border: InputBorder.none),
                                          keyboardType: TextInputType.text,
                                          autocorrect: false,
                                          autovalidate: autoValidate,
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Plate number can not be empty';
                                              }
                                              return null;
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
                                          controller: _modelController,
                                          decoration: InputDecoration(
                                              labelText: 'Automobile Model Number',
                                              hintText: 'Automobile Model Number',
                                              border: InputBorder.none),
                                          keyboardType: TextInputType.text,
                                          inputFormatters: <TextInputFormatter>[
                                            //WhitelistingTextInputFormatter.digitsOnly
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
                                          children: <Widget>[
                                            Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  "Automobile Type",
                                                  style: TextStyle(
                                                      color: Colors.black54),
                                                )),
                                            DropdownButtonFormField<String>(
                                              value: type,
                                              items: ['MotorBike','Car','Van']
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
                                              hint: Text('Automobile type'),
                                              decoration: InputDecoration(
                                                  border: InputBorder.none),
                                              onChanged: (value) {
                                                type=value;
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
                                        child: TextFormField(
                                          controller: _nameController,
                                          decoration: InputDecoration(
                                              labelText: 'Automobile Name',
                                              hintText: 'Automobile Name',
                                              border: InputBorder.none),
                                          keyboardType: TextInputType.text,
                                          autocorrect: false,
                                        ),
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
                                                onPressed:(){},
                                                padding: EdgeInsets.all(12),
                                                color: Color.fromRGBO(0, 21, 64, 1),
                                                child: Center(
                                                  child: Text('Submit',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              )
                                          )
                                      ),
                                    ]
                                )
                            ),
                          ),
                        )
                    ),
                  ]
                  )
              )
            ]
            )
        )
    );
  }




  @override
  void dispose() {
    _nameController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    super.dispose();
  }
}
