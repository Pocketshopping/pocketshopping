import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/page/signUp.dart';

class Introduction extends StatelessWidget {
  Introduction({this.linkdata});

  Map<String, dynamic> linkdata;
  BuildContext bcontx;

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (linkdata != null)
        Scaffold.of(bcontx).showSnackBar(SnackBar(
          duration: Duration(seconds: 5),
          content: Text(linkdata['route'] == 'branch'
              ? 'You have to signUp before creating a new branch'
              : ''),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
    });
    final first = PageViewModel(
      titleWidget: Text(
        "Welcome to PocketShopping",
        style: TextStyle(color: PRIMARYCOLOR),
      ),
      bodyWidget: Text(
        "Pocketshopping is a location based ordering app which can be used to make purchase "
        "accross diffrent merchant such as resturant, malls, stores, Bars etc."
        " Pockectshopping supports home delivery and in-place purchase. what this"
        " means is that with pocketshopping you can buy items from merchant around your"
        " location and have them delivered to you, you can equally use pocketshopping as to place"
        " order in restuanrants,bars etc. use it in place of menu.",
        style: TextStyle(color: PRIMARYCOLOR),
      ),
      image: Center(
        child: Image.asset(
          'assets/images/blogo.png',
          height: MediaQuery.of(context).size.height * 0.4,
        ),
      ),
      decoration: PageDecoration(
        pageColor: Colors.white,
      ),
      footer: Text(
        "Fleepage LLC",
        style: TextStyle(color: Colors.white),
      ),
    );
    final second = PageViewModel(
        titleWidget: Text(
          "Merchant Location",
          style: TextStyle(color: PRIMARYCOLOR),
        ),
        bodyWidget: Text(
          "Get directions to Restuarant, Bars, Malls etc. within "
          "a defined radius. Pocketshopping also delivers realtime update on merchant closer to you",
          style: TextStyle(color: PRIMARYCOLOR),
        ),
        image: Center(
          child: Image.asset(
            'assets/images/locator.gif',
            height: MediaQuery.of(context).size.height * 0.5,
          ),
        ),
        decoration: PageDecoration(
          pageColor: Colors.white,
        ));
    final third = PageViewModel(
        titleWidget: Text(
          "Use As Menu",
          style: TextStyle(color: PRIMARYCOLOR),
        ),
        bodyWidget: Text(
          "You can use pocketshopping as menu in restuarant for placing "
          " order",
          style: TextStyle(color: PRIMARYCOLOR),
        ),
        image: Center(
          child: Image.asset(
            'assets/images/menu.gif',
            height: MediaQuery.of(context).size.height * 0.4,
          ),
        ),
        decoration: PageDecoration(
          pageColor: Colors.white,
        ));
    final fourth = PageViewModel(
        titleWidget: Text(
          "Welcome to PocketShopping",
          style: TextStyle(color: PRIMARYCOLOR),
        ),
        bodyWidget: Text(
          "we promise to give you the best",
          style: TextStyle(color: PRIMARYCOLOR),
        ),
        image: Center(
          child: Image.asset(
            'assets/images/online_store_.png',
            height: MediaQuery.of(context).size.height * 0.4,
          ),
        ),
        decoration: PageDecoration(
          pageColor: Colors.white,
        ));
    List<PageViewModel> pages = [first, second, third, fourth];
    return Scaffold(body: Builder(builder: (context) {
      bcontx = context;
      return IntroductionScreen(
        pages: pages,
        onDone: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SignUpPage()));
        },
        onSkip: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SignUpPage(
                        linkdata: linkdata,
                      )));
        },
        showSkipButton: true,
        next: Icon(
          Icons.navigate_next,
          color: PRIMARYCOLOR,
        ),
        skip: Text(
          "Skip",
          style: TextStyle(color: PRIMARYCOLOR),
        ),
        done: Text(
          "Done",
          style: TextStyle(color: PRIMARYCOLOR, fontWeight: FontWeight.w600),
        ),
      );
    }));
  }
}
