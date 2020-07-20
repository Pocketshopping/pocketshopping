import 'package:ant_icons/ant_icons.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:share/share.dart';

class Profile extends StatefulWidget {
  final User user;
  Profile({this.user});
  @override
  _ProfileState createState() => new _ProfileState();
}

class _ProfileState extends State<Profile> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height *
            0.1), // here the desired height
        child: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: PRIMARYCOLOR,
            ),
            onPressed: () {
              //print("your menu action here");
              Get.back();
            },
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            "Profile",
            style: TextStyle(color: Colors.black),
          ),
          automaticallyImplyLeading: false,
        ),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
              child: Text('Hi. ${widget.user.fname}',style: TextStyle(fontSize: 20),),
            )
          ),
          Center(
            child: Stack(
              children: [
                CircularProfileAvatar(
                  widget.user.profile.isNotEmpty?widget.user.profile:PocketShoppingDefaultAvatar,
                  radius:  MediaQuery.of(context).size.height * 0.13,
                  backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
                  borderWidth: 5,  // sets border, default 0.0
                  initialsText: Text(
                    "${widget.user.fname[0].toUpperCase()}",
                    style: TextStyle(fontSize: 40, color: Colors.white),
                  ),
                  borderColor: const Color.fromRGBO(245, 245, 245, 1), // sets border color, default Colors.white
                  elevation: 5.0, // sets elevation (shadow of the profile picture), default value is 0.0
                  foregroundColor: Colors.brown.withOpacity(0.5), //sets foreground colour, it works if showInitialTextAbovePicture = true , default Colors.transparent
                  cacheImage: true,
                  onTap: () {
                    print('adil');
                  }, // sets on tap
                  showInitialTextAbovePicture: false,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    onPressed: (){
                      Get.bottomSheet(builder: (context){
                        return Container(
                          color: Colors.white,
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(AntIcons.camera),
                                title: Text('From Camera'),
                                subtitle: Text('set profile picture by taking a new photo'),
                              ),
                              const Divider(),
                              ListTile(
                                leading: Icon(Icons.photo),
                                title: Text('From Gallery'),
                                subtitle: Text('Select a picture from gallery'),
                              )
                            ],
                          ),
                          height: MediaQuery.of(context).size.height*0.25,
                        );
                      });
                    },
                    color: Colors.black54,
                    icon: Icon(Icons.camera_alt,size: 40,),
                  )
                )
              ],
            )
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text('ID: ${widget.user.walletId}',style: TextStyle(fontSize: 20,),),
                    )
                  ),
                  Expanded(
                    flex: 0,
                    child: Center(
                      child: IconButton(
                        onPressed: (){
                          Share.share('${widget.user.walletId}');
                        },
                        icon: Icon(Icons.share),
                      ),
                    )
                  )
                ],
              )
            )
          ),
          Container(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: FlatButton(
                onPressed: ()async{
                  await UserRepository().changeRole('admin');
                  BlocProvider.of<AuthenticationBloc>(context).add(AppStarted());
                  Get.back();
                },
                color: PRIMARYCOLOR,
                child: Text('Activate Business Accout',style: TextStyle(color: Colors.white),),
              )
            ),
          )
        ],
      ),
    );
  }
}