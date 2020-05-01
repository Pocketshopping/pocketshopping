import 'package:badges/badges.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:transparent_image/transparent_image.dart';

class MerchantUI extends StatefulWidget{
  final Merchant merchant;
  MerchantUI({this.merchant});
  @override
  State<StatefulWidget> createState() => _MerchantUIState();
}

class _MerchantUIState extends State<MerchantUI>{

  final TextEditingController _filter = new TextEditingController();
  String _searchText;
  Icon _searchIcon;
  Widget _appBarTitle;
  ViewModel vmodel;
  String barcode;
  int _value;
  List<dynamic> category;
  String selectedCategory;
  bool searchMode;
  int track;
  int OrderCount;

  @override
  void initState() {


    _appBarTitle = new Text(widget.merchant.bName,style: TextStyle(color: PRIMARYCOLOR), );
    _searchIcon = new Icon(Icons.search,color: PRIMARYCOLOR,);
    searchMode=false;
    _searchText = "";
    barcode = "";
    _value=0;
    track=0;
    OrderCount=1;
    widget.merchant;
    CloudFunctions.instance.getHttpsCallable(
      functionName: "FetchMerchantsProductCategory",
    ).call({'mID':widget.merchant.mID}).then((value) =>
        setState((){
          category = value.data;
          if(category.isNotEmpty)
          selectedCategory=category[0];
        })

    );
    super.initState();
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      Navigator.pop(context);
      setState(() => vmodel.handleQRcodeSearch(search: barcode));
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException{
      setState(() => this.barcode = 'you cancelled the QRcode search');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  void _searchPressed() {
    _filter.clear();
    setState(() {

      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon =  Icon(Icons.close,color: PRIMARYCOLOR,);
        this._appBarTitle =  TextFormField(
          controller: _filter,
          decoration:  InputDecoration(
              prefixIcon:  Icon(Icons.search),
              hintText: 'Search ${widget.merchant.bName}',
              filled: true,
              fillColor: Colors.grey.withOpacity(0.2),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),


          ),
          autofocus: true,
          enableSuggestions: true,
          textInputAction: TextInputAction.done,
          onChanged: (value){
            if(value.isNotEmpty){
              vmodel.handleSearch(search: _filter.text);
              _searchText=value;
              setState(() { });
            }
          },
        );

        searchMode=true;
      } else {
        this._searchIcon =  Icon(Icons.search,color: PRIMARYCOLOR,);
        this._appBarTitle =  Text(widget.merchant.bName,style: TextStyle(color: PRIMARYCOLOR),);
        searchMode=false;
        vmodel.handleChangeCategory(category: selectedCategory);
      }
    });
  }

  _SeacrhUsingQRCode(){
    showModalBottomSheet(
      context: context,
      builder: (context) =>
          BottomSheetTemplate(
            height: MediaQuery.of(context).size.height*0.6,
            opacity: 0.2,
            child: Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child:

                    Container(

                      child: FlatButton(

                        onPressed: () => {
                          this.scan()
                        },

                        padding: EdgeInsets.all(10.0),
                        child: Column( // Replace with a Row for horizontal icon + text
                          children: <Widget>[
                            Center(child:Text("Search Using QRcode/Barcode",style: TextStyle(fontSize:14, color: Colors.black54),textAlign: TextAlign.center,)),
                            Container(height: 10,),
                            FittedBox(fit:BoxFit.contain,child:Icon(Icons.camera,color: Colors.green, size: MediaQuery.of(context).size.height*0.1,)),
                            Center(child:Text("Scan QRCode to search for product",style: TextStyle(color: Colors.black54),textAlign: TextAlign.center,)),
                          ],
                        ),
                      ),
                    ),



                  )
                  ,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(barcode, textAlign: TextAlign.center,),
                  )
                  ,
                ],
              ),
            ),
          ),
      isScrollControlled: true,
    );
  }


  _MerchantUIState() {
    //if(mounted)


  }


@override
  void dispose() {
    _filter.dispose();
    //vmodel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height=MediaQuery.of(context).size.height;

    return category != null ?
    category.isNotEmpty?
    Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.25), // here the desired height
        child: AppBar(
          elevation: 0.0,
          centerTitle: true,
          backgroundColor: Color.fromRGBO(255, 255, 255, 1),
          leading: IconButton(

            icon: Icon(Icons.arrow_back_ios,color:Colors.grey,
            ),
            onPressed: (){
              Navigator.pop(context);
            },
          ) ,
          actions: <Widget>[
            IconButton(
              icon: _searchIcon,
              onPressed: _searchPressed,

            ),
          ],
          bottom: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.15),
          child: Container(
            padding: EdgeInsets.only(left: 10,right: 10),
            //margin: EdgeInsets.only(bottom: 20),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    category != null?Text(!searchMode?"Categories":'Search', style: TextStyle(fontSize: height*0.04,fontWeight: FontWeight.bold),):Container(),
                    Badge(
                        badgeContent: Text('1',style: TextStyle(color:Colors.white),),
                        position: BadgePosition.topRight(top:1, right: 1),
                        child: IconButton(
                          onPressed: (){},
                          color: Colors.grey,
                          icon: Icon(Icons.shopping_basket,size: height*0.05,),
                        )
                    ),

                  ],
                ),
                category != null?
                    searchMode?
                    Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _searchText.isNotEmpty?
                            'Showing result for $_searchText'
                                :
                            'Search for product in ${widget.merchant.bName}'
                            ,),
                        ),
                        SizedBox(height: 10,),
                      ],
                    )
                        :Container(
                  height: height*0.1,
                  child:
                  ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      Wrap(
                        spacing: 2.0,
                        children: List<Widget>.generate(
                          category.length,
                              (int index) {
                            return ChoiceChip(

                              label: Text('${category[index]}',style: TextStyle(color:
                              Colors.grey),),

                              selected: _value == index,
                              backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                              onSelected: (bool selected) {
                                setState(() {
                                  int lastIndex= _value;
                                  _value = selected ? index : null;
                                 if(_value == null){
                                   _value=lastIndex;
                                   selectedCategory = category[_value];
                                 }
                                 else{
                                   selectedCategory = category[_value];
                                 }
                                 // selectedCategory = selected ? category[index] : "";
                                  vmodel.handleChangeCategory(category: selectedCategory);
                                });
                              },

                            );
                          },
                        ).toList(),
                      ),
                    ],
                  ),
                ):Container()

              ],
            )
          )
          ),

          title:_appBarTitle,

          automaticallyImplyLeading: false,
        ),
      ),
      body: ChangeNotifierProvider<ViewModel>(

        create: (context) => ViewModel(
            query: {'typeOf':'PRODUCT',
              'mid':widget.merchant.mID,
              'category':selectedCategory,
            }),
        child: Consumer<ViewModel>(

          builder: (context, model, child) => ListView.builder(
            itemCount: model.items.length,
            itemBuilder: (context, index) => AwareListItem(
              itemCreated: () {
                vmodel=model;
                return SchedulerBinding.instance.addPostFrameCallback(
                        (duration) => model.handleItemCreated(index));

              },
              child: ListItem(
                title: model.items[index],
                template: model.items[0] != SearchEmptyIndicatorTitle?MerchantUIIndicatorTitle:SearchEmptyIndicatorTitle,
                callback: (value){
                  switch(value['callType']){
                    case 'ORDER':
                      orderCallback(value['payload']);
                    break;
                    case 'DETAIL':
                      detailCallback();
                      break;
                    default:
                      detailCallback();
                    break;
                  }

                },
              ),
            ),
          ),
        ),
      ),

    ):
    Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height*0.4,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Colors.transparent],
                  ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                },
                blendMode: BlendMode.dstIn,
                child:FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image:widget.merchant.bPhoto.isNotEmpty?
                  widget.merchant.bPhoto:
                  PocketShoppingDefaultCover,
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: height*0.4,

                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height*0.6,
              child: Column(
                children: <Widget>[
                  Text(widget.merchant.bName??'Merchant',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height*0.06,
                    color: Colors.black54
                  ),),
                  SizedBox(height:20),
                  Text('We are currently setting up our pocketshopping account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height*0.03,
                        color: Colors.black54
                    ),),
                  SizedBox(height:20),
                  Text('Visit Us',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height*0.03,
                        color: Colors.black54
                    ),),
                  SizedBox(height:10),
                  FlatButton(
                    onPressed: (){},
                    child: Icon(Icons.place,
                        size: MediaQuery.of(context).size.height*0.1,
                        color: Colors.black54
                    ),

                  ),
                  SizedBox(height:10),
                  Text('Contact Us',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height*0.02,
                        color: Colors.black54
                    ),),
                  SizedBox(height:5),
                  Text(widget.merchant.bTelephone??'',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height*0.025,
                        color: Colors.black54
                    ),),


                ],
              ),
            )
          ],
        ),
      )
    )
        :Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }


  detailCallback(){
     showModalBottomSheet(
        context: context,
        builder: (context) =>

            BottomSheetTemplate(
              height: MediaQuery.of(context).size.height*0.4,
              child: Container(

                child: Container(),
              ),
            )



    );
  }

  orderCallback(dynamic data){
    showModalBottomSheet(
        context: context,
        builder: (context) =>
            OrderUI(merchant: widget.merchant,payload: data,),
      isScrollControlled: true,




    );
  }
}


class OrderUI extends StatefulWidget{
  final Merchant merchant;
  final dynamic  payload;
  OrderUI({this.merchant,this.payload});
  @override
  State<StatefulWidget> createState() => _OrderUIState();
}

class _OrderUIState extends State<OrderUI>{
  int OrderCount;
  @override
  void initState() {
    OrderCount = 1;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CarouselBottomSheetTemplate(
      height: MediaQuery.of(context).size.height*0.8,
      child: Container(

          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(
                    height:MediaQuery.of(context).size.height*0.4,
                    width: MediaQuery.of(context).size.width,
                    child: Carousel(
                      images:List<NetworkImage>.generate(
                          widget.payload.pPhoto.length,
                              (int index) {
                            return NetworkImage(widget.payload.pPhoto[index]);
                          }
                      ).toList(),
                    )
                ),
                SizedBox(height: 10,),
                Text(widget.payload.pName,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height*0.03
                  ),),
                SizedBox(height: 5,),
                Text('@ \u20A6 ${widget.payload.pPrice.toString()}',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height*0.03
                  ),),
                SizedBox(height: 5,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(

                      child: Center(child: Text('Qty'),),
                    ),
                    Expanded(

                      child:Center(child:
                      Column(
                        children: <Widget>[
                          Container(
                              alignment: Alignment.center,
                              child: Center(
                                  child:GestureDetector(
                                    onTap: (){
                                      OrderCount +=1;
                                      setState(() { });
                                    },
                                    child:  Icon(Icons.arrow_drop_up,
                                      size: MediaQuery.of(context).size.height*0.06,
                                      color: Colors.black54,
                                    ),
                                  )
                              )
                          ),
                          Container(child: Center(child: Text('$OrderCount',
                            style: TextStyle(fontSize:MediaQuery.of(context).size.height*0.03 ),
                          ),),),
                          Container(
                              alignment: Alignment.center,
                              child: Center(
                                  child:GestureDetector(
                                    onTap: (){
                                      if(OrderCount>1)
                                        OrderCount -=1;
                                      setState(() { });
                                    },
                                    child:  Icon(Icons.arrow_drop_down,
                                      size: MediaQuery.of(context).size.height*0.06,
                                      color: Colors.black54,
                                    ),
                                  )
                              )
                          ),


                        ],
                      )
                      ) ,
                    ),
                    Expanded(

                      child: Center(child: Text(widget.payload.pUnit.toString()),),
                    ),
                  ],
                ),
                Container(
                  color: Colors.green,
                  child: FlatButton(

                    child: Text('Order Now (\u20A6 ${widget.payload.pPrice*OrderCount})',
                      style: TextStyle(color: Colors.white),),
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  color: Colors.grey.withOpacity(0.3),
                  child: FlatButton(
                    onPressed: (){Navigator.pop(context);},
                    child: Text('Cancel',
                      style: TextStyle(color: Colors.black54),),
                  ),
                ),
                SizedBox(height: 20,),
              ],
            ),
          )
      ),
    );
  }
}
