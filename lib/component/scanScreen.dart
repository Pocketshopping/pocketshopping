import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';

class ScanScreen extends StatefulWidget {
  ScanScreen(this.themeColor);
  final Color themeColor;
  @override
  _ScanState createState() => new _ScanState(themeColor);
}

class _ScanState extends State<ScanScreen> {

  _ScanState(this.themeColor);
  final Color themeColor;

  String barcode = "";

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child:

                Container(

                  child: FlatButton(

                    onPressed: () => {
                      this.scan()
                    },

                    padding: EdgeInsets.all(10.0),
                    child: Column( // Replace with a Row for horizontal icon + text
                      children: <Widget>[
                        Center(child:Text("1.Visit https://screen.pocketshopping.com",style: TextStyle(fontSize:14, color: Colors.black54),textAlign: TextAlign.center,)),
                        Center(child:Text("2.Click on the scan button below to share screen",style: TextStyle(fontSize:14, color: Colors.black54),textAlign: TextAlign.center,)),
                        Container(height: 10,),
                        FittedBox(fit:BoxFit.contain,child:Icon(Icons.camera,color: themeColor, size: MediaQuery.of(context).size.height*0.1,)),
                        Center(child:Text("Scan QRCode to share screen",style: TextStyle(color: Colors.black54),textAlign: TextAlign.center,)),
                      ],
                    ),
                  ),
                ),



              )
              ,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(barcode, textAlign: TextAlign.center,),
              )
              ,
            ],
          ),
        );
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException{
      setState(() => this.barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }
}
