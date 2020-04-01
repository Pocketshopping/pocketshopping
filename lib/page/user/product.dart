import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:pocketshopping/util/data.dart';
import 'package:pocketshopping/component/dialog.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:pocketshopping/widget/bSheetOrderWidget.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProductWidget extends StatelessWidget {
  ProductWidget(this._seesion,this.defaut);
  final session _seesion;
  final PaletteColor defaut;


  @override
      Widget build(BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1.0),
            border: Border.all(
                color: Colors.grey.withOpacity(0.3), width: 1.0),
            color: Colors.white,
          ),
          child: Column(
            children: <Widget>[

              Expanded(
                  flex: 2,
                  child:
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          image: DecorationImage(
                            image: NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTXNpiQxaHdAgFQ2AgUQiRWphhCFbBBSES6f64WlQwJSVhixIOp'),
                            fit: BoxFit.cover,
                            colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.dstATop),
                            //colorFilter: Colors.black.withOpacity(0.4),

                          ),
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            onPressed: (){},
                            icon: Icon(FontAwesome5.question_circle, color:Colors.white),
                          ),
                        ),
                      ),

              ),

              Expanded(
                flex: 2,
                child: Column(
                  children: <Widget>[
                    Text("Food",style: TextStyle(fontSize:18),),
                    Text('\u20A6 456.09',style: TextStyle(fontSize:16),),
                    RatingBar(
                      onRatingUpdate: (rate){},
                      initialRating: 3.5,
                      minRating: 1,
                      maxRating: 5,
                      itemSize: MediaQuery.of(context).size.width*0.04,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                      itemBuilder: (context, _)=>Icon(Icons.star, color: Colors.amber,),

                    ),
                    Row(

                      children: <Widget>[
                        Expanded(
                          child:
                        FlatButton(

                          onPressed: () {
                            showBottomSheet(
                                context: context,
                                builder: (context) =>
                                    BottomSheetOrderWidget()
                            );

                          },
                          textColor: Colors.white,
                          padding:  EdgeInsets.all(0.0),
                          child: Container(

                            alignment: Alignment(0.0, 0.0),
                            decoration: BoxDecoration(
                              color: defaut.color,
                            ),
                            padding:  EdgeInsets.all(5.0),
                            margin:EdgeInsets.all(5.0),
                            child:  Text(
                                'Order',
                                style:  TextStyle(fontSize: 20)
                            ),
                          ),
                        )
                        ),
                        Expanded(
                          child:
                        FlatButton(

                          onPressed: () {
                            showBottomSheet(
                                context: context,
                                builder: (context) =>
                                    BottomSheetOrderWidget()
                            );

                          },
                          textColor: Colors.white,
                          padding:  EdgeInsets.all(0.0),
                          child: Container(
                            padding:  EdgeInsets.all(5.0),
                            margin:EdgeInsets.all(5.0),
                            child:Icon(Icons.shopping_cart, color: defaut.color,),
                          ),
                        ),
                        ),
                      ],
                    )
                  ],
                ),
              )


            ],
          ),

        );
      }
}