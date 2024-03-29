import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomSheetTemplate extends StatelessWidget {
  final Widget child;
  final double height;
  final double opacity;
  final Color color;

  BottomSheetTemplate(
      {@required this.child,
      this.height = 100,
      this.opacity = 0.5,
      this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
            height: Get.height,
            width: Get.width,
            color: Colors.transparent,
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                child: Container(
                    decoration: BoxDecoration(
                      color: color,
                    ),
                    height: height,
                    width: Get.width,
                    //
                    child: Column(
                      children: <Widget>[
                        Container(
                          color: color,
                          alignment: Alignment.topRight,
                          height: Get.width * 0.05,
                          child: FlatButton(
                              onPressed: () => {Navigator.pop(context)},
                              child: Icon(Icons.close)),
                        ),
                        Expanded(
                            flex: 1,
                            child: CustomScrollView(
                                physics: NeverScrollableScrollPhysics(),
                                slivers: <Widget>[
                                  SliverList(
                                      delegate:
                                          SliverChildListDelegate([child]))
                                ])),
                      ],
                    )))));
  }
}

class CarouselBottomSheetTemplate extends StatelessWidget {
  final Widget child;
  final double height;
  final double opacity;
  final Color color;
  final bool scrollable;

  CarouselBottomSheetTemplate({
    @required this.child,
    this.height = 100,
    this.opacity = 0.5,
    this.color = Colors.white,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          //Navigator.pop(context);
        },
        child: Container(
            height: Get.height,
            width: Get.width,
            color: Colors.transparent,
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                child: Container(
                    decoration: BoxDecoration(
                      color: color,
                    ),
                    height: height,
                    width: Get.width,
                    //
                    child: child)
            )

        )
    );
  }
}
