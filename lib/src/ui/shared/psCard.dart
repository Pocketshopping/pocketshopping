import 'package:flutter/material.dart';

class psCard extends StatefulWidget {
  psCard(
      {
        this.child,
        this.color,
        this.title='PocketShopping',
        this.boxShadow,
        this.bg,
  });

  final Color bg;
  final Widget child;
  final Color color;
  final String title;
  final List<BoxShadow> boxShadow;

  @override
  State<StatefulWidget> createState() => _psCardState();
}

class _psCardState extends State<psCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: widget.boxShadow,
      ),
      //width: 300,
      margin: EdgeInsets.all(MediaQuery.of(context).size.width*0.04),

      child:Column(
          children:<Widget>[

            Container(
              decoration: BoxDecoration(
                color: widget.color,

              ),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height*0.05,
              child: FittedBox(
                  fit: BoxFit.contain,
                  child:Text(widget.title,style: TextStyle(fontSize: 18,color: Colors.white),)
              ),

            ),
            Container(

              //padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
              child: widget.child !=null?widget.child:Container(),

            ),

          ]
      ),
    );


  }
}