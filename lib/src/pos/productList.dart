import 'dart:async';
import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton/flutter_skeleton.dart';
import 'package:get/get.dart';
import 'package:loadmore/loadmore.dart';
import 'package:pocketshopping/src/admin/package_admin.dart' as admin;
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/admin/product/editProduct.dart';
import 'package:pocketshopping/src/logistic/agent/newAgent.dart';
import 'package:pocketshopping/src/logistic/agent/repository/agentObj.dart';
import 'package:pocketshopping/src/logistic/agentCompany/agentTracker.dart';
import 'package:pocketshopping/src/logistic/locationUpdate/agentLocUp.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/order/repository/cartObj.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/agent/myAuto.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:http/http.dart' as http;
import 'package:pocketshopping/src/pos/checkOut.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/payment/topup.dart';

class ProductList extends StatefulWidget {
  final Session user;
  final int callBckActionType;
  final String title;
  final int route;
  ProductList({this.user,this.callBckActionType=1,this.title,this.route=0});
  @override
  _ProductListState createState() => new _ProductListState();
}

class _ProductListState extends State<ProductList> {
  int get count => list.length;

  List<Product> list = [];
  bool _finish;
  bool loading;
  bool empty;
  String address ;
  List<String> category;
  String selectedCategory;
  final _count = ValueNotifier<int>(1);
  List<CartItem> _cartItem;
  Stream<Wallet> _walletStream;
  final _walletNotifier = ValueNotifier<Wallet>(null);


  void initState() {
    _finish = true;
    loading =false;
    empty = false;
    _cartItem=[];
    category = ['All'];
    selectedCategory = 'All';
    ProductRepo.fetchAllProduct(widget.user.merchant.mID, null).then((value){
      //print(value);
      if(mounted)
        setState((){
          list=value;
          loading =false;
          if(list.length >= 10)
            _finish=false;
          else
            _finish=true;

          if(list.isEmpty) {
            empty = true;
            _finish=true;
          }
        });
    });
    _walletStream = WalletBloc.instance.walletStream;
    _walletStream.listen((wallet) {
      if (mounted) {
        _walletNotifier.value=null;
        _walletNotifier.value = wallet;

      }
    });
    super.initState();
  }



  void load() {
    if(list.isNotEmpty)
      if(selectedCategory != 'All')
        ProductRepo.fetchCategoryProduct(widget.user.merchant.mID, list.last,selectedCategory).then((value) {
          loading=false;
          if(mounted)
            if(value.isNotEmpty)
              setState((){
                //empty = false;
                list.addAll(value);
                if(list.length >= 10)
                  _finish=false;
                else
                  _finish=true;
              });
            else
              setState(() {
                _finish=true;
                if(list.isEmpty)
                  empty=true;
              });

        });
      else
        ProductRepo.fetchAllProduct(widget.user.merchant.mID, list.last).then((value) {
          loading=false;
          if(mounted)
            if(value.isNotEmpty)
              setState((){
                //empty = false;
                list.addAll(value);
                if(list.length >= 10)
                  _finish=false;
                else
                  _finish=true;
              });
            else
              setState(() {
                _finish=true;
                if(list.isEmpty)
                  empty=true;
              });

        });
    else
    if(selectedCategory != 'All')
      ProductRepo.fetchCategoryProduct(widget.user.merchant.mID, null,selectedCategory).then((value) {
        loading=false;
        if(mounted)
          if(value.isNotEmpty)
            setState((){
              //empty = false;
              list.addAll(value);
              if(list.length >= 10)
                _finish=false;
              else
                _finish=true;
            });
          else
            setState(() {
              _finish=true;
              if(list.isEmpty)
                empty=true;
            });

      });
    else
      ProductRepo.fetchAllProduct(widget.user.merchant.mID, null).then((value) {
        loading=false;
        if(mounted)
          if(value.isNotEmpty)
            setState((){
              //empty = false;
              list.addAll(value);
              if(list.length >= 10)
                _finish=false;
              else
                _finish=true;
            });
          else
            setState(() {
              _finish=true;
              if(list.isEmpty)
                empty=true;
            });

      });
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HttpsCallableResult>(
      future: CloudFunctions.instance.getHttpsCallable(
        functionName: "FetchMerchantsProductCategory",
      ).call({'mID': widget.user.merchant.mID}),
      builder: (context,AsyncSnapshot<HttpsCallableResult> data){
        if(data.hasData){
          category.addAll( List.castFrom(data.data.data));
          //selectedCategory = category[0];
          //list.clear();
          //load();
        return Scaffold(
          backgroundColor: Color.fromRGBO(255, 255, 255, 1),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(
                MediaQuery.of(context).size.height *
                    0.22),
            child: AppBar(
                title: Text(widget.title==null?'${widget.user.merchant.bName} Product(s)':widget.title,style: TextStyle(color: PRIMARYCOLOR),),
                centerTitle: true,
                backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    Get.back();
                  },
                ),
                elevation: 0.0,
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(
                      MediaQuery.of(context).size.height *
                          0.22),
                  child: Column(
                    children: [
                      Container(child:
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: DropdownButtonFormField<String>(
                          value: selectedCategory,
                          items: category.toSet().toList()
                              .map((label) => DropdownMenuItem(
                            child: Text(
                              label,
                              style: TextStyle(
                                  color:
                                  Colors.black54),
                            ),
                            value: label,
                          ))
                              .toList(),
                          isExpanded: true,
                          hint: Text('Category'),
                          decoration: InputDecoration(
                              border: InputBorder.none),
                          onChanged: (value) {setState(() {
                            selectedCategory = value;
                            list.clear();
                            loading=true;
                          });
                          if(value == 'All'){
                            ProductRepo.fetchAllProduct(widget.user.merchant.mID, null).then((value){
                              //print(value);
                              if(mounted)
                                setState((){
                                  list=value;
                                  loading =false;
                                  if(list.length >= 10)
                                    _finish=false;
                                  else
                                    _finish=true;

                                  if(list.isEmpty) {
                                    empty = true;
                                    _finish=true;
                                  }
                                });
                            });
                          }
                          else{
                            load();
                          }

                          },
                        )
                      )
                      ),
                      Container(
                          child: TextFormField(
                            controller: null,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText: 'Search for Product(s)',
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.2),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                              ),
                            ),
                            autofocus: false,
                            enableSuggestions: true,
                            textInputAction: TextInputAction.done,
                            onChanged: (value) {
                              if(value.isEmpty){
                                if(selectedCategory != 'All')
                                ProductRepo.fetchCategoryProduct(widget.user.merchant.mID, null,selectedCategory).then((value) {
                                  if(mounted)
                                    setState((){
                                      empty = false;
                                      list=value;
                                      if(list.length >= 10)
                                        _finish=false;
                                    });

                                });

                                else
                                  ProductRepo.fetchAllProduct(widget.user.merchant.mID, null).then((value) {
                                    if(mounted)
                                      setState((){
                                        empty = false;
                                        list=value;
                                        if(list.length >= 10)
                                          _finish=false;
                                      });

                                  });
                              }
                              else{
                                ProductRepo.searchProduct(widget.user.merchant.mID, null,value.trim()).then((result) {

                                  if(mounted)
                                    setState((){
                                      if(result.isNotEmpty) {
                                        list = result;
                                        if (list.length >= 10)
                                          _finish = false;
                                        empty = false;
                                      }
                                      else {
                                        //list.clear();
                                        empty = true;
                                      }

                                    });


                                });
                              }
                            },
                          )

                      ),
                    ],
                  )

                )
            ),
          ),
          body: Column(
            children: [
              Expanded(flex:0,child: SizedBox(height: 10,)),
              Expanded(
                  flex:3,
                  child: !loading?
                  !empty?
                  Container(
                    child: RefreshIndicator(
                      child: LoadMore(
                        isFinish: _finish,
                        onLoadMore: _loadMore,
                        child: ListView.separated(
                          separatorBuilder: (_,i){return const Divider(thickness: 1,);},
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              onTap: ()async
                            {
                              if(_walletNotifier.value.pocketUnitBalance >= 100){
                              Get.defaultDialog(
                                  title: 'Quantity',
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(flex: 0, child:
                                          Center(
                                            child: GestureDetector(
                                              onTap: () {
                                                if (_count.value > 1)
                                                  _count.value -= 1;
                                              },
                                              child: Container(
                                                margin:
                                                EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 15),
                                                padding:
                                                EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 15),
                                                decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .withOpacity(0.3),
                                                    border: Border.all(
                                                      width: 1,
                                                      color: Colors.grey
                                                          .withOpacity(0.4),
                                                    ),
                                                    borderRadius: BorderRadius
                                                        .all(
                                                        Radius.circular(5))),
                                                child: Text('-'),
                                              ),
                                            ),
                                          ),
                                          ),
                                          Expanded(child: Center(child:

                                          ValueListenableBuilder(
                                            valueListenable: _count,
                                            builder: (_, int count, __) {
                                              return Text('$count',
                                                style: TextStyle(
                                                    fontWeight: FontWeight
                                                        .bold),);
                                            },
                                          )

                                          ),),
                                          Expanded(flex: 0, child:
                                          Center(
                                            child: GestureDetector(
                                              onTap: () {
                                                _count.value += 1;
                                              },
                                              child: Container(
                                                margin:
                                                EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 15),
                                                padding:
                                                EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 15),
                                                decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .withOpacity(0.3),
                                                    border: Border.all(
                                                      width: 1,
                                                      color: Colors.grey
                                                          .withOpacity(0.4),
                                                    ),
                                                    borderRadius: BorderRadius
                                                        .all(
                                                        Radius.circular(5))),
                                                child: Text('+'),
                                              ),
                                            ),
                                          ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  cancel: FlatButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: Text('Cancel', style: TextStyle(
                                        color: Colors.grey[400]),),
                                  ),
                                  confirm: FlatButton.icon(
                                    onPressed: () {
                                      Get.back();
                                      if (list[index].availability == 0) {
                                        Utility.infoDialogMaker(
                                            'Product currently not available.',
                                            title: '');
                                      }
                                      else {
                                        CartItem cartItem = CartItem(
                                            count: _count.value,
                                            item: list[index],
                                            total: (list[index].pPrice *
                                                _count.value)
                                        );
                                        if (_cartItem.contains(cartItem))
                                          Utility.infoDialogMaker(
                                              'Product already in cart.',
                                              title: '');
                                        else
                                          _cartItem.add(cartItem);

                                        setState(() {});
                                      }
                                    },
                                    label: Text('Add'),
                                    icon: Icon(Icons.add),

                                  )
                              );
                            }
                              else{
                                bool result = await Utility.confirmDialogMaker('PocketUnit can not be below expected quota ($CURRENCY 100). Do you want to TopUp');
                              if(result){
                                Get.dialog(TopUp(user: widget.user.user,payType: "TOPUPUNIT",));
                              }

                              }
                              },
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey.withOpacity(0.2),
                                child: Image.network(list[index].pPhoto.isNotEmpty?list[index].pPhoto.first:PRODUCTDEFAULT,
                                ),
                              ),
                              title: Text('${list[index].pName}',style: TextStyle(fontSize: 18),),
                              subtitle: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          list[index].availability == 1?Icon(Icons.check,color: Colors.green,):Icon(Icons.close,color: Colors.red,),
                                          list[index].availability == 1?Text('Available'):Text('Unavailable')
                                        ],
                                      ),
                                      Text('$CURRENCY${list[index].pPrice}'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Stock Count: ${list[index].pStockCount}',style: TextStyle(fontSize: 16),)
                                    ],
                                  )
                                ],
                              ),
                              trailing:  Icon(Icons.shopping_basket),
                            );
                          },
                          itemCount: count,
                        ),
                        whenEmptyLoad: false,
                        delegate: DefaultLoadMoreDelegate(),
                        textBuilder: (l){
                          switch(l){
                            case LoadMoreStatus.nomore:
                              return '';
                              break;
                            case LoadMoreStatus.loading:
                              return 'Loading.. please wait';
                              break;
                            case LoadMoreStatus.fail:
                              return 'Error';
                              break;
                            default:
                              return 'Loading.. please wait';
                              break;
                          }
                        },
                      ),
                      onRefresh: _refresh,
                    ),
                  ):
                  ListTile(
                    title: Image.asset('assets/images/empty.gif'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child: Text(
                            'Empty',
                            style: TextStyle(
                                fontSize: MediaQuery.of(context).size.height * 0.06),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  "No Product added yet",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                      :
                  Center(
                    child: JumpingDotsProgressIndicator(
                      fontSize: MediaQuery.of(context).size.height * 0.12,
                      color: PRIMARYCOLOR,
                    ),
                  )
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: PRIMARYCOLOR,
            child: Badge(
              badgeContent:
              Text(
                '${_cartItem.length}',
                style: TextStyle(
                    color: Colors.white),
              ),

              position:
              BadgePosition.topRight(
                  top: 1, right: 1),
              child: IconButton(
                onPressed: () {
                  if(_cartItem.isNotEmpty)
                  Get.bottomSheet(builder: (context){
                    return Container(
                      color: Colors.white,
                      child: PosCheckOut(payload: _cartItem,cartOps: cartOps,
                        isRestaurant: widget.user.merchant.bCategory == 'Restuarant',
                      session: widget.user,
                      )
                    );
                  },
                    isScrollControlled: true,
                    isDismissible: false,
                    enableDrag: false,
                  ).then((value) {
                    if(value != null){
                      if(value == 'clear'){
                        _cartItem.clear();
                        _refresh();
                      }
                      else{
                        _refresh();
                      }
                    }
                    else{
                      _refresh();
                    }
                  }
                  );
                },
                color: PRIMARYCOLOR,
                icon: Icon(
                  Icons.shopping_basket,
                  color: Colors.white,
                  //size: height * 0.05,
                ),
              ),
              showBadge: _cartItem.length > 0
                  ? true
                  : false,
              animationDuration:
              Duration(seconds: 5),
            ),
          ),
        );
        }
        else if (data.hasError){return Scaffold(
            body: Container(
                color: Colors.white,
                child: Center(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                      child: Text('Error communicating to server. Check your internet connection and try again',textAlign: TextAlign.center,)
                    ),
                  ),
                )
            )
        );}
        else{ return Scaffold(
            body: Container(
                color: Colors.white,
                child: Center(
                  child: JumpingDotsProgressIndicator(
                    fontSize: MediaQuery.of(context).size.height * 0.12,
                    color: PRIMARYCOLOR,
                  ),
                )
            )
        );}



      },
    );
  }

  Future<bool> _loadMore() async {
    load();
    return true;
  }

  Future<void> _refresh() async {
    setState(() {
      list.clear();
    });
    load();
  }




  cartOps() {
    setState(() {});
  }






}
