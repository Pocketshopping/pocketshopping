import 'package:flutter/material.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/ui/shared/dynamicLinks.dart';
import 'package:pocketshopping/src/ui/shared/psCard.dart';
import 'package:share/share.dart';

class Referral extends StatefulWidget {
  final String walletId;

  Referral({this.walletId});

  @override
  _ReferralState createState() => new _ReferralState();
}

class _ReferralState extends State<Referral> {
  String referralLink;

  @override
  void initState() {
    DynamicLinks.createLinkWithParams({
      'referralID': '${widget.walletId}',
      'page': '',
    }).then((value) => setState(() {
          referralLink = value.toString();
        }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            "Referral",
            style: TextStyle(color: PRIMARYCOLOR),
          ),
          automaticallyImplyLeading: false,
        ),
      ),
      body: Center(
        child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            width: MediaQuery.of(context).size.width * 0.9,
            child: psHeadlessCard(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    //offset: Offset(1.0, 0), //(x,y)
                    blurRadius: 6.0,
                  ),
                ],
                child: Column(
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      child: Text(
                        'Refer a business and earn for life.',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Divider(
                      height: 2,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 10),
                      child: Text(
                        'Here is your referral Link.',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    if (referralLink != null)
                      Row(
                        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 10),
                              child: Text(
                                '$referralLink',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 0,
                              child: Padding(
                                padding: EdgeInsets.only(right: 20),
                                child: IconButton(
                                  onPressed: () {
                                    Share.share(referralLink);
                                  },
                                  icon: Icon(Icons.share),
                                ),
                              ))
                        ],
                      ),
                  ],
                ))),
      ),
    );
  }
}
