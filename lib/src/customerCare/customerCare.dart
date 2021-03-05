
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/customerCare/repository/customerCareObj.dart';
import 'package:pocketshopping/src/customerCare/repository/customerCareRepo.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';


class CustomerCare extends StatelessWidget {
  final Session session;
   CustomerCare({this.session});

  final _searchNotifier = ValueNotifier<String>('');
  final _numbr = TextEditingController();
  final _name= TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
            Get.height *
                0.08),
        child: AppBar(
            title: Text('CustomerCare',style: TextStyle(color: PRIMARYCOLOR),),
            centerTitle: true,
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
        ),
      ),
      body: ValueListenableBuilder(
          valueListenable: _searchNotifier,
          builder: (_,search,__){

            return StreamBuilder<List<CustomerCareLine>>(
                stream: CustomerCareRepo.fetchMyCustomerCareLine(session.merchant.mID),
                builder: (BuildContext context, AsyncSnapshot<List<CustomerCareLine>> snapshot) {
                  if (snapshot.hasError) return Center(child: new Text('Error connecting to the server.'));
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(
                        child: JumpingDotsProgressIndicator(
                          fontSize: Get.height * 0.12,
                          color: PRIMARYCOLOR,
                        ),
                      );
                    default:
                      return snapshot.data.isNotEmpty?Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Expanded(
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.all(10.0),
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: PRIMARYCOLOR,
                                      child: Center(child: Text(snapshot.data[index].name[0].toUpperCase(),style:TextStyle(color:Colors.white)),),
                                    ),
                                    title: Text('${snapshot.data[index].number}'),
                                    subtitle: Text('${snapshot.data[index].name}'),
                                    trailing: IconButton(
                                      onPressed: ()async{
                                        //Get.back();
                                        Utility.bottomProgressLoader();
                                        await CustomerCareRepo.deleteCustomerCare(session.merchant.mID,snapshot.data[index].number);
                                        Get.back();
                                        Utility.bottomProgressSuccess(body: 'Customer Care deleted');
                                      },
                                      icon: Icon(Icons.delete),
                                    ),
                                  );
                                  //return buildUserRow(snapshot.data.docs[index]);
                                },
                                separatorBuilder: (context, index) {
                                  return Divider();
                                },
                              ),
                            ),
                            snapshot.data.length<50?
                            Expanded(
                              flex: 0,
                              child: addButton(snapshot.data),
                            ):const SizedBox.shrink(),
                          ],
                        ),
                      ):Column(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Center(
                                  child:Image.asset('assets/images/empty.gif'),
                                ),
                                Center(
                                  child: Text(
                                    'Empty',
                                    style: TextStyle(
                                        fontSize: Get.height * 0.04),
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
                                          "No Customer care added yet",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          snapshot.data.length<50?
                          Expanded(
                            flex: 0,
                            child: addButton(snapshot.data),
                          ):const SizedBox.shrink(),
                        ],
                      );
                  }
                });

          })

    );
  }

  Widget addButton(List<CustomerCareLine> cc){
    return Container(
      color: PRIMARYCOLOR,
      child: Center(
        child: FlatButton.icon(
          onPressed: (){
            Get.bottomSheet(Container(
                color: Colors.white,
                height: Get.height / 2,
                child: Column(
                  children: [
                    const SizedBox(height: 20,),
                    Column(
                        children: [
                          Center(child: Text("Customer Care Line",style: TextStyle(fontSize: 18),),),
                    Padding(
                    padding: EdgeInsets.symmetric(vertical: 15,horizontal: 20),
                          child:
                          TextFormField(
                            controller: _numbr,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText: 'Mobile Number',
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

                            },
                          ),
                    ),
              Padding(
              padding: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
              child:
                          TextFormField(
                            controller: _name,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText: 'Name',
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

                            },
                          )
              )
                        ],
                      ),
                     Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: FlatButton(
                          onPressed: ()async{
                            if(_numbr.text.isNotEmpty && _name.text.isNotEmpty)
                              {

                                CustomerCareLine temp =CustomerCareLine(name: _name.text,number: _numbr.text);
                                if(!cc.contains(temp)){
                                  Get.back();
                                  Utility.bottomProgressLoader();
                                  cc.add(temp);
                                  await CustomerCareRepo.saveCustomerCare(session.merchant.mID,cc);
                                  Get.back();
                                  Utility.bottomProgressSuccess(body: 'Customer Care added');
                                }
                                else{
                                  Utility.infoDialogMaker('Number already in customer care list',title: '');
                                }

                              }
                            else{
                              Utility.infoDialogMaker('Ensure all fields are filled.',title: '');
                            }
                          },
                          color: PRIMARYCOLOR,
                          child: Text('Add',style: TextStyle(color: Colors.white),),
                        ),
                      )

                  ],
                ),
              ),
            isScrollControlled: true
            );
          },
          icon: Icon(Icons.add,color: Colors.white,),
          label: Text('Add New',style: TextStyle(color: Colors.white),),
        ),
      ),
    );
  }
}

