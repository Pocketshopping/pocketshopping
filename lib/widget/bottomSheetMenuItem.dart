import 'package:flutter/material.dart';
import 'package:badges/badges.dart';



class BsMenuItem extends StatelessWidget{
  BsMenuItem(
      {
        @required this.height,
        @required this.icon,
        @required this.title,
        this.isBadged=false,
        this.border:Colors.black54,
        this.badgeType='text',
        this.openCount=0,
        this.page,
      });

  final Widget page;
  final double height;
  final Icon icon;
  final String title;
  final Color border;
  final bool isBadged;
  final String badgeType;
  final int openCount;




  @override
  Widget build(BuildContext context) {
    return Container(

      margin: EdgeInsets.all(5),
      //color: Colors.white70,
      height: height,
      child:
      FlatButton(
        onPressed: () => {
          page != null?
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          ):Container(),
        },

        padding: EdgeInsets.all(10.0),
        child: Column( // Replace with a Row for horizontal icon + text
          children: <Widget>[
            isBadged && openCount>0?Badge(
                badgeColor: badgeType=="text"?Colors.red:openCount==1?Colors.red:openCount==2?Colors.grey:openCount==3?Colors.green:Colors.black54,
                badgeContent: badgeType == 'text'?Text(openCount.toString(),style: TextStyle(color:Colors.white),):
                FittedBox(fit:BoxFit.contain,child:Icon(openCount==1?Icons.face:Icons.tag_faces,color: Colors.white,)),
                child:FittedBox(fit:BoxFit.contain,child:icon)):FittedBox(fit:BoxFit.contain,child:icon),
        Center(child:Text(title,style: TextStyle(color: Colors.black),textAlign: TextAlign.center,))
          ],
        ),
      ),
    );
  }
}