import 'package:ant_icons/ant_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/category/repository/merchatCategoryObj.dart';
import 'package:pocketshopping/src/errand/errand.dart';
import 'package:pocketshopping/src/geofence/package_geofence.dart';
import 'package:pocketshopping/src/geofence/reviewPlace.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:progress_indicators/progress_indicators.dart';

class MyRadius extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyRadiusState();
}

class _MyRadiusState extends State<MyRadius> {

  Session currentUser;
  GeoFenceBloc gBloc;
  final showSearch=ValueNotifier<bool>(false);
  final left=ValueNotifier<bool>(false);
  final right=ValueNotifier<bool>(true);
  final search=ValueNotifier<List<MCategory>>([]);
  final scrollController = ScrollController();

  @override
  void initState() {
    currentUser = BlocProvider.of<UserBloc>(context).state.props[0];
    gBloc = GeoFenceBloc();
    WalletRepo.getWallet(currentUser.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
    //Utility.locationAccess();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GeoFenceBloc>(
        create: (context) => gBloc..add(NearByMerchant(category: 'All')),
    child: BlocBuilder<GeoFenceBloc, GeoFenceState>(
    builder: (context, state) {
      search.value = state.categories;
      right.value = state.nearByMerchants.length>2;
      return Scaffold(
          resizeToAvoidBottomPadding : false,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(MediaQuery.of(context).size.height *
                0.08), // here the desired height
            child: AppBar(
              leading: IconButton(
                icon: Icon(
                  Icons.menu,
                  color: PRIMARYCOLOR,
                ),
                onPressed: () {
                  //print("your menu action here");
                  Scaffold.of(context).openDrawer();
                },
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text(
                "Pocketshopping",
                style: TextStyle(color: Colors.black),
              ),
              automaticallyImplyLeading: false,
            ),
          ),
          body: Column(
            children: [


              Expanded(
                flex: 1,
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Column(
                      children: [
                        if(state.isSuccess)
                          if(state.nearByMerchants.isNotEmpty)
                        Expanded(flex: 0,child: Align(alignment: Alignment.centerLeft,child: Padding(padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),child: Text('Places nearest to you.'),),)),
                        if(state.isSuccess)
                        Expanded(
                          child: state.nearByMerchants.isNotEmpty?Stack(
                            children: [
                              NotificationListener(
                                child: ListView.builder(
                                  itemBuilder: (BuildContext context, int index) {
                                    return state.nearByMerchants[index].bCategory != 'Logistic'?Container(
                                        padding: EdgeInsets.symmetric(horizontal: 5),
                                        width: MediaQuery.of(context).size.width*0.5,
                                        child: ReviewPlaceWidget(
                                          merchant: state.nearByMerchants[index],
                                          cPosition: GeoFirePoint(
                                              state.currentPosition.latitude,
                                              state.currentPosition.longitude),
                                          user: currentUser.user,
                                        )
                                    ):const SizedBox.shrink();
                                  },
                                  itemCount: state.nearByMerchants.length,
                                  scrollDirection: Axis.horizontal,
                                  controller: scrollController,
                                ),
                                onNotification: (t) {
                                  if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
                                    left.value =true;
                                    right.value =false;
                                  }
                                  else if (scrollController.position.pixels == scrollController.position.minScrollExtent) {
                                    right.value = true;
                                    left.value=false;
                                  }
                                  else{
                                    right.value = true;
                                    left.value=true;
                                  }

                                  return true;
                                },
                              ),
                              ValueListenableBuilder(
                                valueListenable: left,
                                builder: (i,bool showLeft,ii){
                                  return showLeft?Align(
                                      alignment: Alignment.centerLeft,
                                      child: GestureDetector(
                                        onTap: (){
                                          scrollController..animateTo(
                                              scrollController.position.pixels-100.0,
                                              duration: Duration(milliseconds: 1000),
                                              curve: Curves.ease);
                                        },
                                          child: Card(
                                            child: CircleAvatar(
                                              backgroundColor: Colors.white,
                                              child: Icon(Icons.arrow_back_ios,color: Colors.grey,),
                                            ),
                                            shape: CircleBorder(),
                                            elevation: 18.0,
                                            clipBehavior: Clip.antiAlias,
                                          )
                                      )
                                  ):const SizedBox.shrink();
                                },
                              ),

                              ValueListenableBuilder(
                                valueListenable: right,
                                builder: (_,bool showRight,__){
                                  return showRight?Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: (){
                                          scrollController..animateTo(
                                              scrollController.position.pixels+100.0,
                                              duration: Duration(milliseconds: 1000),
                                              curve: Curves.ease);
                                        },
                                          child: Card(
                                            child: CircleAvatar(
                                              backgroundColor: Colors.white,
                                              child: Icon(Icons.arrow_forward_ios,color: Colors.grey,),
                                            ),
                                            shape: CircleBorder(),
                                            elevation: 18.0,
                                            clipBehavior: Clip.antiAlias,
                                          )
                                      )
                                  ):const SizedBox.shrink();
                                },
                              )
                            ],
                          ):
                              Center(
                                child: Image.asset('assets/images/blogo.png'),
                              )
                        ),
                        if(state.isFailure)
                          Center(
                            child: Image.asset('assets/images/blogo.png'),
                          ),

                        if(state.isLoading)
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: JumpingDotsProgressIndicator(
                                fontSize: MediaQuery.of(context).size.height * 0.12,
                                color: PRIMARYCOLOR,
                              ),
                            ),
                          ),
                      ],
                    )
                )
              ),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    //border: Border(top: BorderSide(width: 0.5, color: Colors.black54)),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ],
                  ),

                  child: ValueListenableBuilder(
                    valueListenable: search,
                    builder: (_,List<MCategory> items,__){
                      return Column(
                        children: [
                          Expanded(
                            flex: 0,
                            child: Center(
                              child: ValueListenableBuilder(
                                valueListenable: showSearch,
                                builder: (_,bool show,__){
                                  return Row(
                                    children: [
                                      if(show)
                                        Expanded(
                                          flex:1,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                                            child: TextFormField(
                                              controller: null,
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(Icons.search),
                                                labelText: 'Search',
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
                                              onChanged: (value) async{
                                               // search.value =value;
                                                if(value.isNotEmpty)
                                                search.value = state.categories.where((element) => element.categoryName.toLowerCase().contains(value.toLowerCase())).toList();
                                                else
                                                  search.value = state.categories;
                                                },
                                            ),
                                          ),
                                        ),
                                      if(!show)
                                        Expanded(
                                          flex:1,
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 10,top: 20),
                                            child: Text('What are you looking for?',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,),),
                                          ),
                                        ),
                                      if(!show)
                                        Expanded(
                                          flex:0,
                                          child: Padding(
                                            //padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                                              padding: EdgeInsets.only(left: 0,top: 20),
                                              child: IconButton(icon: Icon(AntIcons.search_outline,color: PRIMARYCOLOR,),
                                                onPressed: (){showSearch.value=true;},)
                                          ),
                                        ),
                                      if(show)
                                        Expanded(
                                          flex:0,
                                          child: Padding(
                                            //padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                                              padding: EdgeInsets.only(left: 0,top: 20),
                                              child: IconButton(icon: Icon(AntIcons.close,color: PRIMARYCOLOR,),
                                                onPressed: (){showSearch.value=false; search.value = state.categories; },)
                                          ),
                                        )
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: items.isNotEmpty?
                            ListView.separated(
                              separatorBuilder: (_,i){return const Divider(thickness: 0.5,);},
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  onTap: (){
                                    if(items[index].categoryName == 'Logistic'){
                                      Get.to(
                                          Errand(user: currentUser,position: state.currentPosition,)
                                      );
                                    }
                                    else{
                                      Get.to(
                                          GeoFence(user: currentUser,category: items[index].categoryName,position: state.currentPosition,)
                                      );
                                    }
                                  },
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.white,
                                    child: Image.network(items[index].categoryURI,width: 30,height: 30,),
                                  ),
                                  title: Text('${items[index].categoryName == 'Logistic'?'Riders':items[index].categoryName}',style: TextStyle(fontSize: 18),),
                                  subtitle: Text('${items[index].desc}'),
                                );
                              },
                              itemCount: items.length,
                            )
                                :
                            ListTile(
                              onTap: (){},
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.hourglass_empty,color: Colors.black54,),
                              ),
                              title: Text('Empty',style: TextStyle(fontSize: 18,color: Colors.black54),),
                              subtitle: Text("oops!! sorry we don't have what you are looking for"),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              )
            ],
          )
      );
    }));

  }
}