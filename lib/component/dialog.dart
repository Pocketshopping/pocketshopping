import 'package:flutter/material.dart';
import 'package:pocketshopping/component/merchantMap.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class dialog {
  dialog(this.context, [this.data]);

  final BuildContext context;
  final Map data;

  showInfo() {
    Alert(
            context: this.context,
            //style: alertStyle,
            type: this.data != null &&
                    this.data.isNotEmpty &&
                    this.data.containsKey("info")
                ? AlertType.info
                : this.data != null &&
                        this.data.isNotEmpty &&
                        this.data.containsKey("error")
                    ? AlertType.error
                    : this.data != null &&
                            this.data.isNotEmpty &&
                            this.data.containsKey("warning")
                        ? AlertType.warning
                        : this.data != null &&
                                this.data.isNotEmpty &&
                                this.data.containsKey("success")
                            ? AlertType.success
                            : AlertType.none,
            title: this.data != null &&
                    this.data.isNotEmpty &&
                    this.data.containsKey("title")
                ? data['title']
                : '',
            desc: this.data != null &&
                    this.data.isNotEmpty &&
                    this.data.containsKey("desc")
                ? data['desc']
                : '',
            buttons: [
              DialogButton(
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onPressed: () => Navigator.pop(this.context),
                color:
                    const Color(0xff33805D), //Color.fromRGBO(91, 55, 185, 1.0),
                radius: BorderRadius.circular(10.0),
              ),
            ],
            closeFunction: () {})
        .show();
  }

  showMerchantMap() {
    Alert(
      context: this.context,
      title: "",
      content: Column(children: [
        Text(
          "Opposite Emadabe Filling Station",
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: MediaQuery.of(context).size.width * 1.0,
          height: MediaQuery.of(context).size.height * 0.5,
          child: MerchantMap(),
        ),
        const SizedBox(height: 10),
        Text(
          "You are Xmeter(s) away from ",
          style: TextStyle(
            fontSize: 14,
          ),
        ),
      ]),
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () => Navigator.pop(this.context),
          color: const Color(0xff33805D), //Color.fromRGBO(91, 55, 185, 1.0),
          radius: BorderRadius.circular(10.0),
        ),
      ],
    ).show();
  }
}
