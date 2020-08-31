import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/logistic/vehicle/repository/vehicleObj.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';

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
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isSubmitting;
  String type;
  bool autoValidate;
  bool trueFalse;

  @override
  void initState() {
    trueFalse = false;
    isSubmitting = false;
    type = 'MotorBike';
    autoValidate = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double marginLR = Get.width;
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
                                        Get.width *
                                            0.02),
                                    child: TextFormField(
                                      controller: _plateController,
                                      decoration: InputDecoration(
                                          labelText: 'Plate Number',
                                          border: InputBorder.none),
                                      keyboardType: TextInputType.text,
                                      autocorrect: false,
                                      autovalidate: autoValidate,
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Plate number can not be empty';
                                        }
                                        if (trueFalse) {
                                          return 'AutoMobile is already in the database';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        isNew(value);
                                        if(mounted)
                                        setState(() {
                                          autoValidate = true;
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
                                        Get.width *
                                            0.02),
                                    child: TextFormField(
                                      controller: _modelController,
                                      decoration: InputDecoration(
                                          labelText: 'Automobile Model Number',
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
                                        Get.width *
                                            0.02),
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
                                          items: ['MotorBike', 'Car', 'Van']
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
                                          hint: Text('Automobile type'),
                                          decoration: InputDecoration(
                                              border: InputBorder.none),
                                          onChanged: (value) {
                                            type = value;
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
                                        Get.width *
                                            0.02),
                                    child: TextFormField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                          labelText: 'Automobile Name',
                                          border: InputBorder.none),
                                      keyboardType: TextInputType.text,
                                      autocorrect: false,
                                    ),
                                  ),
                                  Container(
                                      padding: EdgeInsets.all(
                                          Get.width *
                                              0.02),
                                      child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: marginLR * 0.008,
                                              horizontal: marginLR * 0.08),
                                          child: RaisedButton(
                                            onPressed: !isSubmitting
                                                ? () {
                                                    if (_formKey.currentState
                                                        .validate()) {
                                                      if(mounted)
                                                      setState(() {
                                                        isSubmitting = true;
                                                      });
                                                      GetBar(
                                                        title: 'Automobile',
                                                        messageText: Text(
                                                          'Adding new $type please wait',
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
                                                      LogisticRepo.saveAutomobile(AutoMobile(
                                                              autoLogistic:
                                                                  widget
                                                                      .session
                                                                      .merchant
                                                                      .mID,
                                                              autoID: '',
                                                              autoModelNumber:
                                                                  _modelController
                                                                      .text,
                                                              autoName:
                                                                  _nameController
                                                                      .text,
                                                              autoPlateNumber:
                                                                  _plateController
                                                                      .text,
                                                              autoAssigned:
                                                                  false,
                                                              autoType: type),
                                                              bCount: type == 'MotorBike' ?(widget.session.merchant.bikeCount+1):widget.session.merchant.bikeCount,
                                                              cCount: type == 'Car' ?(widget.session.merchant.carCount+1):widget.session.merchant.carCount,
                                                              vCount: type == 'Van' ?(widget.session.merchant.vanCount+1):widget.session.merchant.vanCount,
                                                      )
                                                          .then((value) => {
                                                                if (Get
                                                                    .isSnackbarOpen)
                                                                  {
                                                                    Get.back(),
                                                                    GetBar(
                                                                      title:
                                                                          'Automobile',
                                                                      messageText:
                                                                          Text(
                                                                        '$type added successfully',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                                      duration: Duration(
                                                                          seconds:
                                                                              3),
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
                                                                    ).show(),
                                                                    _plateController
                                                                        .clear(),
                                                                    _nameController
                                                                        .clear(),
                                                                    _modelController
                                                                        .clear(),
                                                                    if(mounted)
                                                                    setState(
                                                                        () {
                                                                      autoValidate =
                                                                          false;
                                                                    }),
                                                                  },
                                                        if(mounted)
                                                                setState(() {
                                                                  isSubmitting =
                                                                      false;
                                                                })
                                                              })
                                                          .catchError((_) {
                                                        if (Get
                                                            .isSnackbarOpen) {
                                                          Get.back();
                                                          GetBar(
                                                            title: 'Automobile',
                                                            messageText: Text(
                                                              'Error adding Automobile, check your connection and try again',
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
                                                          if(mounted)
                                                          setState(() {
                                                            isSubmitting =
                                                                false;
                                                          });
                                                        }
                                                      });
                                                    } else {
                                                      if(mounted)
                                                      setState(() {
                                                        autoValidate = true;
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

  bool isNew(String value) {
    LogisticRepo.alreadyAdded(widget.session.merchant.mID, value)
        .then((value) => setState(() {
              trueFalse = value;
            }));
    return true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    super.dispose();
  }
}
