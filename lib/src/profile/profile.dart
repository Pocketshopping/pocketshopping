import 'dart:io';

import 'package:ant_icons/ant_icons.dart';
import 'package:camera/camera.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/ui/shared/imageEditor.dart';
import 'package:pocketshopping/src/user/bloc/broadcaster.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:share/share.dart';

class Profile extends StatefulWidget {
  final User user;
  Profile({this.user});
  @override
  _ProfileState createState() => new _ProfileState();
}

class _ProfileState extends State<Profile> {

  final name = TextEditingController();
  final phone = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final nameValidate = ValueNotifier<bool>(false);
  final phoneValidate = ValueNotifier<bool>(false);

  @override
  void initState() {
    name.text = widget.user.fname;
    phone.text = widget.user.telephone;
    super.initState();
  }

  Future<bool> deleteProfilePhoto(String url)async{
    try{
      StorageReference store = await FirebaseStorage.instance.getReferenceFromUrl(url);
      String name = await store.getName();
      if(name != 'avatar.png'){
        await store.delete();
      }
      return true;
    }
    catch(_){return false;}
  }

  Future<bool> updateProfilePhoto({File image,String uid,String url})async{
    try{
      bool deleted = await deleteProfilePhoto(url);
      if(deleted){
        final List<String> images = await Utility.uploadMultipleImages([image],bucket: 'users');
        bool result = await UserRepo().upDate(profile: images.first,uid: uid);
        if(result) return true;
        else return false;
      }
      else
        return false;
    }
    catch(_){return false;}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(Get.height *
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
      body: FutureBuilder(
        future: UserRepo.getOneUsingUID(widget.user.uid),
        builder: (context,AsyncSnapshot<User>user){
          if(user.connectionState == ConnectionState.waiting){
            return Center(
              child: JumpingDotsProgressIndicator(
                fontSize: Get.height * 0.12,
                color: PRIMARYCOLOR,
              ),
            );
          }
          else if(user.hasError){
            return Center(
              child: Text('Error Loading user. Check connction and try again',textAlign: TextAlign.center,),
            );
          }
          else{
            if(user.data != null){
              name.text = user.data.fname;
              phone.text = user.data.telephone;
              UserBroadcaster.instance.newUser(user.data);
              return ListView(
                children: [
                  Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                        child: Text('Hi. ${user.data.fname}',style: TextStyle(fontSize: 20),),
                      )
                  ),
                  Center(
                      child: Stack(
                        children: [
                          CircularProfileAvatar(
                            user.data.profile.isNotEmpty?user.data.profile:PocketShoppingDefaultAvatar,
                            radius:  Get.height * 0.13,
                            backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
                            borderWidth: 5,  // sets border, default 0.0
                            initialsText: Text(
                              "${user.data.fname[0].toUpperCase()}",
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
                                            onTap: (){
                                              _showCamera(user.data.uid,user.data.profile);
                                            },
                                          ),
                                          const Divider(),
                                          ListTile(
                                            leading: Icon(Icons.photo),
                                            title: Text('From Gallery'),
                                            subtitle: Text('Select a picture from gallery'),
                                            onTap: (){
                                              _showGallery(user.data.uid,user.data.profile);
                                            },
                                          )
                                        ],
                                      ),
                                      height: Get.height*0.25,
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
                                    child: Text('ID: ${user.data.walletId}',style: TextStyle(fontSize: 20,),),
                                  )
                              ),
                              Expanded(
                                  flex: 0,
                                  child: Center(
                                    child: IconButton(
                                      onPressed: (){
                                        Share.share('${user.data.walletId}');
                                      },
                                      icon: Icon(Icons.share),
                                    ),
                                  )
                              )
                            ],
                          )
                      )
                  ),
                  psHeadlessCard(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          //offset: Offset(1.0, 0), //(x,y)
                          blurRadius: 2.0,
                        ),
                      ],
                      child: Column(children: [
                        Container(
                            decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    //                   <--- left side
                                    color: Colors.black12,
                                    width: 1.0,
                                  ),
                                ),
                                color: PRIMARYCOLOR),
                            padding: EdgeInsets.all(
                                Get.width * 0.02),
                            child: const Align(
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                'Details',
                                style: const TextStyle(color: Colors.white),
                              ),
                            )),
                        SizedBox(height: 10,),
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
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text('${user.data.email}'),
                                )
                              ],
                            )),
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
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text('${user.data.fname}'),
                                ),
                                Expanded(
                                  flex: 0,
                                  child: IconButton(
                                    onPressed: (){
                                      Get.defaultDialog(
                                          title: 'Edit Name',
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              ValueListenableBuilder(
                                                valueListenable: nameValidate,
                                                builder: (_,bool validate,__){
                                                  return Form(
                                                    child: TextFormField(
                                                      validator: (value) {
                                                        if (value.isEmpty) {
                                                          return 'Name can not be empty';
                                                        } else if (value.trim() == user.data.fname) {
                                                          return 'No changes made';
                                                        }
                                                        return null;
                                                      },
                                                      controller: name,
                                                      decoration: InputDecoration(
                                                        labelText: 'Name',
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
                                                      autovalidate: validate,
                                                      enableSuggestions: true,
                                                      textInputAction: TextInputAction.done,

                                                      onChanged: (value) async{},
                                                    ),
                                                    key: formKey,
                                                  );
                                                },
                                              )
                                            ],
                                          ),
                                          cancel: FlatButton(
                                            onPressed: (){Get.back();},
                                            child: Text('Cancel',style: TextStyle(color: Colors.grey.withOpacity(0.5)),),
                                          ),
                                          confirm: FlatButton(
                                            onPressed: ()async{
                                              if(formKey.currentState.validate()){
                                                nameValidate.value=false;
                                                Get.back();
                                                Utility.bottomProgressLoader(title: 'Name',body: 'Saving changes please wait...');
                                                bool result = await UserRepo().upDate(fname: name.text,uid: user.data.uid);
                                                Get.back();
                                                if(result){
                                                  Utility.bottomProgressSuccess(title: 'Name Updated',body: 'Name has been updated');
                                                }
                                                else{
                                                  Utility.bottomProgressFailure(title: 'Error',body: 'Error encountered while changing name. Try again');
                                                }
                                              }
                                              else{
                                                nameValidate.value=true;
                                              }
                                              setState(() {});
                                            },
                                            child: Text('Save',style: TextStyle(color: PRIMARYCOLOR),),
                                          )
                                      );
                                    },
                                    icon: Icon(Icons.edit),
                                  ),
                                ),
                              ],
                            )),
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
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text('${user.data.telephone}'),
                                ),
                                Expanded(
                                  flex: 0,
                                  child: IconButton(
                                    onPressed: (){
                                      Get.defaultDialog(
                                          title: 'Edit Telephone',
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              ValueListenableBuilder(
                                                valueListenable: phoneValidate,
                                                builder: (_,bool val,__){
                                                  return Form(
                                                    key: formKey2,
                                                    child: TextFormField(
                                                      validator: (value) {
                                                        if (value.isEmpty) {
                                                          return 'Phone can not be empty';
                                                        } else if (value.trim() == user.data.telephone) {
                                                          return 'No changes made';
                                                        }
                                                        return null;
                                                      },
                                                      controller: phone,
                                                      decoration: InputDecoration(
                                                        labelText: 'Phone',
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
                                                      autovalidate: val,
                                                      enableSuggestions: true,
                                                      textInputAction: TextInputAction.done,
                                                      onChanged: (value) async{},
                                                    ),
                                                  );
                                                },
                                              )
                                            ],
                                          ),
                                          cancel: FlatButton(
                                            onPressed: (){Get.back();},
                                            child: Text('Cancel',style: TextStyle(color: Colors.grey.withOpacity(0.5)),),
                                          ),
                                          confirm: FlatButton(
                                            onPressed: ()async{
                                              if(formKey2.currentState.validate()){
                                                phoneValidate.value=false;
                                                Get.back();
                                                Utility.bottomProgressLoader(title: 'Phone number ',body: 'Saving changes please wait...');
                                                bool result = await UserRepo().upDate(telephone: phone.text,uid: user.data.uid);
                                                Get.back();
                                                if(result){
                                                  Utility.bottomProgressSuccess(title: 'Phone number Updated',body: 'Phone number has been updated');
                                                }
                                                else{
                                                  Utility.bottomProgressFailure(title: 'Error',body: 'Error encountered while changing phone number. Try again');
                                                }
                                              }
                                              else{
                                                phoneValidate.value=true;
                                              }
                                              setState(() {});
                                            },
                                            child: Text('Save',style: TextStyle(color: PRIMARYCOLOR),),
                                          )
                                      );
                                    },
                                    icon: Icon(Icons.edit),
                                  ),
                                ),
                              ],
                            )),
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
                                Get.width *
                                    0.02),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child:
                                  Text('${Utility.presentDate(DateTime.parse((user.data.createdat).toDate().toString()))}'),
                                ),
                              ],
                            )),
                        if(user.data.role != 'user')
                          FutureBuilder(
                            future: MerchantRepo.getMerchant(user.data.bid.id),
                            builder: (context,AsyncSnapshot<Merchant> snapshot){
                              if(snapshot.hasData){
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
                                        Get.width *
                                            0.02),
                                    child: Row(
                                      children: <Widget>[
                                        if(user.data.role == 'admin')
                                          Expanded(
                                            child:
                                            Text('You own ${snapshot.data.bName}'),
                                          ),
                                        if(user.data.role == 'staff')
                                          Expanded(
                                            child:
                                            Text('You are a staff of ${snapshot.data.bName}'),
                                          ),
                                        if(user.data.role == 'rider')
                                          Expanded(
                                            child:
                                            Text('You are a rider of ${snapshot.data.bName}'),
                                          ),
                                      ],
                                    ));
                              }
                              else{
                                return const SizedBox.shrink();
                              }
                            },
                          )

                      ])),
                 /* if(false)
                    Container(
                      child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: FlatButton(
                            onPressed: ()async{
                              await UserRepository().changeRole('admin');
                              BlocProvider.of<AuthenticationBloc>(context).add(AppStarted());
                              Get.off(App(userRepository: await SessionBloc.instance.getSession(),));
                            },
                            color: PRIMARYCOLOR,
                            child: Text('Activate Business Accout',style: TextStyle(color: Colors.white),),
                          )
                      ),
                    ),*/

                ],
              );
            }
            else{
              return Center(
                child: Text('Error Loading user. Check connction and try again',textAlign: TextAlign.center,),
              );
            }
          }
        },
      )
    );
  }

  void _showCamera(String uid,String url) async {
    try{
      final cameras = await availableCameras();

      final camera = cameras.first;

      dynamic camresult = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TakePicturePage(
                camera: camera,
                fabColor: PRIMARYCOLOR,
              )));
      File pImage = File(camresult);
      Get.dialog(Editor(imageFile: pImage,callbvck: (File image)async{
        Get.back();
        await Future.delayed(Duration(seconds: 1));
        Utility.bottomProgressLoader(title: 'Uploading',body: 'Uploading image please wait');
        bool result = await updateProfilePhoto(uid: uid,url: url,image: image);
        Get.back();
        if(result){
          //BlocProvider.of<UserBloc>(context).add(LoadUser(user.data.uid));
          Utility.bottomProgressSuccess(title: 'Image Uploaded',body: 'Your profile image have been successfully change.',duration: 5);
        }
        else{
          Utility.bottomProgressFailure(title: 'Error',body: 'Error encountered. Check internet connection and try again');
        }
        setState(() { });
      },));
    }
    catch(_){}
  }

  void _showGallery(String uid,String url)async{
    try{
      var hold = await ImagePicker.pickImage(source: ImageSource.gallery);
      File pImage = File(hold.path);
      Get.dialog(Editor(imageFile: pImage,callbvck: (File image)async{
        Get.back();
        await Future.delayed(Duration(seconds: 1));
        Utility.bottomProgressLoader(title: 'Uploading',body: 'Uploading image please wait');
        bool result = await updateProfilePhoto(uid: uid,url: url,image: image);
        Get.back();
        if(result){
          //BlocProvider.of<UserBloc>(context).add(LoadUser(user.data.uid));
          Utility.bottomProgressSuccess(title: 'Image Uploaded',body: 'Your profile image have been successfully change.',duration: 5);
        }
        else{
          Utility.bottomProgressFailure(title: 'Error',body: 'Error encountered. Check internet connection and try again');
        }
        setState(() { });
      },));
    }
    catch(_){}
  }


}