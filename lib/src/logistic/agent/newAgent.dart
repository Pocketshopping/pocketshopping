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
                                      child: Column(
                                        children: [
                                          Center(
                                            child: CircleAvatar(
                                              backgroundColor: Colors.white,
                                              radius: 50,
                                              backgroundImage: agent != null
                                                  ? agent.runtimeType != String
                                                      ? agent.profile.isNotEmpty
                                                          ? NetworkImage(
                                                              agent.profile)
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
                                                '${agent != null ? agent.runtimeType != String ? agent.fname : 'Rider' : 'Rider'}'),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          agent != null
                                              ? agent.runtimeType == String
                                                  ? Center(
                                                      child: Text(
                                                      'This user can not be a Rider, because the account is registered as ${agent=='admin'?' a business owner':' a staff'}',
                                                      style: TextStyle(
                                                          color: Colors.red),textAlign: TextAlign.center,
                                                    ))
                                                  : Container()
                                              : _agentController.text.isNotEmpty?Center(
                                                  child: Text(
                                                  'No Rider with this ID',
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
                                      controller: _agentController,
                                      decoration: InputDecoration(
                                          labelText: 'Rider ID',
                                          hintText: 'Rider ID',
                                          border: InputBorder.none),
                                      keyboardType: TextInputType.text,
                                      autocorrect: false,
                                      autovalidate: autoValidate,

                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Rider ID can not be empty';
                                        } else if (agent == null) {
                                          return 'No Rider with this ID';
                                        } else if (agent.runtimeType ==
                                            String) {
                                          return 'This user can not be a Rider, because the account is registered as $agent';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        if (value.length > 6) {
                                          UserRepo()
                                              .getOneUsingWallet(value)
                                              .then((value) => setState(() {
                                                    agent = value;
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
                                    child: TextFormField(
                                      controller: _limitController,
                                      decoration: InputDecoration(
                                          labelText: 'Collection Limit:$CURRENCY',
                                          hintText: 'Collection Limit:$CURRENCY',
                                          border: InputBorder.none),
                                      keyboardType: TextInputType.number,
                                      autocorrect: false,
                                      autovalidate: autoValidate,
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
                                                          if (value.length >
                                                              0) {
                                                            typeData = value;
                                                            assign = ['Select'];
                                                            assign.addAll(value
                                                                .keys
                                                                .toList());
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
                                                    print(value);
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
                                            onPressed: !isSubmitting
                                                ? () {
                                                    if (_formKey.currentState
                                                        .validate()) {
                                                      setState(() {
                                                        isSubmitting = true;
                                                      });
                                                      GetBar(
                                                        title: 'Rider',
                                                        messageText: Text(
                                                          'Adding new Rider please wait',
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
                                                      LogisticRepo.saveAgent(
                                                              Agent(
                                                                  agentWorkPlace:
                                                                      widget
                                                                          .session
                                                                          .merchant
                                                                          .mID,
                                                                  agentID: '',
                                                                  agentBehaviour:
                                                                      '',
                                                                  agentCreatedAt:
                                                                      Timestamp
                                                                          .now(),
                                                                  startDate:
                                                                      Timestamp
                                                                          .now(),
                                                                  endDate: null,
                                                                  autoAssigned:
                                                                      typeData[
                                                                              assigned]
                                                                          .autoID,
                                                                  agent:
                                                                      agent.uid,
                                                                  name: (agent as User).fname,
                                                                  limit: int.tryParse(_limitController.text.trim())??10000,
                                                                  agentWallet: agent.walletId,
                                                                  autoType:
                                                                      type,
                                                                  agentStatus:1,
                                                              workPlaceWallet: widget.
                                                                            session.
                                                                            user.
                                                                            walletId),
                                                              Request(
                                                                requestTitle:
                                                                    'Work Request',
                                                                requestReceiver:
                                                                    agent.uid,
                                                                requestClearedAt:
                                                                    null,
                                                                requestAction:
                                                                    'WORKREQUEST',
                                                                requestBody:
                                                                    'You are requested to be an delivery agent of ${widget.session.merchant.bName} do you want to accept it.',
                                                                requestCleared:
                                                                    false,
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
                                                      )
                                                          .then((value)  {
                                                                if (Get
                                                                    .isSnackbarOpen)
                                                                  {
                                                                    Get.back();
                                                                    Utility.pushNotifier(
                                                                    fcm: agent.notificationID,
                                                                    body: 'You have a request to attend to click for more information',
                                                                    title: 'Request',
                                                                    notificationType: 'WorkRequestResponse',
                                                                    data: {}
                                                                    );
                                                                    //requestPusher(agent.notificationID);
                                                                    GetBar(
                                                                      title:
                                                                          'Agent',
                                                                      messageText:
                                                                          Text(
                                                                        'Work request has been sent to the Agent once confirmed the agent will be activated.',
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
                                                                    _agentController
                                                                        .clear();
                                                                    setState(
                                                                        () {
                                                                      autoValidate =
                                                                          false;
                                                                      agent =
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
                                                            title: 'Agent',
                                                            messageText: Text(
                                                              'Error adding Rider, check your connection and try again',
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
