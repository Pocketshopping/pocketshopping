import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/ui/shared/imageEditor.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:recase/recase.dart';

class ManageBusiness extends StatefulWidget {
  ManageBusiness({this.session});

  final Session session;


  @override
  State<StatefulWidget> createState() => _ManageBusinessState();
}

class _ManageBusinessState extends State<ManageBusiness> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _openController = TextEditingController(text: '1');
  final TextEditingController _closeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _telephone2Controller = TextEditingController();

  FocusNode _nameFocus = FocusNode();
  FocusNode _addressFocus = FocusNode();
  FocusNode _descriptionFocus = FocusNode();
  FocusNode _openFocus = FocusNode();
  FocusNode _closeFocus = FocusNode();
  FocusNode _emailFocus = FocusNode();
  FocusNode _telephone = FocusNode();
  FocusNode _telephone2Focus = FocusNode();


  //final format = DateFormat("HH:mm");
  Session currentUser;
  bool _nameEnabler;
  bool _addressEnabler;
  bool _descriptionEnabler;
  bool _openEnabler;
  bool _closeEnabler;
  bool _emailEnabler;
  bool _telephoneEnabler;
  bool _telephone2Enabler;
  List<bool> isSelected;
  File pImage;
  List<String> images;
  bool working;



  @override
  void initState() {
    working = false;
    images=[widget.session.merchant.bPhoto];
    images.remove(PocketShoppingDefaultCover);
    isSelected = [widget.session.merchant.bStatus==0, widget.session.merchant.bStatus==1];
    _nameEnabler = false;
    _addressEnabler = false;
    _openEnabler = false;
    _descriptionEnabler = false;
    _closeEnabler = false;
    _emailEnabler = false;
    _telephoneEnabler=false;
    _telephone2Enabler=false;
    _nameController.text = widget.session.merchant.bName;
    _addressController.text = widget.session.merchant.bAddress;
    _openController.text = widget.session.merchant.bOpen;
    _closeController.text = widget.session.merchant.bClose;
    _emailController.text = widget.session.merchant.bEmail;
    _descriptionController.text = widget.session.merchant.bDescription;
    _telephoneController.text = widget.session.merchant.bTelephone;
    _telephone2Controller.text = widget.session.merchant.bTelephone2;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double marginLR = Get.width;
    return WillPopScope(
        onWillPop: () async {
          Get.back(result: 'Refresh');
          return true;

        },
        child: Scaffold(
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(
                  Get.height *
                      0.08),
              child: AppBar(
                title: Text('Business Settings',style: TextStyle(color: PRIMARYCOLOR),),
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
                   )
              ),
            backgroundColor: Colors.white,
            body: CustomScrollView(slivers: <Widget>[
              SliverList(
                  delegate: SliverChildListDelegate([
                    Container(
                        padding: EdgeInsets.only(
                            left: marginLR * 0.01, right: marginLR * 0.01),
                        margin: EdgeInsets.only(top: marginLR * 0.01),
                        child: Center(
                          child: psCard(
                            color: PRIMARYCOLOR,
                            title: '${widget.session.merchant.bName}',
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                //offset: Offset(1.0, 0), //(x,y)
                                blurRadius: 6.0,
                              ),
                            ],
                            child: Form(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      !widget.session.merchant.adminUploaded?
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
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller: _nameController,
                                                  decoration: InputDecoration(
                                                      labelText: 'Business Name',
                                                      hintText: 'Business Name',
                                                      border: InputBorder.none),
                                                  keyboardType: TextInputType.text,
                                                  autocorrect: false,
                                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                                  enabled: _nameEnabler,
                                                  autofocus: _nameEnabler,
                                                  focusNode: _nameFocus,
                                                ),
                                              ),
                                              !working?
                                              Expanded(
                                                  flex: 0,
                                                  child: _nameEnabler?FlatButton(
                                                    onPressed: ()async{
                                                      if(_nameController.text.isNotEmpty){
                                                        List<String> temp = Utility.makeIndexList(_nameController.text);
                                                        temp.addAll(Utility.makeIndexList(widget.session.merchant.bCategory));
                                                        if(widget.session.merchant.bDelivery == 'Yes') {temp.addAll(Utility.makeIndexList('Logistic'));}
                                                        await MerchantRepo.update(widget.session.merchant.mID,
                                                            {
                                                              'businessName':_nameController.text.sentenceCase,
                                                              'index': temp,
                                                            });
                                                        setState(() {
                                                          _nameEnabler=false;
                                                        });
                                                      }
                                                    },
                                                    color: PRIMARYCOLOR,
                                                    child: Text('Save',style: TextStyle(color: Colors.white),),
                                                  ):
                                                  FlatButton(
                                                    onPressed: ()async{

                                                      setState(() {
                                                        _nameEnabler=true;
                                                      });
                                                      await Future.delayed(Duration(milliseconds: 500));
                                                      FocusScope.of(context).requestFocus(_nameFocus);
                                                    },
                                                    child: Text('Edit'),
                                                  )
                                              ):Container()
                                              ,
                                            ],
                                          )
                                      ):const SizedBox.shrink(),
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
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller: _addressController,
                                                  decoration: InputDecoration(
                                                      labelText: 'Business Address',
                                                      hintText: 'Business Address',
                                                      border: InputBorder.none),
                                                  keyboardType: TextInputType.text,
                                                  autocorrect: false,
                                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                                  enabled: _addressEnabler,
                                                  focusNode: _addressFocus,
                                                  inputFormatters: <TextInputFormatter>[
                                                    //WhitelistingTextInputFormatter.digitsOnly
                                                  ],
                                                ),
                                              ),
                                              !working?
                                              Expanded(
                                                  flex: 0,
                                                  child: _addressEnabler?FlatButton(
                                                    onPressed: ()async{
                                                      if(_addressController.text.isNotEmpty){
                                                        await MerchantRepo.update(widget.session.merchant.mID,
                                                            {
                                                              'businessAdress':_addressController.text,
                                                            });
                                                        setState(() {
                                                          _addressEnabler=false;
                                                        });
                                                      }
                                                    },
                                                    color: PRIMARYCOLOR,
                                                    child: Text('Save',style: TextStyle(color: Colors.white),),
                                                  ):
                                                  FlatButton(
                                                    onPressed: ()async{
                                                      setState(() {
                                                        _addressEnabler=true;
                                                      });
                                                      await Future.delayed(Duration(milliseconds: 500));
                                                      FocusScope.of(context).requestFocus(_addressFocus);
                                                    },
                                                    child: Text('Edit'),
                                                  )
                                              ):Container(),
                                            ],
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
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller: _descriptionController,
                                                  decoration: InputDecoration(
                                                      labelText: 'Business Description',
                                                      hintText: 'Business Description',
                                                      border: InputBorder.none),
                                                  keyboardType: TextInputType.text,
                                                  autocorrect: false,
                                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                                  maxLines: 3,
                                                  enabled: _descriptionEnabler,
                                                  focusNode: _descriptionFocus,
                                                  inputFormatters: <TextInputFormatter>[
                                                    //WhitelistingTextInputFormatter.digitsOnly
                                                  ],
                                                ),
                                              ),
                                              !working?
                                              Expanded(
                                                  flex: 0,
                                                  child: _descriptionEnabler?FlatButton(
                                                    onPressed: ()async{
                                                      if(_descriptionController.text.isNotEmpty){
                                                        await MerchantRepo.update(widget.session.merchant.mID,
                                                            {
                                                              'businessDescription':_descriptionController.text,
                                                            });
                                                        setState(() {
                                                          _descriptionEnabler=false;
                                                        });
                                                      }
                                                    },
                                                    color: PRIMARYCOLOR,
                                                    child: Text('Save',style: TextStyle(color: Colors.white),),
                                                  ):
                                                  FlatButton(
                                                    onPressed: ()async{
                                                      setState(() {
                                                        _descriptionEnabler=true;
                                                      });
                                                      await Future.delayed(Duration(milliseconds: 500));
                                                      FocusScope.of(context).requestFocus(_descriptionFocus);
                                                    },
                                                    child: Text('Edit'),
                                                  )
                                              ):Container(),
                                            ],
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
                                          child:
                                          Row(
                                            children: [
                                              Expanded(
                                                child: /*DateTimeField(
                                                  controller: _openController,
                                                  decoration: InputDecoration(
                                                    labelText: "Opening Time",
                                                    hintText: 'Opening Time',
                                                    border: InputBorder.none,
                                                  ),
                                                  enabled: _openEnabler,
                                                  focusNode: _openFocus,
                                                  format: format,
                                                  onShowPicker: (context, currentValue) async {
                                                    final time = await showTimePicker(
                                                        context: context,
                                                        initialTime:
                                                        TimeOfDay.fromDateTime(currentValue ?? DateTime.now()));
                                                    return DateTimeField.convert(time);
                                                  },
                                                )*/
                                                Column(

                                                  children: [
                                                    Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                                                        child: Text('Opening Time'),
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 100,
                                                      child:CupertinoDatePicker(
                                                        mode: CupertinoDatePickerMode.time,
                                                        use24hFormat: true,
                                                        initialDateTime: DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,
                                                            int.tryParse(widget.session.merchant.bOpen.split(':')[0]), int.tryParse(widget.session.merchant.bOpen.split(':')[1])),
                                                        onDateTimeChanged: (DateTime newDateTime) {
                                                          _openController.text = '${newDateTime.hour}:${newDateTime.minute}';
                                                        },
                                                      ),),
                                                  ],
                                                )
                                              ),
                                              !working?
                                              Expanded(
                                                  flex: 0,
                                                  child: _openEnabler?FlatButton(
                                                    onPressed: ()async{
                                                      if(_openController.text.isNotEmpty){
                                                        await MerchantRepo.update(widget.session.merchant.mID,
                                                            {
                                                              'businessOpenTime':_openController.text,
                                                            });
                                                        setState(() {
                                                          _openEnabler=false;
                                                        });
                                                      }
                                                    },
                                                    color: PRIMARYCOLOR,
                                                    child: Text('Save',style: TextStyle(color: Colors.white),),
                                                  ):
                                                  FlatButton(
                                                    onPressed: ()async{
                                                      setState(() {
                                                        _openEnabler=true;
                                                      });
                                                      await Future.delayed(Duration(milliseconds: 500));
                                                      FocusScope.of(context).requestFocus(_openFocus);
                                                    },
                                                    child: Text('Edit'),
                                                  )
                                              ):Container(),
                                            ],
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
                                          child:
                                          Row(
                                            children: [
                                              Expanded(
                                                  child:Column(
                                                    children: [
                                                      Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Padding(
                                                          padding: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                                                          child: Text('Closing Time'),
                                                        ),
                                                      ),

                                                      Container(
                                                        height: 100,

                                                        child:CupertinoDatePicker(
                                                          mode: CupertinoDatePickerMode.time,
                                                          initialDateTime: DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,
                                                              int.tryParse(widget.session.merchant.bClose.split(':')[0]), int.tryParse(widget.session.merchant.bClose.split(':')[1])),
                                                          use24hFormat: true,
                                                          onDateTimeChanged: (DateTime newDateTime) {
                                                            _closeController.text = '${newDateTime.hour}:${newDateTime.minute}';
                                                          },
                                                        ),),
                                                    ],
                                                  )
                                            /*DateTimeField(
                                                    controller: _closeController,
                                                    decoration: InputDecoration(
                                                        labelText: "Closing Time",
                                                        hintText: 'Closing Time',
                                                        border: InputBorder.none,

                                                    ),
                                                    enabled: _closeEnabler,
                                                    focusNode: _closeFocus,
                                                    format: format,
                                                    onShowPicker: (context, currentValue) async {
                                                      final time = await showTimePicker(
                                                          context: context,
                                                          initialTime:
                                                          TimeOfDay.fromDateTime(currentValue ?? DateTime.now()));
                                                      return DateTimeField.convert(time);
                                                    },
                                                  )*/
                                              ),
                                              !working?
                                              Expanded(
                                                  flex: 0,
                                                  child: _closeEnabler?FlatButton(
                                                    onPressed: ()async{
                                                      if(_closeController.text.isNotEmpty){
                                                        await MerchantRepo.update(widget.session.merchant.mID,
                                                            {
                                                              'businessCloseTime':_closeController.text,
                                                            });
                                                        setState(() {
                                                          _closeEnabler=false;
                                                        });
                                                      }
                                                    },
                                                    color: PRIMARYCOLOR,
                                                    child: Text('Save',style: TextStyle(color: Colors.white),),
                                                  ):
                                                  FlatButton(
                                                    onPressed: ()async{
                                                      setState(() {
                                                        _closeEnabler=true;
                                                      });
                                                      await Future.delayed(Duration(milliseconds: 500));
                                                      FocusScope.of(context).requestFocus(_closeFocus);
                                                    },
                                                    child: Text('Edit'),
                                                  )
                                              ):Container(),
                                            ],
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
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller: _emailController,
                                                  decoration: InputDecoration(
                                                      labelText: 'Business Email',
                                                      hintText: 'Business Email',
                                                      border: InputBorder.none),
                                                  keyboardType: TextInputType.text,
                                                  autocorrect: false,
                                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                                  focusNode: _emailFocus,
                                                  enabled: _emailEnabler,
                                                  inputFormatters: <TextInputFormatter>[
                                                    //WhitelistingTextInputFormatter.digitsOnly
                                                  ],
                                                ),
                                              ),
                                              !working?
                                              Expanded(
                                                  flex: 0,
                                                  child: _emailEnabler?FlatButton(
                                                    onPressed: ()async{
                                                      if(_emailController.text.isNotEmpty){
                                                        await MerchantRepo.update(widget.session.merchant.mID,
                                                            {
                                                              'businessEmail':_emailController.text,
                                                            });
                                                        setState(() {
                                                          _emailEnabler=false;
                                                        });
                                                      }
                                                    },
                                                    color: PRIMARYCOLOR,
                                                    child: Text('Save',style: TextStyle(color: Colors.white),),
                                                  ):
                                                  FlatButton(
                                                    onPressed: ()async{
                                                      setState(() {
                                                        _emailEnabler=true;
                                                      });
                                                      await Future.delayed(Duration(milliseconds: 500));
                                                      FocusScope.of(context).requestFocus(_emailFocus);
                                                    },
                                                    child: Text('Edit'),
                                                  )
                                              ):Container(),
                                            ],
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
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller: _telephoneController,
                                                  decoration: InputDecoration(
                                                      labelText: 'Business Telephone',
                                                      hintText: 'Business Telephone',
                                                      border: InputBorder.none),
                                                  keyboardType: TextInputType.text,
                                                  autocorrect: false,
                                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                                  focusNode: _telephone,
                                                  enabled: _telephoneEnabler,
                                                  inputFormatters: <TextInputFormatter>[
                                                    //WhitelistingTextInputFormatter.digitsOnly
                                                  ],
                                                ),
                                              ),
                                              !working?
                                              Expanded(
                                                  flex: 0,
                                                  child: _telephoneEnabler?FlatButton(
                                                    onPressed: ()async{
                                                      if(_telephoneController.text.isNotEmpty){
                                                        await MerchantRepo.update(widget.session.merchant.mID,
                                                            {
                                                              'businessTelephone':_telephoneController.text,
                                                            });
                                                        setState(() {
                                                          _telephoneEnabler=false;
                                                        });
                                                      }
                                                    },
                                                    color: PRIMARYCOLOR,
                                                    child: Text('Save',style: TextStyle(color: Colors.white),),
                                                  ):
                                                  FlatButton(
                                                    onPressed: ()async{
                                                      setState(() {
                                                        _telephoneEnabler=true;
                                                      });
                                                      await Future.delayed(Duration(milliseconds: 500));
                                                      FocusScope.of(context).requestFocus(_telephone);
                                                    },
                                                    child: Text('Edit'),
                                                  )
                                              ):Container(),
                                            ],
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
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller: _telephone2Controller,
                                                  decoration: InputDecoration(
                                                      labelText: 'Business Telephone2',
                                                      hintText: 'Business Telephone2',
                                                      border: InputBorder.none),
                                                  keyboardType: TextInputType.text,
                                                  autocorrect: false,
                                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                                  focusNode: _telephone2Focus,
                                                  enabled: _telephone2Enabler,
                                                  inputFormatters: <TextInputFormatter>[
                                                    //WhitelistingTextInputFormatter.digitsOnly
                                                  ],
                                                ),
                                              ),
                                              !working?
                                              Expanded(
                                                  flex: 0,
                                                  child: _telephone2Enabler?FlatButton(
                                                    onPressed: ()async{
                                                      if(_telephone2Controller.text.isNotEmpty){
                                                        await MerchantRepo.update(widget.session.merchant.mID,
                                                            {
                                                              'businessTelephone2':_telephone2Controller.text,
                                                            });
                                                        setState(() {
                                                          _telephone2Enabler=false;
                                                        });
                                                      }
                                                    },
                                                    color: PRIMARYCOLOR,
                                                    child: Text('Save',style: TextStyle(color: Colors.white),),
                                                  ):
                                                  FlatButton(
                                                    onPressed: ()async{
                                                      setState(() {
                                                        _telephone2Enabler=true;
                                                      });
                                                      await Future.delayed(Duration(milliseconds: 500));
                                                      FocusScope.of(context).requestFocus(_telephone2Focus);
                                                    },
                                                    child: Text('Edit'),
                                                  )
                                              ):Container(),
                                            ],
                                          )
                                      ),
                                      !widget.session.merchant.adminUploaded?
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
                                          child:
                                          Column(
                                              children:[
                                                Center(
                                                  child: Text('Business Availability'),
                                                ),
                                                SizedBox(height: 10,),
                                                Center(child: ToggleButtons(
                                                  borderColor: Colors.blue.withOpacity(0.5),
                                                  fillColor: Colors.blue,
                                                  borderWidth: 1,
                                                  selectedBorderColor: Colors.blue,
                                                  selectedColor: Colors.white,
                                                  borderRadius: BorderRadius.circular(0),
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.all(4.0),
                                                      child: Text(
                                                        'Unvailable',
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(4.0),
                                                      child: Text(
                                                        'Available',
                                                      ),
                                                    ),
                                                  ],
                                                  onPressed: (int index) async{
                                                    setState(() {
                                                      for (int i = 0; i < isSelected.length; i++) {
                                                        isSelected[i] = i == index;
                                                      }
                                                    });
                                                    if(!working) {
                                                      await MerchantRepo
                                                          .update(
                                                          widget.session.merchant.mID,
                                                          {
                                                            'businessStatus': isSelected.indexOf(true),
                                                          });
                                                      setState(() {});
                                                    }
                                                  },
                                                  isSelected: isSelected,
                                                  constraints: BoxConstraints(
                                                      maxWidth: Get.width,
                                                      minWidth: Get.width*0.25
                                                  ),
                                                ),
                                                )
                                              ]
                                          )
                                      ):const SizedBox.shrink(),
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
                                        child: Column(
                                          children: <Widget>[
                                            Text(
                                                "Business Cover Photo:",
                                                style:
                                                TextStyle(color: Colors.black54)),
                                            images.length < 1 && !working
                                                ? Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                              children: <Widget>[
                                                Center(
                                                  child: FlatButton(
                                                    onPressed: () {
                                                      _showCamera(1);
                                                    },
                                                    child: Column(
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.file_upload,
                                                          color: Colors.black54,
                                                          size: MediaQuery.of(
                                                              context)
                                                              .size
                                                              .height *
                                                              0.05,
                                                        ),
                                                        FittedBox(
                                                          fit: BoxFit.contain,
                                                          child: Text(
                                                              "Select a Photo",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black54)),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Center(
                                                  child: FlatButton(
                                                    onPressed: () {
                                                      _showCamera(0);
                                                    },
                                                    child: Column(
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.photo_camera,
                                                          color: Colors.black54,
                                                          size: MediaQuery.of(
                                                              context)
                                                              .size
                                                              .height *
                                                              0.05,
                                                        ),
                                                        FittedBox(
                                                          fit: BoxFit.contain,
                                                          child: Text(
                                                            "Capture a Photo",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black54),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                                : Container(),
                                            Container(
                                                padding: EdgeInsets.only(top: 10),
                                                child: images.isNotEmpty
                                                    ? Wrap(
                                                    spacing: 5.0,
                                                    children:
                                                    List<Widget>.generate(
                                                        images
                                                            .length,
                                                            (index) => Container(
                                                          width: MediaQuery.of(
                                                              context)
                                                              .size
                                                              .width *
                                                              0.4,
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  width:
                                                                  1,
                                                                  color: Colors
                                                                      .grey
                                                                      .withOpacity(0.5))),
                                                          child: Column(
                                                            children: <
                                                                Widget>[
                                                              Align(
                                                                alignment:
                                                                Alignment
                                                                    .centerLeft,
                                                                child:
                                                                !working?
                                                                IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    FirebaseStorage.instance.getReferenceFromUrl(images[index]).then((value){
                                                                      value.delete().then((value) => null);
                                                                      images.remove(images[index]);
                                                                      MerchantRepo.update(widget.session.merchant.mID, {'businessPhoto':images.isNotEmpty?images.first:PRODUCTDEFAULT}).then((value)
                                                                      {
                                                                        setState(() {});
                                                                      });

                                                                    });


                                                                  },
                                                                  alignment:
                                                                  Alignment.centerLeft,
                                                                  icon:
                                                                  Icon(
                                                                    Icons
                                                                        .delete,
                                                                    color:
                                                                    Colors.black54,
                                                                  ),
                                                                ):Container(),
                                                              ),
                                                              Image.network(
                                                                images[
                                                                index],
                                                                fit: BoxFit
                                                                    .fill,
                                                              )
                                                            ],
                                                          ),
                                                        )).toList())
                                                    : Container())
                                          ],
                                        ),
                                      ),
                                     /* !widget.session.merchant.adminUploaded?
                                      !working?
                                          widget.session.merchant.bActive?
                                      Container(
                                          padding: EdgeInsets.all(
                                              Get.width *
                                                  0.02),
                                          child: Center(
                                              child: FlatButton.icon(
                                                onPressed:(){
                                                  Get.defaultDialog(
                                                    title: 'Confirm',
                                                    content: Text('Are you sure you want to deactivate this business?'),
                                                    cancel: FlatButton(
                                                      onPressed: (){Get.back();},
                                                      child: Text('No'),
                                                    ),
                                                    confirm: FlatButton(
                                                      onPressed: ()async{
                                                        Get.back(result: 'Refresh');
                                                        Get.snackbar('', 'Deactivating',
                                                            backgroundColor: Colors.grey,
                                                            colorText: Colors.white,
                                                            snackStyle: SnackStyle.GROUNDED);
                                                        await MerchantRepo.update(widget.session.merchant.mID,{'businessActive':false});
                                                        Get.back(result: 'Refresh');
                                                        Get.snackbar('', 'Deactivated',
                                                            backgroundColor: PRIMARYCOLOR,colorText: Colors.white,
                                                            snackStyle: SnackStyle.GROUNDED);
                                                        Get.back(result: 'Refresh');
                                                      },
                                                      child: Text('Yes'),
                                                    ),

                                                  );
                                                },
                                                padding: EdgeInsets.all(12),
                                                color: Colors.red,
                                                icon: Icon(Icons.close,color: Colors.white,),
                                                label:  Text('Deactivate Business',
                                                    style: TextStyle(
                                                        color: Colors.white)),

                                              )
                                          )):
                                          Container(
                                              padding: EdgeInsets.all(
                                                  Get.width *
                                                      0.02),
                                              child: Center(
                                                  child: FlatButton.icon(
                                                    onPressed:()async{
                                                      await MerchantRepo.update(widget.session.merchant.mID,{'businessActive':true});
                                                      Get.back(result: 'Refresh');
                                                    },
                                                    padding: EdgeInsets.all(12),
                                                    color: PRIMARYCOLOR,
                                                    icon: Icon(Icons.check,color: Colors.white,),
                                                    label:  Text('Activate Business',
                                                        style: TextStyle(
                                                            color: Colors.white)),

                                                  )
                                              ))
                                          :Container():const SizedBox.shrink(),*/
                                    ])),
                          ),
                        )),
                  ]))
            ])));

  }

  void _showCamera(int type) async {
    dynamic camresult;
    if(type == 0) {
      final cameras = await availableCameras();
      final camera = cameras.first;
      camresult = await Get.to(TakePicturePage(camera: camera, fabColor: PRIMARYCOLOR,));
    }
    else{
      var hold = await ImagePicker.pickImage(source: ImageSource.gallery);
      camresult = hold.path;
    }


    if(camresult != null) {
      setState(() {
        pImage = File(camresult);
      });

      Get.dialog(Editor(
          imageFile: pImage,
          callbvck: (image)async{
            setState(() {working = true; });
            Get.snackbar('Uploading',
                'Business Cover Image Uploading',
                backgroundColor: Colors.grey,
                colorText: Colors.black,
                snackStyle: SnackStyle.GROUNDED,
                duration: Duration(days: 365)
            );
            var _images = await Utility.uploadMultipleImages([image],bucket: 'MerchantCover');
            Get.back();
            if(_images.isNotEmpty)
              Get.snackbar('Uploaded',
                'Business Cover Image Uploading',duration: Duration(seconds: 3),
                backgroundColor: PRIMARYCOLOR,
                colorText: Colors.white,
                snackStyle: SnackStyle.GROUNDED,

              );
            else
              Get.snackbar('Upload Error',
                'Failed Uploading image',duration: Duration(seconds: 3),
                backgroundColor: Colors.red,
                colorText: Colors.white,
                snackStyle: SnackStyle.GROUNDED,

              );


            images.addAll(_images);
            await MerchantRepo.update(widget.session.merchant.mID, {'businessPhoto':images.first});
            working = false;
            setState(() { });

          }));
      //Utility.cropImage(pImage).then((value) => print(value.toString()));

    }


  }




  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _openController.dispose();
    _closeController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _telephone2Controller.dispose();
    super.dispose();
  }
}

