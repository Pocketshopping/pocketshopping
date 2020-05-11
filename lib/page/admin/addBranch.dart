import 'package:flutter/material.dart';
import 'package:pocketshopping/component/psCard.dart';
import 'package:pocketshopping/component/psProvider.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/model/DataModel/merchantData.dart';
import 'package:share/share.dart';


class AddBranch extends StatefulWidget {
  AddBranch({this.coverUrl = '', this.color = null});

  final String coverUrl;
  final Color color;

  @override
  State<StatefulWidget> createState() => _AddBranchState();
}

class _AddBranchState extends State<AddBranch> {
  final _formKey = GlobalKey<FormState>();

  bool orders;
  bool messages;
  bool products;
  bool finances;
  bool managers;

  String office;

  bool loaded;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    orders = false;
    messages = false;
    products = false;
    finances = false;
    managers = false;
    loaded = true;
    office =
        'Office1Office1Office1Office1Office1Office1Office1Office1Office1Office1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).size.height *
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
                  /*if(true){
                  Scaffold.of(ctx)
                      .showSnackBar(SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text('I am working please wait')));
                }
                else{*/
                  Navigator.pop(context);
                  //}
                },
              ),
              title: Text(
                "Branch",
                style: TextStyle(color: PRIMARYCOLOR),
              ),
              automaticallyImplyLeading: false,
            ),
          ),
        ),
        body: FutureBuilder<String>(
            future: MerchantDataModel()
                .BranchOTP(psProvider.of(context).value['user']['merchantID']),
            builder: (context, AsyncSnapshot<String> snapshot) {
              return CustomScrollView(slivers: <Widget>[
                SliverList(
                    delegate: SliverChildListDelegate(
                  [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    psCard(
                        color: widget.color,
                        title: 'New Business Branch',
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            //offset: Offset(1.0, 0), //(x,y)
                            blurRadius: 6.0,
                          ),
                        ],
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
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
                                              child: Container(
                                                  child: Column(
                                            children: <Widget>[
                                              Text(
                                                "Use the link below  to create new branch on a new device.",
                                                style: TextStyle(fontSize: 18),
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.02,
                                              ),
                                              Text(
                                                  "The new device will have admin privileges while you retain "
                                                  "superAdmin privilege on the new branch. Note this link only last for 60minute")
                                            ],
                                          ))),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.02,
                                          ),
                                          snapshot.hasData
                                              ? Center(
                                                  child: Container(
                                                  child: Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        flex: 3,
                                                        child: Text(
                                                          snapshot.data ?? "",
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color: Colors
                                                                  .black54),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 0,
                                                        child: IconButton(
                                                          onPressed: () {
                                                            Share.share(
                                                                snapshot.data);
                                                          },
                                                          icon:
                                                              Icon(Icons.share),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ))
                                              : Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.02,
                                          ),
                                        ],
                                      )),
                                    ),
                                  ],
                                )
                            ])),
                  ],
                )),
              ]);
            }));
  }
}
