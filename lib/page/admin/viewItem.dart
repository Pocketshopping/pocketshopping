import 'package:flutter/material.dart';
import 'package:pocketshopping/widget/bSheetTemplate.dart';

class ViewItem extends StatelessWidget {
  ViewItem(this.gHeight,
      {this.actionText = '',
      this.Header = '',
      this.subHeader = '',
      this.content,
      this.skey,
      this.bgColor = Colors.black54,
      this.isMultiMenu = true});

  final double gHeight;
  final String Header;
  final Widget content;
  final Color bgColor;
  final String subHeader;
  final String actionText;
  final GlobalKey<ScaffoldState> skey;
  final bool isMultiMenu;

  @override
  Widget build(BuildContext context) {
    Color tc = bgColor.computeLuminance() < 0.4 ? Colors.white : Colors.black54;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: bgColor),
        color: bgColor,
      ),
      margin: EdgeInsets.all(5),
      //color: Colors.white70,
      height: gHeight,
      child: FlatButton(
        onPressed: () => {
          isMultiMenu
              ? showBottomSheet(
                  context: context,
                  builder: (context) => BottomSheetTemplate(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: content != null ? content : Container(),
                  ),
                )
              : content != null
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => content),
                    )
                  : Container(),
        },
        padding: EdgeInsets.all(10.0),
        child: Column(
          // Replace with a Row for horizontal icon + text
          children: <Widget>[
            if (Header.isNotEmpty)
              Center(
                  child: Text(
                Header,
                style: TextStyle(color: tc, fontSize: 20),
              )),
            Center(
              child: Text(
                subHeader,
                style: TextStyle(color: tc, fontSize: 12),
              ),
            ),
            Container(height: gHeight * 0.1),
            if (actionText.isNotEmpty && isMultiMenu)
              Center(
                  child: Text(
                actionText,
                style: TextStyle(color: tc, fontSize: 12),
              )),
          ],
        ),
      ),
    );
  }
}
