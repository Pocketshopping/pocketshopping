import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:pocketshopping/page/user/merchant.dart';

import 'bSheetMapTemplate.dart';

class FirstMerchant extends StatelessWidget{
  final String image;
  final Color themeColor;
  FirstMerchant({
    this.image,
    this.themeColor,

  });

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color:Colors.white,
          boxShadow: [

            BoxShadow(
              color: Colors.grey,
              //offset: Offset(1.0, 1.0), //(x,y)
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible (

              fit: FlexFit.loose,

              child: Container(
                //height: MediaQuery.of(context).size.height*0.25,
                width: MediaQuery.of(context).size.height*0.3,
                padding: EdgeInsets.all(5),
                child: Column(
                  children: <Widget>[
                    Text("Amala Place",
                      style: TextStyle(fontSize: 16),),
                    Text("why am i seeing this?",style: TextStyle(fontSize: 14),),
                    Container(
                      //margin: EdgeInsets.only(top: MediaQuery.of(context).size.width*0.05),
                      child: Column(
                        children: <Widget>[
                          RatingBar(
                            onRatingUpdate: (rate){},
                            initialRating: 3.5,
                            minRating: 1,
                            maxRating: 5,
                            itemSize: MediaQuery.of(context).size.width*0.06,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                            itemBuilder: (context, _)=>Icon(Icons.star, color: Colors.amber,),

                          ),
                          Text("Restuarant",style: TextStyle(fontSize: 12),),
                          Row(
                            children: <Widget>[
                              IconButton(
                                icon:Icon(Icons.place,
                                  color: themeColor,),
                                tooltip: 'View Map and get Direction',
                                onPressed: () {
                                  //Navigator.of(context).pushNamed(MerchantMap.tag);
                                  showBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return BottomSheetMapTemplate();
                                      }
                                  );
                                },
                              ),
                              IconButton(
                                icon:Icon(Icons.question_answer,
                                  color: themeColor,),
                                tooltip: 'Talk to customer care',
                                onPressed: () {
                                  //Navigator.of(context).pushNamed(MerchantMap.tag);
                                  showBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return BottomSheetMapTemplate();
                                      }
                                  );
                                },
                              ),
                              IconButton(
                                icon:Icon(Icons.info,
                                  color: themeColor,),
                                tooltip: 'Who we are',
                                onPressed: () {

                                },
                              ),

                            ],
                          ),
                          FlatButton(

                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => MerchantWidget(

                                    data: {'title':'Amala Place','cover':image},            ),
                                  ));
                            },
                            textColor: Colors.white,
                            padding: const EdgeInsets.all(0.0),
                            child: Container(
                              margin: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width*0.02,
                                right:MediaQuery.of(context).size.width*0.02, ),
                              alignment: Alignment(0.0, 0.0),
                              decoration:  BoxDecoration(
                                color: Colors.grey,

                              ),
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                  'Check Out What we Offer',
                                  style: TextStyle(color: Colors.black54,
                                      fontSize: 12)

                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible (
              flex: 1,
              fit: FlexFit.loose,
              child: Container(
                height: MediaQuery.of(context).size.height*0.23,
                width: MediaQuery.of(context).size.height*0.25,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(1.0),
                  border: Border.all(
                      color: Colors.grey.withOpacity(0.3), width: 1.0
                  ),
                  image: DecorationImage(
                    image: NetworkImage(image),
                    fit: BoxFit.cover,
                    colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),

                  ),
                ),
                child: Center(
                  child: Text("Amala Place",style: TextStyle(color: Colors.white),),
                ),
              ),
            ),


        Flexible (

          fit: FlexFit.loose,

          child:
          GestureDetector(
              onTap: (){
                /*Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MerchantWidget(
                      session_: _session,
                      data: mData,            ),
                    ));*/
              },
              child:
              Container(
                  height: MediaQuery.of(context).size.height*0.23,
                  width: MediaQuery.of(context).size.height*0.3,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(1.0),
                    border: Border.all(
                        color: Colors.grey.withOpacity(0.3), width: 1.0
                    ),
//color: Colors.white,
                    image: DecorationImage(
                      image: NetworkImage("https://worldlytreat.com/wp-content/uploads/2018/02/IMG_3688.jpg"),
                      fit: BoxFit.cover,
                      colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.dstATop),
//colorFilter: Colors.black.withOpacity(0.4),

                    ),
                  ),
                  child:ListView(
                    children: <Widget>[
                      Center(
                          child: Text("FuFu",style: TextStyle(color: Colors.white),)
                      ),
                      Center(
                          child: Text("N234",style: TextStyle(color: Colors.white),)
                      ),
                      Center(
                          child: Text("Amala Place",style: TextStyle(color: Colors.white),)
                      )
                    ],
                  )
              )
          )

        ),
            Flexible (

                fit: FlexFit.loose,

                child:
                GestureDetector(
                    onTap: (){
                      /*Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MerchantWidget(
                      session_: _session,
                      data: mData,            ),
                    ));*/
                    },
                    child:
                    Container(
                        height: MediaQuery.of(context).size.height*0.23,
                        width: MediaQuery.of(context).size.height*0.3,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(1.0),
                          border: Border.all(
                              color: Colors.grey.withOpacity(0.3), width: 1.0
                          ),
//color: Colors.white,
                          image: DecorationImage(
                            image: NetworkImage("https://worldlytreat.com/wp-content/uploads/2018/02/IMG_3688.jpg"),
                            fit: BoxFit.cover,
                            colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.dstATop),
//colorFilter: Colors.black.withOpacity(0.4),

                          ),
                        ),
                        child:ListView(
                          children: <Widget>[
                            Center(
                                child: Text("FuFu",style: TextStyle(color: Colors.white),)
                            ),
                            Center(
                                child: Text("N234",style: TextStyle(color: Colors.white),)
                            ),
                            Center(
                                child: Text("Amala Place",style: TextStyle(color: Colors.white),)
                            )
                          ],
                        )
                    )
                )

            ),
            Flexible (

                fit: FlexFit.loose,

                child:
                GestureDetector(
                    onTap: (){
                      /*Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MerchantWidget(
                      session_: _session,
                      data: mData,            ),
                    ));*/
                    },
                    child:
                    Container(
                        height: MediaQuery.of(context).size.height*0.23,
                        width: MediaQuery.of(context).size.height*0.3,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(1.0),
                          border: Border.all(
                              color: Colors.grey.withOpacity(0.3), width: 1.0
                          ),
//color: Colors.white,
                          image: DecorationImage(
                            image: NetworkImage("https://worldlytreat.com/wp-content/uploads/2018/02/IMG_3688.jpg"),
                            fit: BoxFit.cover,
                            colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.dstATop),
//colorFilter: Colors.black.withOpacity(0.4),

                          ),
                        ),
                        child:ListView(
                          children: <Widget>[
                            Center(
                                child: Text("FuFu",style: TextStyle(color: Colors.white),)
                            ),
                            Center(
                                child: Text("N234",style: TextStyle(color: Colors.white),)
                            ),
                            Center(
                                child: Text("Amala Place",style: TextStyle(color: Colors.white),)
                            )
                          ],
                        )
                    )
                )

            ),
            Flexible (

                fit: FlexFit.loose,

                child:
                GestureDetector(
                    onTap: (){
                      /*Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MerchantWidget(
                      session_: _session,
                      data: mData,            ),
                    ));*/
                    },
                    child:
                    Container(
                        height: MediaQuery.of(context).size.height*0.23,
                        width: MediaQuery.of(context).size.height*0.3,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(1.0),
                          border: Border.all(
                              color: Colors.grey.withOpacity(0.3), width: 1.0
                          ),
//color: Colors.white,
                          image: DecorationImage(
                            image: NetworkImage("https://worldlytreat.com/wp-content/uploads/2018/02/IMG_3688.jpg"),
                            fit: BoxFit.cover,
                            colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.dstATop),
//colorFilter: Colors.black.withOpacity(0.4),

                          ),
                        ),
                        child:ListView(
                          children: <Widget>[
                            Center(
                                child: Text("FuFu",style: TextStyle(color: Colors.white),)
                            ),
                            Center(
                                child: Text("N234",style: TextStyle(color: Colors.white),)
                            ),
                            Center(
                                child: Text("Amala Place",style: TextStyle(color: Colors.white),)
                            )
                          ],
                        )
                    )
                )

            ),
            Flexible (

                fit: FlexFit.loose,

                child:Container(
                  //width: 20,
                  child: FlatButton(
                    onPressed: (){},
                    child: Text("See More"),
                  ),
                )
            ),
          ],
        )
    );
  }
}

