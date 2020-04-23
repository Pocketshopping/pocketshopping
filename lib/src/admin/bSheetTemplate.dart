import 'package:flutter/material.dart';


class BottomSheetTemplate extends StatelessWidget{
  final Widget child;
  final double height;
  final double opacity;
  BottomSheetTemplate({
    @required this.child,
    this.height=100,
    this.opacity=0.5

  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: (){
          Navigator.pop(context);
        },
        child:Container(
        height: MediaQuery.of(context).size.height,
    width: MediaQuery.of(context).size.width,
    color: Colors.transparent,
    alignment: Alignment.bottomCenter,
    child: ClipRRect(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
        child:
        Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            height:height,
            width: MediaQuery.of(context).size.width,
            //
            child: Column(
              children: <Widget>[

                Container(
                  color: Colors.white,
                  alignment: Alignment.topRight,


                  child: FlatButton(
                      onPressed: () => {Navigator.pop(context)},
                      child: Icon(Icons.close)),

                ),
                Expanded(
                    flex: 1,
                    child:
                    CustomScrollView(

                        slivers: <Widget>[
                          SliverList(
                              delegate: SliverChildListDelegate(
                                  [
                                   child
                                  ]
                              ))])
                ),

              ],
            )
        )
    )
    )
    );

  }
}