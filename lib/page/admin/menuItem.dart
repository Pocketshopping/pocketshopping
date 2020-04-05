import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import 'package:pocketshopping/widget/bSheetTemplate.dart';


class MenuItem extends StatelessWidget{
  MenuItem(this.gHeight,
      this.icon,
      this.title,
  { this.isBadged=false,
    this.border:Colors.black,
    this.badgeType='text',
    this.openCount=0,
    this.content,
    this.isMultiMenu=true,
    this.bsheet

  });

  final Function bsheet;
  final double gHeight;
  final Icon icon;
  final String title;
  final Color border;
  final Widget content;
  final bool isBadged;
  final String badgeType;
  final int openCount;
  final bool isMultiMenu;



  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        //border: Border.all(width:1, color: border),

      ),
      margin: EdgeInsets.all(5),
      //color: Colors.white70,
      height: gHeight,
      child:
      FlatButton(
        onPressed: () => {
              isMultiMenu ? showModalBottomSheet(
                context: context,
                builder: (context) =>

                        BottomSheetTemplate(
                          height: MediaQuery.of(context).size.height*0.4,
                          child: Container(

                            child: content != null ? content : Container(),
                          ),
                        )



              ):
              content != null?
        Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => content),
        ):Container(),
        },
        //color: Colors.black12,
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