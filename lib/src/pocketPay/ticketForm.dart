import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/pocketPay/repository/ticketRepo.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';


class TicketFormWidget extends StatelessWidget {
  final Session user;
  TicketFormWidget({this.user});

  final _formKey = GlobalKey<FormState>();
  List<String> categories=['Select','General','Pocket','Logistic','Account'];
  final category = ValueNotifier<String>('Select');
  final message = ValueNotifier<String>('');
  final loading = ValueNotifier<bool>(false);
  final complain = TextEditingController();




  @override
  Widget build(BuildContext context) {
    return Scaffold(

        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        appBar: AppBar(
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
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text('New Support Ticket',style: TextStyle(color: PRIMARYCOLOR),),
          automaticallyImplyLeading: false,
        ),
        body: ListView(
          children: [
          psCard(
          color: PRIMARYCOLOR,
          title: 'Support Ticket',
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              //offset: Offset(1.0, 0), //(x,y)
              blurRadius: 6.0,
            ),
          ],
          child: Form(
            key: _formKey,
            child: Column(
              children: [
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
                        Get.width * 0.02),
                    child: Text('Fill the form below to submit a complain, once submitted your complaint will be logged and our customer care will work to resolve the issue.')
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
                        Get.width * 0.02),
                    child: ValueListenableBuilder(
                      valueListenable: category,
                      builder: (_,String categoria,__){
                        return DropdownButtonFormField<String>(
                          value: categoria,
                          items: categories
                              .map((label) => DropdownMenuItem(
                            child: Text(
                              '$label Category',
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
                          onChanged: (value) {
                            category.value = value;
                          },
                          validator: (value) {
                            if (value == 'Select') {
                              return 'Select a valid category';
                            }
                            return null;
                          },

                        );
                      },
                    )
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
                      Get.width * 0.02),
                  child: TextFormField(
                    controller: complain,
                    decoration: InputDecoration(
                        hintText: 'Complain',
                        border: InputBorder.none),
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    maxLength: 120,
                    maxLengthEnforced: true,
                    maxLines: 3,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Complain can not be epty';
                      }
                      return null;
                    },
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: message,
                  builder: (_,String mssg,__){
                    return Container(
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
                          Get.width * 0.02),
                      child: Text(mssg,style: TextStyle(color: Colors.orangeAccent,fontWeight: FontWeight.bold),),
                    );
                  },
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
                    color: PRIMARYCOLOR
                  ),
                  padding: EdgeInsets.all(
                      Get.width * 0.02),
                  child: ValueListenableBuilder(
                    valueListenable: loading,
                    builder: (_,bool load,__){
                      return FlatButton(
                        onPressed: ()async{
                          if(!load){
                            if(_formKey.currentState.validate()){
                              loading.value = true;
                              bool result = await TicketRepo.saveTicket(customerID: user.user.walletId,category: category.value,complain: complain.text);
                              loading.value = false;
                              if(result){
                                Get.back();
                                Utility.bottomProgressSuccess(title: 'Ticket',body: 'Your complaint has been logged our agent will reach out to you soon. Thank you',duration: 5);
                              }
                              else{
                                Utility.bottomProgressFailure(title: 'Ticket',body: 'Error logging complain. Check connection and try again.',duration: 5);
                              }
                            }
                          }
                          else{}
                        },
                        color: PRIMARYCOLOR,
                        child: Center(
                          child: load?
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                              :Text('Send',style: TextStyle(color: Colors.white),),
                        ),
                      );
                    },
                  )
                ),


              ],
            ),
          ),

          ),


          ],
        )
    );
  }

}

