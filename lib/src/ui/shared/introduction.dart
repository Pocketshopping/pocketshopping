import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:pocketshopping/src/register/register.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';

class Introduction extends StatefulWidget {
  final Uri linkdata;
  final UserRepository _userRepository;

  Introduction(
      {Key key, @required UserRepository userRepository, this.linkdata})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  State<Introduction> createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction> {
  @override
  Widget build(BuildContext context) {
    //SchedulerBinding.instance.addPostFrameCallback((_) {});
    final first = PageViewModel(
      titleWidget: Text(
        "Your shopping companion",
        style: TextStyle(color: PRIMARYCOLOR,fontSize: 20),
      ),
      bodyWidget: Text(
        "Fleepage LLC",
        style: TextStyle(color: PRIMARYCOLOR),
      ),
      image: Center(
        child: Image.asset(
          'assets/images/blogo.png',
          //height: MediaQuery.of(context).size.height * 0.4,
        ),
      ),
      decoration: PageDecoration(
        pageColor: Colors.white,
        bodyFlex: 0
      ),
    );
    final second = PageViewModel(
        titleWidget: Text(
          "Shopping",
          style: TextStyle(color: PRIMARYCOLOR,fontSize: 20),
        ),
        bodyWidget: Text(
          " You can use pocketshopping to order for items and have them delivered to you. "
          " On pocketshopping we have restaurant, stores, pharmacies etc.",
          style: TextStyle(color: PRIMARYCOLOR),
        ),
        image: Center(
          child: Image.asset(
            'assets/images/shopping.png',
            //height: MediaQuery.of(context).size.height * 0.5,
          ),
        ),
        decoration: PageDecoration(
          pageColor: Colors.white,
          bodyFlex: 1,
          imageFlex: 2
        ));
    final third = PageViewModel(
        titleWidget: Text(
          "Errand",
          style: TextStyle(color: PRIMARYCOLOR,fontSize: 20),
        ),
        bodyWidget: Text(
          "You can have riders on pocketshopping excute an errand. This feature is suitable for business owners as well as user who have needs for riders(Motorcycle, car and mini-van)",
          style: TextStyle(color: PRIMARYCOLOR),
        ),
        image: Center(
          child: Image.asset(
            'assets/images/erranIntro.png',
            //height: MediaQuery.of(context).size.height * 0.4,
          ),
        ),
        decoration: PageDecoration(
          pageColor: Colors.white,
            bodyFlex: 1,
            imageFlex: 2
        ));
    final fourth = PageViewModel(
        titleWidget: Text(
          "Business",
          style: TextStyle(color: PRIMARYCOLOR,fontSize: 20),
        ),
        bodyWidget: Text(
          "With our in-built PoS (Point of sale), Stock Manager, Staff Manager, mobile/web reporting tool, logistic Manager etc. "
              "Business has been made easy and fascinating to manage.",
          style: TextStyle(color: PRIMARYCOLOR),
        ),
        image: Center(
          child: Image.asset(
            'assets/images/business.png',
            //height: MediaQuery.of(context).size.height * 0.4,
          ),
        ),
        decoration: PageDecoration(
            pageColor: Colors.white,
            bodyFlex: 1,
            imageFlex: 2
        ));
    final fifth = PageViewModel(
        titleWidget: Text(
          "Pocketpay",
          style: TextStyle(color: PRIMARYCOLOR,fontSize: 20),
        ),
        bodyWidget: Text(
          "With our in-built Scan-to-Pay functionality paying for goods has been made much more simple and rewarding.",
          style: TextStyle(color: PRIMARYCOLOR),
        ),
        image: Center(
          child: Image.asset(
            'assets/images/payment.png',
            //height: MediaQuery.of(context).size.height * 0.4,
          ),
        ),
        decoration: PageDecoration(
            pageColor: Colors.white,
            bodyFlex: 1,
            imageFlex: 2
        ));
    List<PageViewModel> pages = [first, second, third, fourth,fifth];
    return Scaffold(body: Builder(builder: (context) {
      return IntroductionScreen(
        pages: pages,
        onDone: () {
          Get.off(RegisterScreen(
            userRepository: widget._userRepository,
            linkdata: widget.linkdata,
          ));
        },
        onSkip: () {
          Get.off(RegisterScreen(
            userRepository: widget._userRepository,
            linkdata: widget.linkdata,
          ));
          //SignUpPage(linkdata: linkdata,)
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
