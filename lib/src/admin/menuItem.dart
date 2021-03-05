import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/utility/utility.dart';

class MenuItem extends StatelessWidget {

  const MenuItem(this.gHeight, this.icon, this.title,
      {this.isBadged = false,
      this.border: Colors.black,
      this.badgeType = 'text',
      this.openCount = 0,
      this.content,
      this.isMultiMenu = true,
      this.bsheet,
      this.refresh,
      this.isLocked=false,
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
  final Function refresh;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          //border: Border.all(width:1, color: border),

          ),
      margin: EdgeInsets.all(5),
      //color: Colors.white70,
      height: gHeight,
      child: FlatButton(
        onPressed: ()  {
          if(!isLocked){
            isMultiMenu
                ? Get.bottomSheet(
                BottomSheetTemplate(
                  height: Get.height * 0.4,
                  child: Container(
                    child: content != null ? content : Container(),
                  ),
                )
            )
                : content != null ? Get.to(content).then((value) { if(refresh != null)refresh();}) : Container();
          }
          else{
            Utility.infoDialogMaker('Sorry you are not allowed to perform this action. Contact the admin for more information',title: 'Information');
          }
        },
        //color: Colors.black12,
        padding: EdgeInsets.all(10.0),
        child: Column(
          // Replace with a Row for horizontal icon + text
          children: <Widget>[
            Stack(
              children: [
                isBadged && openCount > 0
                    ? Badge(
                    badgeColor: badgeType == "text"
                        ? Colors.red
                        : openCount == 1
                        ? Colors.red
                        : openCount == 2
                        ? Colors.grey
                        : openCount == 3
                        ? Colors.green
                        : Colors.black54,
                    badgeContent: badgeType == 'text'
                        ? Text(
                      openCount.toString(),
                      style: TextStyle(color: Colors.white),
                    )
                        : FittedBox(
                        fit: BoxFit.contain,
                        child: Icon(
                          openCount == 1 ? Icons.face : Icons.tag_faces,
                          color: Colors.white,
                        )),
                    child: FittedBox(fit: BoxFit.contain, child: icon))
                    : FittedBox(fit: BoxFit.contain, child: icon),

                if(isLocked)
                Positioned(
                  top: 0,
                  right: 0,
                  child: FittedBox(fit: BoxFit.contain, child: Icon(Icons.lock,color: Colors.red,)),
                )
              ],
            ),
            Center(
                child:  Text(
              title,
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
            ))
          ],
        ),
      ),
    );
  }
}
