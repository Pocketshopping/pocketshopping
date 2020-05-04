import 'package:flutter/material.dart';

class BsViewItem extends StatelessWidget {
  BsViewItem({
    this.height,
    this.actionText = '',
    this.header,
    this.subHeader = '',
    this.themeColor = Colors.black54,
  });

  final double height;
  final Icon header;
  final Color themeColor;
  final String subHeader;
  final String actionText;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      //color: Colors.white70,
      height: height,
      child: FlatButton(
        onPressed: () => {},
        padding: EdgeInsets.all(10.0),
        child: Column(
          // Replace with a Row for horizontal icon + text
          children: <Widget>[
            if (header != null) FittedBox(fit: BoxFit.contain, child: header),
            FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  subHeader,
                  style: TextStyle(color: Colors.black),
                )),
            Container(height: height * 0.2),
            if (actionText.isNotEmpty)
              FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    actionText,
                    style: TextStyle(color: Colors.black),
                  )),
          ],
        ),
      ),
    );
  }
}
