import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pocketshopping/component/dialog.dart';
import 'package:pocketshopping/page/user/merchant.dart';
import 'package:pocketshopping/page/user/singleMerchant.dart';
import 'package:pocketshopping/widget/bSheetMapTemplate.dart';

class SinglePlaceWidget extends StatelessWidget {
  SinglePlaceWidget({this.themeColor, this.mData});

  final Color themeColor;
  final Map mData;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MerchantUI(
                themeColor: themeColor,
              ),
            ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(10.0),
              topLeft: Radius.circular(30.0),
              bottomLeft: Radius.circular(10.0),
              bottomRight: Radius.circular(30.0)),
          border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1.0),
          //color: Colors.white,
          image: DecorationImage(
            image: NetworkImage(mData['cover']),
            fit: BoxFit.cover,
            colorFilter: new ColorFilter.mode(
                Colors.black.withOpacity(0.4), BlendMode.dstATop),
            //colorFilter: Colors.black.withOpacity(0.4),
          ),
        ),
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceAround,

                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Center(
                        child: Text(
                      'Resturant',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                      textAlign: TextAlign.left,
                    )),
                  ),
                  Expanded(
                    child: IconButton(
                      icon: Icon(
                        Icons.place,
                        color: Colors.white,
                        size: 20,
                      ),
                      tooltip: 'View Map and get Direction',
                      onPressed: () {
                        //Navigator.of(context).pushNamed(MerchantMap.tag);
                        showBottomSheet(
                            context: context,
                            builder: (context) {
                              return BottomSheetMapTemplate();
                            });
                      },
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      icon: Icon(
                        Icons.info,
                        size: 20,
                        color: Colors.white,
                      ),
                      tooltip: 'Who we are',
                      onPressed: () {
                        dialog(context, {
                          'title': 'info',
                        }).showInfo();
                      },
                    ),
                  )
                ],
              ),
            ),
            Column(
              children: <Widget>[
                Text(
                  mData['title'],
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                RatingBar(
                  onRatingUpdate: (rate) {},
                  initialRating: 3.5,
                  minRating: 1,
                  maxRating: 5,
                  itemSize: MediaQuery.of(context).size.width * 0.04,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  //itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                ),
                Text(
                  '500m away',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MerchantWidget(
                            //session_: _session,
                            data: mData,
                          ),
                        ));
                  },
                  textColor: Colors.white,
                  child: Text('Check In',
                      style: TextStyle(fontSize: 14, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
