
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/stockManager/bloc/stockBloc.dart';
import 'package:pocketshopping/src/stockManager/repository/stock.dart';
import 'package:pocketshopping/src/stockManager/repository/stockRepo.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';
import 'package:pocketshopping/src/user/repository/repository.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';

class StockManager extends StatelessWidget{

  final Session user;

  StockManager({this.user});

  final count = TextEditingController();
  final  _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.grey,
          ),
          onPressed: () {
            Get.back(result: 'Refresh');
          },
        ),
        title: const Text(
          'Stock Manager',
          style: TextStyle(color: PRIMARYCOLOR),
        ),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder(
        stream: StockBloc.instance.stockStream,
        builder: (contex,AsyncSnapshot<List<Stock>> snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(
                child: JumpingDotsProgressIndicator(
                  fontSize: Get.height * 0.12,
                  color: PRIMARYCOLOR,
                ));
          }
          else if(snapshot.hasError){
            return Center(
                child: Text('Error communicating with server check internet connection and try again.'));
          }
          else {
            if (snapshot.data.isNotEmpty){
              return ListView.separated(
                separatorBuilder: (_,i){return const Divider(thickness: 1,);},
                itemBuilder: (BuildContext context, int index) {

                  return ListTile(
                    onTap: (){
                      Get.defaultDialog(
                        title: snapshot.data[index].product,
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
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
                                  bool result = await StockRepo.reStock(snapshot.data[index], int.tryParse(count.text)??0, user.user.fname);
                                  Get.back();
                                  if(result){
                                    Get.back();
                                    Utility.bottomProgressSuccess(title: 'Restocking',body: '${snapshot.data[index].product} has been restocked');
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
                        ),
                        cancel: FlatButton(
                          onPressed: (){
                            Get.back();
                          },
                          child: Text('Close'),
                        )
                      );
                    },
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      child: Center(
                        child: Text('${snapshot.data[index].product[0].toUpperCase()}',style: TextStyle(fontSize: 30),),
                      ),
                    ),
                    title: Text('${snapshot.data[index].product}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if(snapshot.data[index].stockCount>0 && snapshot.data[index].stockCount < 10)
                          Row(
                            children: [
                              Expanded(
                                child: Text('The ${user.merchant.bCategory} is running out of ${snapshot.data[index].product}',style: TextStyle(fontSize: 16,color: Colors.orangeAccent),)
                              )
                            ],
                          )
                        else if(snapshot.data[index].stockCount <= 0)
                          Row(
                            children: [
                              Expanded(
                                child: Text('${snapshot.data[index].product} is out of stock',style: TextStyle(fontSize: 16,color: Colors.red),),
                              ),
                            ],
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: Text('Click to take further action'),
                            ),
                          ],
                        )
                      ],
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if(snapshot.data[index].isManaging)
                          if(snapshot.data[index].stockCount > 10)
                            Text('${snapshot.data[index].stockCount}',
                              style: TextStyle(fontSize: 30,color: Colors.green),)
                          else if(snapshot.data[index].stockCount>0 && snapshot.data[index].stockCount < 10)
                            Text('${snapshot.data[index].stockCount}',
                              style: TextStyle(fontSize: 30,color: Colors.orangeAccent),)
                          else if(snapshot.data[index].stockCount <= 0)
                              Text('${snapshot.data[index].stockCount}',
                                style: TextStyle(fontSize: 30,color: Colors.red),),

                          Text('Qty'),
                      ],
                    )
                  );
                },
                itemCount: snapshot.data.length,
              );
            }
            else{
              return Center(
                child: ListTile(
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
                                "No pending stock to manage",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),

              );
            }
          }
        },
      ),
    );


  }
}