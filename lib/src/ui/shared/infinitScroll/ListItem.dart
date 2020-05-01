import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:transparent_image/transparent_image.dart';

typedef DynamicValue =  Function(dynamic);


class ListItem extends StatelessWidget {
  final dynamic title;
  final String template;
  final DynamicValue callback;
  final dynamic data;
  const ListItem({
    Key key,
    this.title,
    this.template,
    this.callback,
    this.data
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    void showMore(){
    showModalBottomSheet(
                context: context,
                builder: (context) =>
                BottomSheetTemplate(
                  height: MediaQuery.of(context).size.height*0.6,
                  opacity: 0.2,
                  child: Container(),
                  ),
                  isScrollControlled: true,
                );
    }


    Widget templateChooser(String select){
      Widget temp;

      switch (select){

        case MessageIndicatorTitle:
        temp = ListTile(

          leading: CircleAvatar(
            radius: 25.0,
                backgroundImage:
                    NetworkImage("https://i.imgur.com/BoN9kdC.png"),
                backgroundColor: Colors.transparent,
                     
          ),
          title:Text("Name",style: TextStyle(fontWeight: FontWeight.bold),),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              
              Text("A ListTile is generally what you use to populate a ListView in Flutter. In this post I will cover all of the parameters with visual examples to make it cl".substring(0,100)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Datetime"),
                  Text("2 Message")
                ],
              ),
              Divider(),
            
            ],
          ),
          trailing: Icon(Icons.keyboard_arrow_right),
        );
        break;
        case OpenOrderIndicatorTitle:
        temp = ListTile(
          onTap: (){callback(title);},

          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Colors.green,
            child: Text("120",style: TextStyle(color: Colors.white),),
                
                     
          ),
          title:  Text("ItemName",style: TextStyle(fontWeight: FontWeight.bold),),
          subtitle:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
             
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Customer Name"),
                  Text("Table Number")
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Paid",style: TextStyle(color: Colors.green,
                  fontWeight: FontWeight.bold,)),
                  Text("timer"),
                  
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Datetime"),
                
                ],
              ),
              Divider(),
            
            ],
          ),
          trailing: Icon(Icons.keyboard_arrow_right),
        );
        break;
        case OpenOrderHomeDeliveryIndicatorTitle:
        temp = ListTile(
          onTap: (){callback(title);},

          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Colors.green,
            child: Text("120",style: TextStyle(color: Colors.white),),
                
                     
          ),
          title: Text("ItemName",style: TextStyle(fontWeight: FontWeight.bold),),
          subtitle:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Customer Name"),
                  Text("CellPhone")
                ],
              ),
              Text("Address"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
              
                  Text("timer"),
                  
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Datetime"),
                  Text("Distance"),
                
                ],
              ),
              Divider(),
            
            ],
          ),
          trailing: Icon(Icons.keyboard_arrow_right),
        );
        break;
        case ProductIndicatorTitle:
        temp = ListTile(
          onTap: (){callback(title);},

          leading: CircleAvatar(
            radius: 25.0,
                backgroundImage:
                    NetworkImage("https://i.imgur.com/BoN9kdC.png"),
                backgroundColor: Colors.transparent,
                     
          ),
          title: Text("ProductName",style: TextStyle(fontWeight: FontWeight.bold),),
          subtitle:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Category"),
                  Text("ItemCount"),
                  ],
              ),
            
              Divider(),
            
            ],
          ),
          trailing: Icon(Icons.keyboard_arrow_right),
        );
        break;
        case StaffIndicatorTitle:
        temp = ListTile(
          onTap: (){callback(title);},

          leading: CircleAvatar(
            radius: 25.0,
                backgroundImage:
                    NetworkImage("https://i.imgur.com/BoN9kdC.png"),
                backgroundColor: Colors.transparent,
                     
          ),
          title: Text("StaffName",style: TextStyle(fontWeight: FontWeight.bold),),
          subtitle:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Roles")
                ],
              ),
              Divider(),
            
            ],
          ),
          trailing: Icon(Icons.keyboard_arrow_right),
        );
        break;
        case PocketUnitHistoryIndicatorTitle:
        temp = ListTile(
          onTap: (){callback(title);},
          title:Text("PocketUnit",style: TextStyle(fontWeight: FontWeight.bold),),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Amount"),
                  Text("DateTime")
                ],
              ),
              Divider(),
            
            ],
          ),
          trailing: Icon(Icons.keyboard_arrow_right),
          
        );
        break;
        case PocketUnitUsageIndicatorTitle:
        temp = ListTile(
          onTap: (){callback(title);},
          title:Text("DateTime",style: TextStyle(fontWeight: FontWeight.bold),),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("PocketUnit"),
                  Text("OrderId")
                ],
              ),
              Divider(),
            
            ],
          ),
          trailing: Icon(Icons.keyboard_arrow_right),
          
        );
        break;
         case SettingsIndicatorTitle:
        temp = ListTile(
          onTap: (){showMore();},
          title:Text("Settings",style: TextStyle(fontWeight: FontWeight.bold),),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text("value"),
              Divider(),
            
            ],
          ),
          trailing: Icon(Icons.keyboard_arrow_right),
          
        );
        break;
        case BranchIndicatorTitle:
        temp = ListTile(
          onTap: (){callback(title);},
          title:Text("BranchName",style: TextStyle(fontWeight: FontWeight.bold),),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("City/State"),
                ],
              ),
              Divider(),
            
            ],
          ),
          trailing: Icon(Icons.keyboard_arrow_right),
          
        );
        break;
         case AccountIndicatorTitle:
        temp = ListTile(
          onTap: (){showMore();},
          title:Text("AccountSettings",style: TextStyle(fontWeight: FontWeight.bold),),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Value"),
                ],
              ),
              Divider(),
            
            ],
          ),
          trailing: Icon(Icons.keyboard_arrow_right),
          
        );
        break;
        case SearchEmptyIndicatorTitle:
          temp = ListTile(

            title:Image.asset('assets/images/empty.gif'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Center(child: Text('Empty',
                  style: TextStyle(fontSize: MediaQuery.of(context).size.height*0.06),),),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                   child: Text("we do not have what you are looking for. "
                       "Try again later"),
                    )
                      ],
                ),


              ],
            ),


          );
          break;
        case SourceProductIndicatorTitle:
          temp = ListTile(
            onTap: (){callback(title);},
            leading: CircleAvatar(
              radius: 25.0,
              backgroundImage:
              NetworkImage("https://i.imgur.com/BoN9kdC.png"),
              backgroundColor: Colors.transparent,

            ),
            title:Text("Product Name",style: TextStyle(fontWeight: FontWeight.bold),),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[

                Text("A ListTile is generally what you use to populate a ListView in Flutter. In this post I will cover all of the parameters with visual examples to make it cl".substring(0,100)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[

                    Expanded(
                      child: Text("DatetimeCreate"),
                    ),
                    Expanded(
                      child: Text("Merchant") ,
                    ),

                  ],
                ),
                Divider(),

              ],
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
          );
          break;
        case CompletedOrderIndicatorTitle:
          temp = ListTile(
            onTap: (){callback(title);},

            leading: CircleAvatar(
              radius: 25.0,
              backgroundImage:
              NetworkImage("https://i.imgur.com/BoN9kdC.png"),
              backgroundColor: Colors.transparent,

            ),
            title:  Text("ItemName",style: TextStyle(fontWeight: FontWeight.bold),),
            subtitle:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Customer Name"),
                    Text("DateTime")
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("PaymentType",style: TextStyle(color: Colors.green,
                      fontWeight: FontWeight.bold,)),
                    Text("OrderType"),

                  ],
                ),
                Divider(),

              ],
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
          );
          break;
        case CancelledOrderIndicatorTitle:
          temp = ListTile(
            onTap: (){callback(title);},
            title:  Text("ItemName",style: TextStyle(fontWeight: FontWeight.bold),),
            subtitle:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Staff Name"),
                    Text("DateTime")
                  ],
                ),
                Divider(),

              ],
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
          );
          break;
        case ReviewsIndicatorTitle:
          temp = ListTile(
            onTap: (){callback(title);},
            leading: CircleAvatar(
              radius: 25.0,
              backgroundImage:
              NetworkImage("https://i.imgur.com/BoN9kdC.png"),
              backgroundColor: Colors.transparent,

            ),
            title:  Text("Customer Name",style: TextStyle(fontWeight: FontWeight.bold),),
            subtitle:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text("Reviewskvnvkdjv vkjv xkjcvx "),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Customer Name"),
                    Text("DateTime")
                  ],
                ),
                Divider(),

              ],
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
          );
          break;
        case NewCustomerIndicatorTitle:
          temp = ListTile(
            onTap: (){callback(title);},

            leading: CircleAvatar(
              radius: 25.0,
              backgroundImage:
              NetworkImage("https://i.imgur.com/BoN9kdC.png"),
              backgroundColor: Colors.transparent,

            ),
            title:  Text("Customer Name",style: TextStyle(fontWeight: FontWeight.bold),),
            subtitle:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("AmountSpent"),
                    Text("DateTime")
                  ],
                ),
                Divider(),

              ],
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
          );
          break;
        case OldCustomerIndicatorTitle:
          temp = ListTile(
            onTap: (){callback(title);},

            leading: CircleAvatar(
              radius: 25.0,
              backgroundImage:
              NetworkImage("https://i.imgur.com/BoN9kdC.png"),
              backgroundColor: Colors.transparent,

            ),
            title:  Text("Customer Name",style: TextStyle(fontWeight: FontWeight.bold),),
            subtitle:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("TotalAmountSpent"),
                    Text("LastDateTime")
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("VisitCount"),

                  ],
                ),
                Divider(),

              ],
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
          );
          break;
        case MerchantUIIndicatorTitle:
          temp = Container(
            //height: height*0.22,
            margin: EdgeInsets.only(bottom: height*0.02,left: height*0.02,right: height*0.02),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),

              ),
              border: Border.all(
                  color: Colors.grey.withOpacity(0.4), width: 1.0
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.4),
                  //offset: Offset(1.0, 0), //(x,y)
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  ),
                  child:ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.topRight,
                        colors: [Colors.black, Colors.transparent],
                      ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                    },
                    blendMode: BlendMode.dstIn,
                    child:FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: title.pPhoto.length>0?title.pPhoto[0]:

                      'https://i.pinimg.com/originals/85/8d/b9/858db9330ae2c94a28a6a99fcd07f85c.jpg',
                      fit: BoxFit.cover,
                      height: height*0.2,

                    ),
                  ),
                ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(5),
                          child: Text(title.pName, style: TextStyle(fontWeight: FontWeight.bold),),
                        ),

                        Container(
                          padding: EdgeInsets.all(10),
                          child: Text('\u20A6 ${title.pPrice}',
                            style: TextStyle(fontWeight: FontWeight.bold),),
                        ),

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
                            FlatButton.icon(
                                onPressed: (){callback({'callType':'CART','payload':title});},
                                icon: Icon(Icons.shopping_basket,color: Colors.black54),
                                label: Text('Add',
                                  style:
                                  TextStyle(color: Colors.black54,
                                  fontSize: 12),))),
                            Expanded(
                              child: FlatButton(
                                color: Colors.orangeAccent,
                                onPressed: (){callback({'callType':'ORDER','payload':title});},
                                child: Text("Order",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
          break;
        case PocketUnitHistoryIndicatorTitle:
          temp = ListTile(
            onTap: (){callback(title);},
            title:Text("PocketUnit",style: TextStyle(fontWeight: FontWeight.bold),),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Amount"),
                    Text("DateTime")
                  ],
                ),
                Divider(),

              ],
            ),
            trailing: Icon(Icons.keyboard_arrow_right),

          );
          break;
        default:
          temp = ListTile(

            title:Text("Quote",style: TextStyle(fontWeight: FontWeight.bold),),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Thought create reality"),
                  ],
                ),


              ],
            ),


          );
          break;


        }

        return temp;
    }


    return title == LoadingIndicatorTitle
          ? Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child:CircularProgressIndicator(),
      alignment: Alignment.center,
    ) : templateChooser(template);
  }
        }