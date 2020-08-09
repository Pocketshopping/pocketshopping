
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/admin/staff/staffRepo/staffObj.dart';
import 'package:pocketshopping/src/admin/staff/staffRepo/staffRepo.dart';
import 'package:pocketshopping/src/statistic/charts/ItemLineChart.dart';
import 'package:pocketshopping/src/statistic/charts/itemBarChart.dart';
import 'package:pocketshopping/src/statistic/charts/itemPieChart.dart';
import 'package:pocketshopping/src/statistic/repository.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/repository/session.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';

class MerchantStatistic extends StatefulWidget{
  final Session user;
  final String title;
  MerchantStatistic({this.user,this.title});
  @override
  _MerchantStatisticState createState() => new _MerchantStatisticState();
}

class _MerchantStatisticState extends State<MerchantStatistic> {

  List<Staff> staffs;
  Staff selectedStaff;

  @override
  void initState() {
    staffs = [Staff(staffName: 'General',staff: '')];
    selectedStaff = staffs[0];
    //DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
    //print(DateTime(yesterday.year,yesterday.month,yesterday.day,23,59,0));
    //print(DateTime(yesterday.year,yesterday.month,yesterday.day,0,0,0));
    //print(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,23,59,0));
    //print(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,0,0,0));
    //print(DateTime.now().subtract(Duration(days: 29)).toString());
    //print(Utility.rangeOf30Days());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Staff>>(
        future: StaffRepo.fetchAllMyStaffs(widget.user.merchant.mID),
        builder: (context,AsyncSnapshot<List<Staff>> data){
          if(data.hasData){
            staffs.addAll( List.castFrom(data.data));
            return Scaffold(
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
              MediaQuery.of(context).size.height *
                  0.15),
          child: AppBar(
              title: Text(widget.title,style: TextStyle(color: PRIMARYCOLOR),),
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
                      Row(
                        children: [
                          Expanded(
                            flex: 0,
                            child: Padding(
                                padding: EdgeInsets.only(left: 15),
                                child: Text('Sort By:')
                            ),
                          ),
                          Expanded(
                            child: Container(child:
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: DropdownButtonFormField<Staff>(
                                  value: selectedStaff,
                                  items: staffs.toSet().toList()
                                      .map((label) => DropdownMenuItem(
                                    child: Text(
                                      '${label.staffName} Report',
                                      style: TextStyle(
                                          color:
                                          Colors.black54),
                                    ),
                                    value: label,
                                  ))
                                      .toList(),
                                  isExpanded: true,
                                  hint: Text('Sort'),
                                  decoration: InputDecoration(
                                      border: InputBorder.none),
                                  onChanged: (value) {setState(() {
                                    selectedStaff = value;
                                  });

                                  },
                                )
                            )
                            ),
                          )
                        ],
                      ),
                    ],
                  )

              )
          ),
        ),
        body: FutureBuilder<Map<String,dynamic>>(
          future: StatisticRepo.getTodayStat(widget.user.merchant.mID,selectedStaff.staff),
          builder: (context,AsyncSnapshot<Map<String,dynamic>> snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   JumpingDotsProgressIndicator(
              fontSize: MediaQuery.of(context).size.height * 0.12,
            color: PRIMARYCOLOR,
            ),
                  Text('Generating report...please wait')
                ],
              );
            }
            else if(snapshot.hasError){
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('Error generating report.. check your internet connection and try again'),
                )
              );
            }
            else{
              if(snapshot.data != null){
                return ListView(
                  children:[
                    Center(
                      child: Text("Today's Report",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                    ),
                    TodayStat(data: snapshot.data,),
                    Center(
                      child: Text("Yesterday's Report",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                    ),
                    YesterdayStat(mid: widget.user.merchant.mID,sid: selectedStaff.staff,),
                    if(selectedStaff.staffName == 'General')
                    Center(
                      child: Text("30-Days Report",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                    ),
                    if(selectedStaff.staffName == 'General')
                    ThirtyDaysStat(mid: widget.user.merchant.mID,)
                  ]
                );
                /*return GroupedListView<dynamic, String>(
                  groupBy: (element) => element['group'],
                  elements: [
                    {'name': 'Today', 'group': 'A'},
                    {'name': 'Yesterday', 'group': 'B'},
                    {'name': '30', 'group': 'C'},
                  ],
                  order: GroupedListOrder.ASC,
                  useStickyGroupSeparators: true,
                  groupSeparatorBuilder: (String value) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      value == 'A'?'Today':value  == 'B'?'Yesterday':'Last 30 Days',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  itemBuilder: (c, element) {
                    switch(element['name']){
                      case 'Today':
                        return TodayStat(data: snapshot.data,);
                        break;
                      case 'Yesterday':
                        return YesterdayStat(mid: widget.user.merchant.mID,sid: selectedStaff.staff,);
                        break;
                      case '30':
                        return ThirtyDaysStat();
                        break;
                      default:
                        return const SizedBox.shrink();
                        break;
                    }
                  },
                );*/
              }
              else{
                return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('Error generating report.. check your internet connection and try again'),
                    )
                );
              }
            }
          },

        )
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
          );
          }
        }
        );
  }
}

class TodayStat extends StatelessWidget{
  final Map<String,dynamic> data;
  TodayStat({this.data});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded (
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2,vertical: 5),
                    child: SizedBox(
                        height: 100,
                        child: Card(
                          elevation: 2.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${Utility.numberFormatter(data['transactionCount'])}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Color(0xff845bef)),),
                              Text('Transactions',style: TextStyle(color: Color(0xff845bef)),)
                            ],
                          ),
                        )
                    )
                ),
              ),
              Expanded (
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2,vertical: 5),
                    child: SizedBox(
                        height: 100,
                        child: Card(
                          elevation: 2.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('$CURRENCY${Utility.numberFormatter(data['total'])}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Color(0xff0293ee)),),
                              Text('Amount Made',style: TextStyle(color: Color(0xff0293ee)),)
                            ],
                          ),
                        )
                    )
                ),
              ),
              Expanded(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2,vertical: 5),
                    child: SizedBox(
                        height: 100,
                        child: Card(
                          elevation: 2.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              /*Text('0',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                                      Text('hello')*/
                            ],
                          ),
                        )
                    )
                ),
              ),
            ],
          ),
          SizedBox(height: 50,),
          if(data['mostFiveItems'].isNotEmpty)
          SizedBox(
                    height: MediaQuery.of(context).size.height*0.5,
                    width: MediaQuery.of(context).size.width*1,
                    child: ItemPieChart(List.castFrom(data['mostFiveItems']),title: 'Most bought item today')
                    ,),
        ],
      ),
    );
  }
}

class YesterdayStat extends StatelessWidget{
  final String mid;
  final String sid;
  YesterdayStat({this.mid,this.sid});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String,dynamic>>(
      future: StatisticRepo.getYesterdayStat(mid,sid),
      builder: (context,AsyncSnapshot<Map<String,dynamic>> snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              JumpingDotsProgressIndicator(
                fontSize: MediaQuery.of(context).size.height * 0.12,
                color: PRIMARYCOLOR,
              ),
              Text('Generating report...please wait')
            ],
          );
        }
        else if(snapshot.hasError){
          return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                child: Text('Error generating report.. Try again later'),
              )
          );
        }
        else{
          if(snapshot.data != null){
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded (
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2,vertical: 5),
                            child: SizedBox(
                                height: 100,
                                child: Card(
                                  elevation: 2.0,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('${Utility.numberFormatter(snapshot.data['transactionCount'])}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Color(0xff845bef)),),
                                      Text('Transactions',style: TextStyle(color: Color(0xff845bef)),)
                                    ],
                                  ),
                                )
                            )
                        ),
                      ),
                      Expanded (
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2,vertical: 5),
                            child: SizedBox(
                                height: 100,
                                child: Card(
                                  elevation: 2.0,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('$CURRENCY${Utility.numberFormatter(snapshot.data['total'])}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Color(0xff0293ee)),),
                                      Text('Amount Made',style: TextStyle(color: Color(0xff0293ee)),)
                                    ],
                                  ),
                                )
                            )
                        ),
                      ),
                      Expanded(
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2,vertical: 5),
                            child: SizedBox(
                                height: 100,
                                child: Card(
                                  elevation: 2.0,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      /*Text('0',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                                      Text('hello')*/
                                    ],
                                  ),
                                )
                            )
                        ),
                      ),
                    ],
                  ),
                 /* if(snapshot.data['mostFiveItems'].isNotEmpty)
                  SafeArea(
                    child: PercentagePieChart(data: List.castFrom(snapshot.data['mostFiveItems']),when: 'yesterday',)
                  ),*/
                  SizedBox(height: 50,),
                  if(snapshot.data['mostFiveItems'].isNotEmpty)
                  SizedBox(
                    height: MediaQuery.of(context).size.height*0.5,
                    width: MediaQuery.of(context).size.width*1,
                    child: ItemPieChart(List.castFrom(snapshot.data['mostFiveItems']),title: 'Most bought item yesterday')
                    ,),
                ],
              ),
            );
          }
          else{
            return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                  child: Text('Error generating report.. Try again later'),
                )
            );
          }
        }
      },

    );
  }
}

class ThirtyDaysStat extends StatelessWidget{
  final String mid;
  ThirtyDaysStat({this.mid,});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String,dynamic>>(
      future: StatisticRepo.getThirtyDaysStat(mid),
      builder: (context,AsyncSnapshot<Map<String,dynamic>> snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                JumpingDotsProgressIndicator(
                  fontSize: MediaQuery.of(context).size.height * 0.12,
                  color: PRIMARYCOLOR,
                ),
                Text('Generating report...please wait')
              ],
            )
          );
        }
        else if(snapshot.hasError){
          return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                child: Text('Error generating report.. Try again later'),
              )
          );
        }
        else{
          if(snapshot.data != null){
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded (
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2,vertical: 5),
                            child: SizedBox(
                                height: 100,
                                child: Card(
                                  elevation: 2.0,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('${Utility.numberFormatter(snapshot.data['transactionCount'])}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Color(0xff845bef)),),
                                      Text('Transactions',style: TextStyle(color: Color(0xff845bef)),)
                                    ],
                                  ),
                                )
                            )
                        ),
                      ),
                      Expanded (
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2,vertical: 5),
                            child: SizedBox(
                                height: 100,
                                child: Card(
                                  elevation: 2.0,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                    ],
                                  ),
                                )
                            )
                        ),
                      ),
                      Expanded(
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2,vertical: 5),
                            child: SizedBox(
                                height: 100,
                                child: Card(
                                  elevation: 2.0,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      /*Text('0',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                                      Text('hello')*/
                                    ],
                                  ),
                                )
                            )
                        ),
                      ),
                    ],
                  ),
                  /*SizedBox(height: 10,),
                  if(snapshot.data['mostFiveItems'].isNotEmpty)
                  SafeArea(
                    child: PercentagePieChart(data: List.castFrom(snapshot.data['mostFiveItems']),when: '(30 days)',)
                  ),*/
                  SizedBox(height: 50,),
                  if(snapshot.data['weekDaysCount'].isNotEmpty)
                    SizedBox(
                      height: MediaQuery.of(context).size.height*0.5,
                      width: MediaQuery.of(context).size.width*1,
                      child: ItemBarChart(List.castFrom(snapshot.data['weekDaysCount']),)
                      ,),
                  SizedBox(height: 50,),
                  SizedBox(
                    height: MediaQuery.of(context).size.height*0.5,
                    width: MediaQuery.of(context).size.width*1,
                    child: ItemLineChart(Map.castFrom(snapshot.data['growthChart']))
                    ,),
                  SizedBox(height: 50,),
                  if(snapshot.data['mostFiveItems'].isNotEmpty)
                  SizedBox(
                    height: MediaQuery.of(context).size.height*0.5,
                  width: MediaQuery.of(context).size.width*1,
                  child: ItemPieChart(List.castFrom(snapshot.data['mostFiveItems']),title: 'Most bought item (30 days)',)
                    ,),
                  SizedBox(height: 50,),
                  if((snapshot.data['pairs'] as List<dynamic>).length > 0)
                    Column(
                      children: [

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: Text('Items most oftenly bought together.',style: TextStyle(fontSize: 20),),),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                          child:  Column(
                            children: List<Widget>.generate((snapshot.data['pairs'] as List<dynamic>).length, (index) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.5),width: 1))
                                ),
                                child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: List<Widget>.generate(snapshot.data['pairs'][index]['items'].length, (iter) {
                                          return Expanded(
                                            child: Text('${snapshot.data['pairs'][index]['items'][iter]}'),
                                          );
                                        })
                                    )
                                )
                              );
                            }),
                          ),
                        ),

                      ],
                    )
                ],
              ),
            );
          }
          else{
            return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                  child: Text('Error generating report.. Try again later'),
                )
            );
          }
        }
      },

    );

  }
}

