import 'package:get/get.dart';

class OrderGlobalState extends GetController{
  static OrderGlobalState get to => Get.find();

  Map<String,dynamic> order = {};

  void adder(String key,Map<String,dynamic> other){
    order[key] = other;
    update(this);
  }

  void updater(String keyFirst,String keySecond, dynamic value){
    order[keyFirst][keySecond] = value;
    update(this);
  }

  void deleter(String key){
    order.remove(key);
    update(this);
  }

}