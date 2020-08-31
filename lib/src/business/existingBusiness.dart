import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';

class ExistingBusiness extends StatefulWidget {
  @override
  _ExistingBusinessState createState() => new _ExistingBusinessState();
}

class _ExistingBusinessState extends State<ExistingBusiness> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(Get.height *
              0.1), // here the desired height
          child: AppBar(
            centerTitle: true,
            elevation: 0.0,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: PRIMARYCOLOR,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              "Business Setup",
              style: TextStyle(color: PRIMARYCOLOR),
            ),
            automaticallyImplyLeading: false,
          ),
        ),
        body: Builder(
            builder: (ctx) => CustomScrollView(slivers: <Widget>[
                  SliverList(
                      delegate: SliverChildListDelegate([
                    Container(
                      height: Get.height * 0.02,
                    ),
                    psCard(
                      color: PRIMARYCOLOR,
                      title: 'New Branch',
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
                            Center(
                                child: Container(
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
                                  Get.width * 0.02),
                              child: Text(
                                "To create a branch you need to request for branch link from the exisiting"
                                " business, once recieved you can create branch by visiting the link."
                                "",
                                style: TextStyle(fontSize: 16),
                              ),
                            )),
                          ]),
                    )
                  ])),
                ])));
  }
}
