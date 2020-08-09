import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/admin/product/editProduct.dart';
import 'package:pocketshopping/src/stockManager/repository/stock.dart';
import 'package:pocketshopping/src/stockManager/repository/stockRepo.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';

class ReStock extends StatelessWidget {
  ReStock({this.session,this.product});

  final Session session;
  final Product product;
  final count = TextEditingController();
  final  _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
              '${product.pName}',
              style: TextStyle(color: PRIMARYCOLOR),
            )),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.grey,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: ListView(

        children: [
          psHeadlessCard(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  //offset: Offset(1.0, 0), //(x,y)
                  blurRadius: 6.0,
                ),
              ],
              child: FutureBuilder(
                future: StockRepo.getOne(product.pID),
                builder: (context,AsyncSnapshot<Stock>stock){
                  if(stock.connectionState == ConnectionState.waiting){
                    return Center(
                        child: JumpingDotsProgressIndicator(
                          fontSize: MediaQuery.of(context).size.height * 0.12,
                          color: PRIMARYCOLOR,
                        ));
                  }
                  else if(stock.hasError){
                    return Center(
                      child: Text('There seems to be a problem with your internet.'),
                    );
                  }
                  else{
                    return Column(
                      children: [
                        if(stock.data == null)
                          const SizedBox(height: 50,),

                        if(stock.data != null)
                          if(stock.data.isManaging)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  if(stock.data.stockCount == 0)
                                    Center(
                                      child: Text('${product.pName} Is Out of Stock',style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20
                                      ),),
                                    ),
                                  if(stock.data.stockCount > 0 && stock.data.stockCount < 10)
                                    Center(
                                      child: Text('${product.pName} Is Runing Out of Stock',style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20
                                      ),),
                                    ),
                                ],
                              ),
                            ),

                        Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  //                   <--- left side
                                  color: Colors.black12,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.02),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: stock.data != null?stock.data.isManaging? Text('Pocketshopping is currently managing this product'): Text('Allow Pocketshopping to manage this product.'): Text('Allow Pocketshopping to manage this product.'),
                                ),
                                Expanded(
                                  child: FlatButton(
                                    onPressed: ()async{
                                      Utility.bottomProgressLoader(title: 'Stock Manager',body: 'Changing product stock status..please wait');
                                      bool result;
                                      if(stock.data != null){
                                        if(stock.data.isManaging){
                                          result = await StockRepo.changeStatus(product.pID,isManaging: false);
                                        }
                                        else{
                                          result = await StockRepo.changeStatus(product.pID,isManaging: true);
                                        }
                                      }
                                      else{
                                        result = await StockRepo.save(
                                            Stock(
                                                product: product.pName,
                                                productID: product.pID,
                                                restockedAt: Timestamp.now(),
                                                restockedBy: session.user.fname,
                                                stockCount: 1,
                                                isManaging: true,
                                                lastRestockCount: 1,
                                                frequency: 0,
                                                company: session.merchant.mID
                                            )
                                        );
                                      }
                                      Get.back();
                                      if(result){
                                        Get.back();
                                        Utility.bottomProgressSuccess(title: 'Product stock',body: 'Changes has been affected.');

                                      }
                                      else{
                                        Get.back();
                                        Utility.bottomProgressFailure(title: 'Product stock',body: 'Error encountered while Changing product status.');
                                      }
                                    },
                                    color: stock.data != null?stock.data.isManaging?Colors.red:PRIMARYCOLOR:PRIMARYCOLOR,
                                    child: stock.data != null?
                                    stock.data.isManaging?
                                    Text('Disable',style: TextStyle(color: Colors.white)):
                                    Text('Enable',style: TextStyle(color: Colors.white))
                                        : Text('Enable',style: TextStyle(color: Colors.white),

                                    ),
                                  ),
                                )
                              ],
                            )),
                        const SizedBox(height: 20,),
                        if(stock.data != null)
                        Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  //                   <--- left side
                                  color: Colors.black12,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.02),
                            child:Row(
                              children: [
                                Expanded(
                                  child: Text('Current Stock:'),
                                ),
                                Expanded(
                                  child: Text('${stock.data.stockCount}',style: TextStyle(fontWeight: FontWeight.bold),),
                                ),
                              ],
                            )
                        ),
                        if(stock.data != null)
                          Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    //                   <--- left side
                                    color: Colors.black12,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width * 0.02),
                              child:Row(
                                children: [
                                  Expanded(
                                    child: Text('Restocked at'),
                                  ),
                                  Expanded(
                                    child: Text('${Utility.presentDate(stock.data.restockedAt.toDate())}'),
                                  ),
                                ],
                              )
                          ),
                        if(stock.data != null)
                          Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    //                   <--- left side
                                    color: Colors.black12,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width * 0.02),
                              child:Row(
                                children: [
                                  Expanded(
                                    child: Text('last restock count '),
                                  ),
                                  Expanded(
                                    child: Text('${stock.data.lastRestockCount}'),
                                  ),
                                ],
                              )
                          ),
                        if(stock.data != null)
                        Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  //                   <--- left side
                                  color: Colors.black12,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.02),
                            child:Row(
                              children: [
                                Expanded(
                                  child: Text('This product has been bought ${Utility.numberFormatter(stock.data.frequency)} times since pocketshopping started managing it.',textAlign: TextAlign.center,),
                                ),
                              ],
                            )
                        ),
                        if(stock.data != null)
                          if(stock.data.isManaging)
                          Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    //                   <--- left side
                                    color: Colors.black12,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width * 0.02),
                              child:Column(
                                children: [
                                  Form(
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Enter quantity';
                                        }
                                        if(int.tryParse(count.text) == 0){
                                          return 'Enter quantity greater than 0';
                                        }
                                        return null;
                                      },
                                      controller: count,
                                      decoration: InputDecoration(
                                        hintText: 'Restock',
                                        hintStyle: TextStyle(fontSize: 18,letterSpacing: 1),
                                        filled: true,
                                        fillColor: Colors.grey.withOpacity(0.2),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                        ),
                                        errorBorder: InputBorder.none,
                                      ),
                                      autofocus: false,
                                      textInputAction: TextInputAction.done,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                                      onChanged: (value) {},
                                      style: TextStyle(fontSize: 30),

                                    ),
                                    key: _formKey,
                                  ),
                                  FlatButton(
                                    onPressed: ()async{
                                        if(_formKey.currentState.validate()){
                                            Utility.bottomProgressLoader(title: 'Restocking',body: 'please wait');
                                            bool result = await StockRepo.reStock(stock.data, int.tryParse(count.text)??0, session.user.fname);
                                            Get.back();
                                            if(result){
                                              Get.back();
                                              Utility.bottomProgressSuccess(title: 'Restocking',body: '${product.pName} has been restocked');
                                            }
                                            else{
                                              Get.back();
                                              Utility.bottomProgressFailure(title: 'Restocking',body: 'Error encountered while restocking. Check you internet connection');
                                            }
                                        }
                                    },
                                    color:PRIMARYCOLOR,
                                    child: Center(
                                      child: Text('Set',style: TextStyle(color: Colors.white),)
                                    ),
                                  )
                                ],
                              )
                          ),
                      ],
                    );
                  }
                },
              )
          ),
          const SizedBox(height: 30,),
          
          FlatButton(
            onPressed: (){
              Get.to(EditProductForm(session: session,product: product,)).then((value) => Get.back());
            },
            child: Text('Edit ${product.pName}',style: TextStyle(color: Colors.blue),),
          )
        ],
      ),
    );
  }
}
