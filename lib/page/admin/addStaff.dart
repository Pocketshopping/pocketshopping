import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flux_validator_dart/flux_validator_dart.dart';
import 'package:pocketshopping/component/psCard.dart';
import 'package:pocketshopping/component/psProvider.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/constants/ui_constants.dart';
import 'package:pocketshopping/model/DataModel/merchantData.dart';
import 'package:pocketshopping/model/DataModel/staffDataModel.dart';
import 'package:pocketshopping/page/admin.dart';

class AddStaff extends StatefulWidget {
  AddStaff({this.color = PRIMARYCOLOR});

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
  Map<String, dynamic> permissions;

  String office;

  bool loaded;
  String report;
  Map<String, dynamic> sData;
  bool loading;
  Map<String, String> bData;
  List<String> branches;
  BuildContext nctx;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    orders = false;
    messages = false;
    products = false;
    finances = false;
    managers = false;
    loaded = false;
    report = "";
    sData = {};
    bData = {};
    loading = false;
    branches = ['Default'];
    office = 'Default';

  }

  setBranches() {
    if (psProvider.of(context).value['user']['isBranch'] != null) if (psProvider
        .of(context)
        .value['user']['isBranch']) {
      branches = [psProvider.of(context).value['user']['businessName']];
      office = psProvider.of(context).value['user']['businessName'];
      bData.putIfAbsent(psProvider.of(context).value['user']['businessName'],
          () => psProvider.of(context).value['user']['merchantID']);
      setState(() {});
    } else {
      MerchantDataModel()
          .getBranch(psProvider.of(context).value['user']['merchantID'])
          .then((result) => {
                branches = [
                  psProvider.of(context).value['user']['businessName']
                ],
                office = psProvider.of(context).value['user']['businessName'],
                bData[psProvider
                        .of(context)
                        .value['user']['businessName']
                        .toString()] =
                    psProvider.of(context).value['user']['merchantID'],
                result.forEach((doc) {
                  branches.add(doc.data['businessName'].toString() +
                      ' (${doc.data['branchUnique'].toString()})');
                  bData[doc.data['businessName'].toString() +
                          ' (${doc.data['branchUnique'].toString()})'] =
                      doc.documentID;
                }),
                //office=branches[0],
                setState(() {})
              });
    }
  }

  @override
  Widget build(BuildContext context) {
    setBranches();

    final offices = Wrap(children: <Widget>[
      DropdownButton<String>(
        isExpanded: true,
        value: office,
        icon: Icon(Icons.arrow_downward),
        iconSize: 24,
        elevation: 16,
        style: TextStyle(color: Colors.black87),
        onChanged: (String newValue) {
          setState(() {
            office = newValue;
          });
        },
        items: branches.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      )
    ]);

    final psid = TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return 'Can not be empty';
        } else if (Validator.email(value)) {
          return 'Enter a valid email';
        }
        return null;
      },
      controller: this._psidController,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: InputDecoration(
        labelText: "User email",
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
        labelText: "Job Title (optional)",
        hintText: 'Job Title (Optional)',
        border: InputBorder.none,
      ),
    );

    final order = CheckboxListTile(
      title: Text(
          "Manage Orders, Staff can view and process customer orders as well as collect payment. staff with this privilege can serve as waiter/cashier/salesperson etc."),
      value: this.orders,
      onChanged: (bool value) {
        setState(() {
          this.orders = value;
        });
      },
    );

    CheckboxListTile message = CheckboxListTile(
      title: Text(
          "Manage Customers Message, Staff can view and process customer messages such as complaints and request. staff with this privilege can serve as customer care personel  etc."),
      value: this.messages,
      onChanged: (bool value) {
        setState(() {
          this.messages = value;
        });
      },
    );

    final product = CheckboxListTile(
      title: Text(
          "Manage Product, Staff can Add,Edit and Delete products. staff with this privilege can serve as chefs/store manager   etc."),
      value: this.products,
      onChanged: (bool value) {
        setState(() {
          this.products = value;
        });
      },
    );

    final finance = CheckboxListTile(
      title: Text(
          "Manage Statistic,PocketUnit,Reviews, Staff can View,Generate statistical report which includes financial flow. staff with this privilege can serve as accountant/marketers   etc."),
      value: this.finances,
      onChanged: (bool value) {
        setState(() {
          this.finances = value;
        });
      },
    );

    final manager = CheckboxListTile(
      title: Text(
          "Manage Staff,Business setttings and overall business, this Staff can add new stafffs, edit business settings and perform all function excluding special privilege which are reserve for business owner. staff with this privilege can serve as manager   etc."),
      value: this.managers,
      onChanged: (bool value) {
        setState(() {
          this.managers = value;
          orders = value;
          messages = value;
          products = value;
          finances = value;
        });
      },
    );

    final addStaff = Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: FlatButton(
        color: widget.color,
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            if (!loaded) {
              setState(() {
                loading = true;
              });
              Map<String, dynamic> data;
              data = await StaffDataModel().getNewStaff(_psidController.text);
              if (data.isNotEmpty) {
                if (_psidController.text ==
                    psProvider.of(context).value['user']['email']) {
                  setState(() {
                    report = "You own the business";
                  });
                } else if (data['business'].toString().isNotEmpty &&
                    data['role'].toString() == 'admin') {
                  setState(() {
                    report =
                        "This user owns a business on pocketshopping, you can't add them as staff";
                  });
                } else if (data['business'].toString().isNotEmpty &&
                    data['role'].toString() == 'staff') {
                  setState(() {
                    report =
                        "This user is currently a staff pocketshopping, you can't add them as staff";
                  });
                } else {
                  setState(() {
                    report = "";
                    sData = data;
                    loaded = true;
                  });
                }
                setState(() {
                  loading = false;
                });
              } else {
                setState(() {
                  report =
                      "No such user on pocketshopping, check the email and try again";
                });
              }
            } else {
              Map<String, dynamic> permissions = {
                'orders': order.value,
                'messages': message.value,
                'products': product.value,
                'finances': finance.value,
                'managers': manager.value
              };
              if (permissions.containsValue(true)) {
                setState(() {
                  //loaded=false;
                  loading = true;
                });
                print(bData[office]);
                StaffDataModel(
                  mRef: bData[office],
                  sJobTitle: _jobController.text,
                  sPermissions: permissions,
                  sRef: sData['staffID'],
                  sBehaviour: null,
                  sStatus: 'PENDING',
                ).save().then((value) => {
                      setState(() {
                        loaded = false;
                        loading = false;
                        _jobController.clear();
                        _psidController.clear();
                        managers = false;
                        orders = false;
                        messages = false;
                        finances = false;
                        products = false;
                      }),
                      Scaffold.of(nctx).showSnackBar(SnackBar(
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 5),
                        content: Text(
                            '${sData['fname']} as been sent a request! Once accepted will be added as a staff'),
                        behavior: SnackBarBehavior.floating,
                      )),
                    });
              } else {
                Scaffold.of(nctx).showSnackBar(SnackBar(
                  content: Text(
                      'You have to select atleast one permission to add staff '),
                  behavior: SnackBarBehavior.floating,
                ));
              }
            }
          } else {
            print('added');
          }
        },
        child: Center(
            child: !loading
                ? Text(
                    loaded ? 'Add Staff' : 'Next',
                    style: TextStyle(color: Colors.white),
                  )
                : SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(),
                  )),
      ),
    );

    return WillPopScope(
        onWillPop: () async {
          if (!loading) {
            return Navigator.push(
                context, MaterialPageRoute(builder: (context) => AdminPage()));
          } else
            return false;
        },
        child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(
                  MediaQuery.of(context).size.height *
                      0.1), // here the desired height
              child: Builder(
                builder: (ctx) => AppBar(
                  centerTitle: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: PRIMARYCOLOR,
                    ),
                    onPressed: () {
                      if (!loading) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdminPage()));
                      }
                    },
                  ),
                  title: Text(
                    "Staff",
                    style: TextStyle(color: PRIMARYCOLOR),
                  ),
                  automaticallyImplyLeading: false,
                ),
              ),
            ),
            body: Builder(builder: (ctx) {
              nctx = ctx;
              return CustomScrollView(slivers: <Widget>[
                SliverList(
                    delegate: SliverChildListDelegate(
                  [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
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
                                if (!loaded)
                                  Column(
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
                                            MediaQuery.of(context).size.width *
                                                0.02),
                                        child: Text(
                                            'Enter email of new staff! Note user email must be registered on pockshopping'),
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
                                        child: psid,
                                      ),
                                    ],
                                  ),
                                if (loaded)
                                  Column(
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
                                            MediaQuery.of(context).size.width *
                                                0.02),
                                        child: Center(
                                            child: Column(
                                          children: <Widget>[
                                            Center(
                                                child: Wrap(children: <Widget>[
                                              Text(
                                                "Please Fill the form below to add ${sData['fname']} as staff",
                                                style: TextStyle(fontSize: 18),
                                              ),
                                            ])),
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02,
                                            ),
                                            Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.35,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.2,
                                                decoration: new BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: new DecorationImage(
                                                        fit: BoxFit.fill,
                                                        image: new NetworkImage(
                                                            sData['profile']
                                                                    .toString()
                                                                    .isNotEmpty
                                                                ? sData[
                                                                    'profile']
                                                                : PocketShoppingDefaultAvatar)))),
                                            Text(
                                              sData['fname'],
                                              style: TextStyle(fontSize: 18),
                                            )
                                          ],
                                        )),
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
                                        child: job,
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
                                                child: Text("Select Office")),
                                            offices
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
                                        child: Column(
                                          children: <Widget>[
                                            Center(
                                              child: Text(
                                                  "select Staff Privilege(s). Note, You can check Multiple privileges"),
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02,
                                            ),
                                            order,
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02,
                                            ),
                                            message,
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02,
                                            ),
                                            product,
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02,
                                            ),
                                            finance,
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02,
                                            ),
                                            manager,
                                          ],
                                        ),
                                      ),
                                    ],
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
                                  child: Text(
                                    report,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.redAccent),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(
                                      MediaQuery.of(context).size.width * 0.02),
                                  child: addStaff,
                                ),
                              ])),
                    ),
                  ],
                )),
              ]);
            })));
  }
}
