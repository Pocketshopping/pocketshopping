import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flux_validator_dart/flux_validator_dart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketshopping/constants/ui_constants.dart';
import 'package:pocketshopping/widget/template.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:pocketshopping/component/psCard.dart';
import 'package:camera/camera.dart';
import 'package:pocketshopping/component/TakePicturePage.dart';
import 'package:pocketshopping/page/admin/nextAddProductPage.dart';
//import 'package:camera_utils/camera_utils.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/model/DataModel/staffDataModel.dart';



class AddStaff extends StatefulWidget {
  AddStaff({this.coverUrl='',this.color=null});
  final String coverUrl;
  final Color color;
  @override
  State<StatefulWidget> createState() => _AddStaffState();
}

class _AddStaffState extends State<AddStaff> {

  final _formKey = GlobalKey<FormState>();

  var _psidController = TextEditingController();
  var _jobController = TextEditingController();

  bool orders;
  bool messages;
  bool products;
  bool finances;
  bool managers;

  String office;

  bool loaded;
  String report;
  Map<String,dynamic> sData;






  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    orders=false;
    messages=false;
    products = false;
    finances = false;
    managers = false;
    loaded=false;
    report="";
    sData={};
    office='Office1Office1Office1Office1Office1Office1Office1Office1Office1Office1';

  }







  @override
  Widget build(BuildContext context) {

    final offices = Wrap(
        children:<Widget>[ DropdownButton<String>(
          isExpanded: true,
      value: office,

      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(
          color: Colors.black87

      ),

      onChanged: (String newValue) {
        setState(() {
          office = newValue;
        });
      },
      items: <String>['Office1Office1Office1Office1Office1Office1Office1Office1Office1Office1', 'Two', 'Free', 'Four']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      })
          .toList(),
    )
    ]

    );

    final psid = TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return 'Can not be empty';
        }
        else if (Validator.email(value)) {
          return 'Enter a valid email';
        }
        return null;
      },
      controller: this._psidController,
      textInputAction: TextInputAction.done,

      keyboardType: TextInputType.emailAddress,
      autofocus: false,

      decoration: InputDecoration(
        labelText:"User email",
        hintText: 'User email',
        border: InputBorder.none,
      ),
    );

    final job = TextFormField(
      controller: this._jobController,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.text,
      autofocus: false,

      decoration: InputDecoration(
        labelText:"Job Title (optional)",
        hintText: 'Job Title (Optional)',
        border: InputBorder.none,
      ),
    );

    final orders = CheckboxListTile(
      title: Text("Manage Orders, Staff can view and process customer orders as well as collect payment. staff with this privilege can serve as waiter/cashier/salesperson etc."),
      value: this.orders,
      onChanged: (bool value) {
        setState(() {
          this.orders = value;
        });
      },
    );

    final message = CheckboxListTile(
      title: Text("Manage Customers Message, Staff can view and process customer messages such as complaints and request. staff with this privilege can serve as customer care personel  etc."),
      value: this.messages,
      onChanged: (bool value) {
        setState(() {
          this.messages = value;
        });
      },
    );

    final product = CheckboxListTile(
      title: Text("Manage Product, Staff can Add,Edit and Delete products. staff with this privilege can serve as chefs/store manager   etc."),
      value: this.products,
      onChanged: (bool value) {
        setState(() {
          this.products = value;
        });
      },
    );

    final finance = CheckboxListTile(
      title: Text("Manage Statistic,PocketUnit,Reviews, Staff can View,Generate statistical report which includes financial flow. staff with this privilege can serve as accountant/marketers   etc."),
      value: this.finances,
      onChanged: (bool value) {
        setState(() {
          this.finances = value;
        });
      },
    );

    final manager = CheckboxListTile(
      title: Text("Manage Staff,Branches and Business setttings, this Staff can add new stafffs, create new branches and edit business settings excluding special privilege which are reserve for business owner. staff with this privilege can serve as manager   etc."),
      value: this.managers,
      onChanged: (bool value) {
        setState(() {
          this.managers = value;
        });
      },
    );


    final addStaff=Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: FlatButton(
        color: widget.color,
        onPressed: ()async {
          if (_formKey.currentState.validate()) {
            if(!loaded){
              Map<String,dynamic> data;
              data = await StaffDataModel().getNewStaff(_psidController.text);
              if(data.isNotEmpty){
                if(data['business'].toString().isNotEmpty && data['role'].toString()=='admin' ){
                  setState(() {
                    report="This user owns a business on pocketshopping, you can't add them as staff";
                  });
                }
                else if(data['business'].toString().isNotEmpty && data['role'].toString()=='staff'){
                  setState(() {
                    report="This user is currently a staff pocketshopping, you can't add them as staff";
                  });
                }
                else{
                  setState(() {
                    report="";
                    sData=data;
                    loaded=true;
                  });
                }

              }
              else{
                setState(() {
                  report="No such user on pocketshopping, check the email and try again";
                });
              }

            }
            else{
              setState(() {
                loaded=true;
              });
            }


          }
          else{
            print('added');
          }
        },
        child: Center(child:Text(loaded?'Add Staff':'Next',style: TextStyle(color: Colors.white),)),
      ),
    );


    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.1), // here the desired height
        child:Builder(
          builder: (ctx) =>AppBar(
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(

              icon: Icon(Icons.arrow_back_ios,color:PRIMARYCOLOR,
              ),

              onPressed: (){


                  Scaffold.of(ctx)
                      .showSnackBar(SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text('I am working please wait')));



              },
            ) ,

            title:Text("Staff",style: TextStyle(color: PRIMARYCOLOR),),

            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: Builder(
        builder: (ctx) =>CustomScrollView(
            slivers: <Widget>[  SliverList(
          delegate: SliverChildListDelegate(
            [
              Container(height: MediaQuery.of(context).size.height*0.02,),
              psCard(
                color: widget.color,
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
                          if(!loaded)
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
                            child: psid,
                          ),
                          if(loaded)
                          Column(children: <Widget>[
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
                            child: Center(child:
                            Column(
                              children: <Widget>[
                                Center(
                                  child: Wrap(
                                    children:<Widget>[Text("Please Fill the form below to add ${sData['fname']} as staff"
                                    ,style: TextStyle(fontSize: 18),),
                                      ])
                                      ),
                                SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                                Container(
                                    width: MediaQuery.of(context).size.width*0.35,
                                    height: MediaQuery.of(context).size.height*0.2,
                                    decoration: new BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: new DecorationImage(
                                            fit: BoxFit.fill,
                                            image: new NetworkImage(
                                                sData['profile'].toString().isNotEmpty?sData['profile']:PocketShoppingDefaultAvatar)
                                        )
                                    )),
                                Text(sData['fname'],style: TextStyle(fontSize: 18),)
                              ],
                            )),
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
                            child: job,
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
                                  Align(
                                    alignment: Alignment.centerLeft,
                                      child: Text("Select Office")),

                                  offices
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
                            child: Column(
                              children: <Widget>[
                                Center(
                                  child: FittedBox(fit: BoxFit.fitWidth,
                                    child: Text("select Staff Privilege(s). Note, You can check Multiple privileges"),),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                                orders,
                                SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                                message,
                                SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                                product,
                                SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                                finance,
                                SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                                manager,

                              ],
                            ),
                          ),
                        ],),
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
                            child: Text(report,style: TextStyle(fontSize: 16,color: Colors.redAccent),),
                          ),
                          Container(
                            padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
                            child: addStaff,
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

    );
  }
}