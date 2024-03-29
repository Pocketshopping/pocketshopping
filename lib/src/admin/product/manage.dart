import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loadmore/loadmore.dart';
import 'package:pocketshopping/src/admin/package_admin.dart' as admin;
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/admin/product/editProduct.dart';
import 'package:pocketshopping/src/admin/product/restocker.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:progress_indicators/progress_indicators.dart';

class ManageProduct extends StatefulWidget {
  final Session user;
  ManageProduct({this.user});
  @override
  _ManageProductState createState() => new _ManageProductState();
}

class _ManageProductState extends State<ManageProduct> {
  int get count => list.length;

  List<admin.Product> list = [];
  bool _finish;
  bool loading;
  bool empty;

  void initState() {
    _finish = true;
    loading =true;
    empty = false;
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
    super.initState();
  }

  void load() {

    if(list.isNotEmpty)
    ProductRepo.fetchAllProduct(widget.user.merchant.mID, list.last).then((value) {
      if(mounted)
        if(value.isNotEmpty)
        setState((){
          loading = false;
          list.addAll(value);
          if(list.length >= 10)
            _finish=false;
          else
            _finish=true;
        });
        else
          setState(() {
            loading = false;
            _finish=true;
          });

    });
    else
      ProductRepo.fetchAllProduct(widget.user.merchant.mID, null).then((value) {
        if(mounted)
          if(value.isNotEmpty)
          setState((){
            loading = false;
            list.addAll(value);
            if(list.length >= 10)
              _finish=false;
            else
              _finish=true;
          });else
            setState(() {
              loading = false;
              _finish=true;
              empty=true;
            });

      });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
              Get.height *
                  0.15),
          child: AppBar(
            title: Text('${widget.user.merchant.bName}',style: TextStyle(color: PRIMARYCOLOR),),
            backgroundColor: Color.fromRGBO(255, 255, 255, 1),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.grey,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            elevation: 0.0,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(
              Get.height *
              0.1),
            child: Container(
              child: TextFormField(
                controller: null,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search ${widget.user.merchant.bName}',
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

            )
          ),
        ),
        body: Column(
          children: [
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
                            onTap: (){
                              if(widget.user.merchant.adminUploaded)
                                Get.to(EditProductForm(session: widget.user,product: list[index],)).then((value) {
                                  _refresh();
                                });
                                else
                              Get.to(ReStock(session: widget.user,product: list[index],)).then((value) {
                                  _refresh();
                              });
                            },
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              backgroundImage: NetworkImage(list[index].pPhoto.isNotEmpty?list[index].pPhoto.first:PRODUCTDEFAULT,
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
                                if(list[index].isManaging)
                                  if(list[index].pStockCount>0 && list[index].pStockCount < 10)
                                    Row(
                                      children: [
                                        Expanded(
                                            child: Text('The ${widget.user.merchant.bCategory} is running out of ${list[index].pName}',style: TextStyle(fontSize: 16,color: Colors.orangeAccent),)
                                        )
                                      ],
                                    )
                                  else if(list[index].pStockCount <= 0)
                                    Row(
                                      children: [
                                        Expanded(
                                            child: Text(' ${list[index].pName} is out of stock',style: TextStyle(fontSize: 16,color: Colors.red),)
                                        ),
                                      ],
                                    )
                              ],
                            ),
                            trailing:  Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if(list[index].isManaging)
                                 if(list[index].pStockCount >= 10)
                                  Text('${list[index].pStockCount}',
                                    style: TextStyle(fontSize: 30,color: Colors.green),)
                                   else if(list[index].pStockCount>0 && list[index].pStockCount < 10)
                                    Text('${list[index].pStockCount}',
                                      style: TextStyle(fontSize: 30,color: Colors.orangeAccent),)
                                  else if(list[index].pStockCount <= 0)
                                    Text('${list[index].pStockCount}',
                                      style: TextStyle(fontSize: 30,color: Colors.red),),
                                if(list[index].isManaging)
                                Text('Qty'),
                              ],
                            )
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
                            return '';
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
                              fontSize: Get.height * 0.06),
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
                    fontSize: Get.height * 0.12,
                    color: PRIMARYCOLOR,
                  ),
                )
            ),
            Expanded(
              flex: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: PRIMARYCOLOR,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15)),
                ),
                padding: EdgeInsets.symmetric(vertical: 10),
                child: FlatButton(
                  onPressed: (){},
                  color: PRIMARYCOLOR,
                  child: Center(
                    child: FlatButton.icon(
                        onPressed: (){
                          Get.to(admin.AddProduct(session: widget.user,)).then((value) {
                            _refresh();
                          });
                        },
                        icon: Icon(Icons.add,color: Colors.white,),
                        label: Text('New Product',style: TextStyle(color: Colors.white),))
                  ),
                ),
              )
            ),
          ],
        )
    );
  }

  Future<bool> _loadMore() async {
    await Future.delayed(Duration(seconds: 0, milliseconds: 2000));
    load();
    return list.length%10 == 0 ?true:false;
  }

  Future<void> _refresh() async {
    setState(() {
      list.clear();
      loading = true;
    });
    load();
  }
}