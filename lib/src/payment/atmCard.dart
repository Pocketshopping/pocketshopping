import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';

class ATMCard extends StatefulWidget {
  final Function onPressed;

  ATMCard(
      {this.onPressed});

  @override
  State<StatefulWidget> createState() => _ATMCardState();
}

class _ATMCardState extends State<ATMCard> {

  String cardNumber;
  String expiryDate;
  String cardHolderName;
  String cvvCode;
  bool isCvvFocused;
  double formHeight;

  @override
  void initState() {
    formHeight = 0.0;
    cardNumber = '';
    expiryDate = '';
    cardHolderName = '';
    cvvCode = '';
    isCvvFocused = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        height: MediaQuery.of(context).size.height,
        child: Column(children: <Widget>[
          //
          Container(
              height: MediaQuery.of(context).size.height * 0.3,
              child: Column(
                children: <Widget>[
                  //SizedBox(height: MediaQuery.of(context).size.height*0.1,),
                  CreditCardWidget(
                    cardBgColor: PRIMARYCOLOR,
                    cardNumber: cardNumber,
                    expiryDate: expiryDate,
                    cardHolderName: cardHolderName,
                    cvvCode: cvvCode,
                    showBackView: isCvvFocused,
                  )
                ],
              )),
          Container(
            height: MediaQuery.of(context).size.height * 0.7,
            child: ListView(
              children: <Widget>[
                CreditCardForm(
                  themeColor: PRIMARYCOLOR,
                  onCreditCardModelChange: onCreditCardModelChange,
                  formAction: (){
                    widget.onPressed({'card':cardNumber.replaceAll(' ', ""),'expiry':expiryDate,'cvv':cvvCode,'name':cardHolderName});
                  },
                  fieldListner: () {
                    setState(() {
                      formHeight = 0.5;
                    });
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Image.asset('assets/images/paystack.png',
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.height * 0.1),
                SizedBox(
                  height: MediaQuery.of(context).size.height * formHeight,
                ),
              ],
            ),
          ),
        ]));
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

}