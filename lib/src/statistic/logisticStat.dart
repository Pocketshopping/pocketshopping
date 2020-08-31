
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/logistic/agent/repository/agentObj.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/statistic/repository.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/repository/session.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:url_launcher/url_launcher.dart';

class LogisticStatistic extends StatefulWidget{
  final Session user;
  final String title;
  LogisticStatistic({this.user,this.title});
  @override
  _LogisticStatisticState createState() => new _LogisticStatisticState();
}

class _LogisticStatisticState extends State<LogisticStatistic> {

  List<Agent> agents;
  Agent selectedAgent;

  @override
  void initState() {
    agents = [Agent(name: 'General',agent: '')];
    selectedAgent = agents[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Agent>>(
        future: LogisticRepo.fetchCompanyAgents(widget.user.merchant.mID),//StaffRepo.fetchAllMyStaffs(widget.user.merchant.mID),
        builder: (context,AsyncSnapshot<List<Agent>> data){
          if(data.hasData){
            agents.addAll( List.castFrom(data.data));
            return Scaffold(
                backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(
                      Get.height *
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
                              Get.height *
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
                                        child: DropdownButtonFormField<Agent>(
                                          value: selectedAgent,
                                          items: agents.toSet().toList()
                                              .map((label) => DropdownMenuItem(
                                            child: Text(
                                              '${label.name} Report',
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
                                            selectedAgent = value;
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
                  future: StatisticRepo.getTodayLogisticStat(widget.user.merchant.bWallet,selectedAgent.agent),
                  builder: (context,AsyncSnapshot<Map<String,dynamic>> snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          JumpingDotsProgressIndicator(
                            fontSize: Get.height * 0.12,
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
                              YesterdayStat(mid: widget.user.merchant.bWallet,sid: selectedAgent.agent,),
                              if(selectedAgent.name == 'General')
                                Center(
                                  child: Text("30-Days Report",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                                ),
                              if(selectedAgent.name == 'General')
                                ThirtyDaysStat(mid: widget.user.merchant.bWallet,),
                              const SizedBox(height: 20,),
                              Center(
                                child: FlatButton(
                                  onPressed: () => launch("http://pocketshopping.com.ng/"),
                                  child: Text("Visit http://pocketshopping.com.ng/ for comprehensive report.",
                                    style: TextStyle(color: Colors.blue),textAlign: TextAlign.center,),
                                )
                              ),
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
                      fontSize: Get.height * 0.12,
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
                              Text('${Utility.numberFormatter(data['volumeCollected'])}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Color(0xff845bef)),),
                              Text('Deliveries',style: TextStyle(color: Color(0xff845bef)),)
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
                              Text('$CURRENCY${Utility.numberFormatter(data['amountCollected'].round())}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Color(0xff0293ee)),),
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
                              Text('$CURRENCY${Utility.numberFormatter(data['puchasedPocketUnit'].round())}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Color(0xff0293ee)),),
                              Text('Unit Purchased',style: TextStyle(color: Color(0xff0293ee)),)
                            ],
                          ),
                        )
                    )
                ),
              ),
            ],
          ),
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
      future: StatisticRepo.getYesterdayLogisticStat(mid,sid),
      builder: (context,AsyncSnapshot<Map<String,dynamic>> snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              JumpingDotsProgressIndicator(
                fontSize: Get.height * 0.12,
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
                                      Text('${Utility.numberFormatter(snapshot.data['volumeCollected'])}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Color(0xff845bef)),),
                                      Text('Deliveries',style: TextStyle(color: Color(0xff845bef)),)
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
                                      Text('$CURRENCY${Utility.numberFormatter(snapshot.data['amountCollected'].round())}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Color(0xff0293ee)),),
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
                                      Text('$CURRENCY${Utility.numberFormatter(snapshot.data['puchasedPocketUnit'].round())}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Color(0xff0293ee)),),
                                      Text('Unit Purchased',style: TextStyle(color: Color(0xff0293ee)),)
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
      future: StatisticRepo.getThirtyDaysLogisticStat(mid,''),
      builder: (context,AsyncSnapshot<Map<String,dynamic>> snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  JumpingDotsProgressIndicator(
                    fontSize: Get.height * 0.12,
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
                                      Text('${Utility.numberFormatter(snapshot.data['volumeCollected'])}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Color(0xff845bef)),),
                                      Text('Deliveries',style: TextStyle(color: Color(0xff845bef)),)
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
                                      Text('$CURRENCY${Utility.numberFormatter(snapshot.data['amountCollected'].round())}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Color(0xff0293ee)),),
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
                                      Text('$CURRENCY${Utility.numberFormatter(snapshot.data['puchasedPocketUnit'].round())}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Color(0xff0293ee)),),
                                      Text('Unit Purchased',style: TextStyle(color: Color(0xff0293ee)),)
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

