import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/logistic/vehicle/repository/vehicleObj.dart';
import 'package:pocketshopping/src/request/repository/requestObject.dart';
import 'package:pocketshopping/src/statistic/agentStatistic/agentStatistic.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';

import 'repository/agentObj.dart';

class AgentForm extends StatefulWidget {
  AgentForm({this.session});

  final Session session;

  @override
  State<StatefulWidget> createState() => _AgentFormState();
}

class _AgentFormState extends State<AgentForm> {
  final TextEditingController _agentController = TextEditingController();
  final TextEditingController _limitController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  Session currentUser;
  bool isSubmitting;
  String type;
  String assigned;
  List<String> assign;
  bool autoValidate;
  bool assigning;
  Map<String, AutoMobile> typeData;
  dynamic agent;

  @override
  void initState() {
    typeData = Map();
    assigning = false;
    autoValidate = false;
    isSubmitting = false;
    type = 'Select';
    assigned = 'Select';
    assign = ['Select'];
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
                  else Get.back();
                },
              ),
              title: Text(
                'New Rider',
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
                        title: 'New Rider',
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
                                      controller: _agentController,
                                      decoration: InputDecoration(
                                          labelText: 'Enter User ID',
                                          hintText: 'Enter User ID',
                                          border: InputBorder.none),
                                      keyboardType: TextInputType.number,
                                      autovalidate: autoValidate,
                                      maxLength: 10,

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
                                    child: TextFormField(
                                      controller: _limitController,
                                      decoration: InputDecoration(
                                          labelText: 'Collection Limit:$CURRENCY',
                                          hintText: 'Collection Limit:$CURRENCY',
                                          border: InputBorder.none),
                                      keyboardType: TextInputType.number,
                                      autocorrect: false,
                                      autovalidate: autoValidate,
                                      inputFormatters: <TextInputFormatter>[ WhitelistingTextInputFormatter.digitsOnly],
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Collection Limit can not be empty';
                                        }
                                        if ((int.tryParse(value.trim())??0) < 1000) {
                                          return 'Collection Limit must be greater than $CURRENCY 1000';
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
                                          validator: (value) {
                                            if (value == 'Select') {
                                              return 'Select an Automobile';
                                            }
                                            return null;
                                          },
                                          autovalidate: autoValidate,
                                          value: type,
                                          items: [
                                            'Select',
                                            'MotorBike',
                                            'Car',
                                            'Van'
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
                                          hint: Text('Automobile type'),
                                          decoration: InputDecoration(
                                              border: InputBorder.none),
                                          onChanged: (value) {
                                            setState(() {
                                              type = value;
                                              if (value != 'Select') {
                                                assigning = true;
                                                LogisticRepo.getUnassignedType(
                                                        widget.session.merchant
                                                            .mID,
                                                        value)
                                                    .then((value) =>
                                                        setState(() {
                                                          if (value.length > 0) {
                                                            typeData = value;
                                                            assign = ['Select'];
                                                            assign.addAll(value.keys.toList());
                                                          } else {
                                                            assigned = 'Select';
                                                            assign = ['Select'];
                                                          }
                                                          assigning = false;
                                                        }));
                                              } else {
                                                assigning = false;
                                                assign = ['Select'];
                                              }
                                            });
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
                                        MediaQuery.of(context).size.width *
                                            0.02),
                                    child: !assigning
                                        ? Column(
                                            children: <Widget>[
                                              Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    "Assign Automobile",
                                                    style: TextStyle(
                                                        color: Colors.black54),
                                                  )),
                                              DropdownButtonFormField<String>(
                                                validator: (value) {
                                                  if (value == 'Select') {
                                                    return 'Assign an Automobile';
                                                  }
                                                  return null;
                                                },
                                                autovalidate: autoValidate,
                                                value: assigned,
                                                items: assign
                                                    .map((label) =>
                                                        DropdownMenuItem(
                                                          child: Text(
                                                            label,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black54),
                                                          ),
                                                          value: label,
                                                        ))
                                                    .toList(),
                                                isExpanded: true,
                                                hint: Text(
                                                    'Assign an Automobile'),
                                                decoration: InputDecoration(
                                                    border: InputBorder.none),
                                                onChanged: (value) {
                                                  setState(() {
                                                    assigned = value;
                                                    //print(value);
                                                    //value != 'Select'?assigning=true:assign=['Select'];
                                                  });
                                                },
                                              )
                                            ],
                                          )
                                        : Center(
                                            child: JumpingDotsProgressIndicator(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.08,
                                              color: PRIMARYCOLOR,
                                            ),
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
                                            onPressed: !isSubmitting ? () async{
                                                    if (_formKey.currentState.validate()) {
                                                      setState(() {isSubmitting = true;});
                                                      Utility.bottomProgressLoader(title: 'Rider',body: 'Adding new Rider please wait');
                                                      User agent = await UserRepo.getUserUsingWallet(_agentController.text);
                                                      if(agent != null){
                                                        if(agent.role == 'user'){
                                                          bool result =await LogisticRepo.saveAgent(
                                                            Agent(
                                                                agentWorkPlace: widget.session.merchant.mID,
                                                                agentID: '',
                                                                agentBehaviour: '',
                                                                agentCreatedAt: Timestamp.now(),
                                                                startDate: Timestamp.now(),
                                                                endDate: null,
                                                                autoAssigned: typeData[assigned].autoID,
                                                                agent: agent.uid,
                                                                name: agent.fname,
                                                                limit: int.tryParse(_limitController.text.trim())??10000,
                                                                agentWallet: agent.walletId,
                                                                autoType: type,
                                                                accepted: false,
                                                                agentStatus:1,
                                                                workPlaceWallet: widget.session.merchant.bWallet),
                                                            Request(
                                                              requestTitle: 'Work Request',
                                                              requestReceiver: agent.uid,
                                                              requestClearedAt: null,
                                                              requestAction: 'WORKREQUEST',
                                                              requestBody: 'You are requested to be a rider of ${widget.session.merchant.bName} do you want to accept it.',
                                                              requestCleared: false,
                                                              requestID: '',
                                                            ),
                                                            AgentStatistic(
                                                              agent: agent.uid,
                                                              totalAmount: 0,
                                                              totalCancelled: 0,
                                                              totalDistance: 0,
                                                              totalOrderCount: 0,
                                                              totalUnitUsed: 0,
                                                            ),
                                                          );
                                                          if(result){
                                                            Get.back();
                                                            Utility.pushNotifier(
                                                                fcm: agent.notificationID,
                                                                body: 'You have a request to attend to click for more information',
                                                                title: 'Request',
                                                                notificationType: 'WorkRequestResponse',
                                                                data: {}
                                                            );
                                                            setState(() {isSubmitting = false;autoValidate = false;});
                                                            _agentController.clear();
                                                            Utility.bottomProgressSuccess(title: 'Rider', body: 'Work request has been sent to ${agent.fname} once confirmed,  ${agent.fname} will be activated as a Rider.');
                                                          }
                                                          else{
                                                            Get.back();
                                                            Utility.bottomProgressFailure(title: 'Rider',body: 'Error adding ${agent.fname}, check your connection and try again');
                                                            setState(() {isSubmitting = false;});
                                                          }
                                                        }
                                                        else if(agent.role == 'rider'){
                                                          Get.back();
                                                          Utility.bottomProgressFailure(title: 'Rider',body: 'Sorry. ${agent.fname} is a rider of another organization.',duration: 5);
                                                          setState(() {isSubmitting = false;});
                                                        }
                                                        else if(agent.role == 'staff'){
                                                          Get.back();
                                                          Utility.bottomProgressFailure(title: 'Staff',body: 'Sorry. ${agent.fname} is a staff of another organization.',duration: 5);
                                                          setState(() {isSubmitting = false;});
                                                        }
                                                        else{
                                                          Get.back();
                                                          Utility.bottomProgressFailure(title: 'Business Owner',body: 'Sorry. ${agent.fname} is a business owner. Can not be added as a rider',duration: 5);
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
    _agentController.dispose();
    super.dispose();
  }







}
