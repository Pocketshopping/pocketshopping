import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/fav/repository/faqRepo.dart';
import 'package:progress_indicators/progress_indicators.dart';


class FaqWidget extends StatelessWidget {
  final GlobalKey _one = GlobalKey();




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(flex: 0,child: SizedBox(height: 10,),),
          Expanded(
              child: FutureBuilder<List<Map<String,dynamic>>>(
                  future: FaqRepo.faq(),
                  builder: (context,AsyncSnapshot<List<Map<String,dynamic>>>snapshot)
                  {
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return Center(
                        child: JumpingDotsProgressIndicator(
                          fontSize: Get.height * 0.12,
                          color: PRIMARYCOLOR,
                        ),
                      );
                    }
                    else if(snapshot.hasError){
                      return Center(
                        child: Text('Error connecting to pocketshopping server.'),
                      );
                    }
                    else{
                      if(snapshot.data.isNotEmpty){
                        return ListView.separated(
                            itemBuilder: (context,index){
                              return ListTile(
                                onTap: (){

                                },
                                title: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                                  child: Text(
                                      '${snapshot.data[index]['id']}.${snapshot.data[index]['question']}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                                  child: Text(
                                    '${snapshot.data[index]['answer']}'
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return Divider();
                            },
                            itemCount: snapshot.data.length);
                      }
                      else{
                        return ListView(
                          children: [
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
                                            "No Faq.",
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),

                                ],
                              ),
                            )
                          ],
                        );
                      }
                    }
                  }
              ),


          ),
        ],
      ),

    );
  }
}
