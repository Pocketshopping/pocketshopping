import 'package:flutter/material.dart';

class BottomSheetSearchWidget extends StatelessWidget {
  final Widget child;
  final double height;

  BottomSheetSearchWidget({
    @required this.child,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(5), topRight: Radius.circular(5)),
        child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            height: height,
            width: MediaQuery.of(context).size.width,
            //
            child: Column(
              children: <Widget>[
                Container(
                  color: Colors.white,
                  alignment: Alignment.topRight,
                  height: MediaQuery.of(context).size.width * 0.05,
                  child: FlatButton(
                      onPressed: () => {Navigator.pop(context)},
                      child: Icon(Icons.close)),
                ),
                Expanded(
                    flex: 1,
                    child: CustomScrollView(slivers: <Widget>[
                      SliverList(delegate: SliverChildListDelegate([child]))
                    ])),
              ],
            )));
  }
}
