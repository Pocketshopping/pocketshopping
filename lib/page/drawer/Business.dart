import 'package:flutter/material.dart';
import 'package:pocketshopping/component/psCard.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/page/business.dart';

class BusinessPage extends StatefulWidget {
  @override
  _BusinessPageState createState() => new _BusinessPageState();
}

class _BusinessPageState extends State<BusinessPage> {
  Map<String, dynamic> business;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    /*MerchantDataModel(uid: psProvider.of(context).value['uid']).getOne().then((value) =>
    setState((){
      business=value;
    })
    );*/
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).size.height *
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
              "My Business",
              style: TextStyle(color: PRIMARYCOLOR),
            ),
            automaticallyImplyLeading: false,
          ),
        ),
        body: CustomScrollView(slivers: <Widget>[
          SliverList(
              delegate: SliverChildListDelegate([
            Container(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            psCard(
              color: PRIMARYCOLOR,
              title: 'Business',
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
                          MediaQuery.of(context).size.width * 0.02),
                      child: Text(
                        "You are currently registered as a user you can change to a business account by registering your businsess on pocketshopping",
                        style: TextStyle(),
                      ),
                    )),
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
                          MediaQuery.of(context).size.width * 0.02),
                      child: FlatButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FirstBusinessPage()));
                        },
                        color: PRIMARYCOLOR,
                        child: Text(
                          "Create A business",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )),
                  ]),
            )
          ])),
        ]));
  }
}
