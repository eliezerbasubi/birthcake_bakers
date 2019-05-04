import 'dart:async';
import 'dart:math';
import 'package:birthcake_bakers/models/users_model.dart';
// import 'package:flutter/services.dart';
//import 'dart:typed_data';
import 'dart:ui';
//import 'dart:io';
import 'package:flutter/rendering.dart';

import 'package:flutter/material.dart';
// import 'package:barcode_scan/barcode_scan.dart';
//import 'package:path_provider/path_provider.dart';

class Order extends StatefulWidget {
  @override
  _OrderState createState() => _OrderState();
}

class _OrderState extends State<Order> {
  String result ="Result will show here";
  bool isResultOK = false;
  bool displayResult = false;
  GlobalKey globalKey = new GlobalKey();
  
  Future scanQRcode() async{
    // try{
    //   String qrResult = await BarcodeScanner.scan();
    //   setState(() {
    //           result = qrResult;
    //           isResultOK = true;
    //           displayResult = true;
    //     });
    // }on PlatformException catch(e){//when camera permission is denied
    //     if (e.code == BarcodeScanner.CameraAccessDenied) {
    //       setState(() {
    //           displayResult = true;
    //            result = "Camera permission denied";       
    //         }); 
    //     }else{// when the error does not result from platform issues
    //     setState(() {
    //         result = "Unknown error";   
    //         displayResult = true;    
    //        });
    //     }
    // }on FormatException{//when back button is pressed and scan did not take place
    //     setState(() {
    //       result = "No result found. Back button was pressed"  ; 
    //       displayResult = true;       
    //     });
    // }catch(exception){
    //    setState(() {
    //         result = "Unknown error";  
    //         displayResult = true;     
    //        });
    //     }
    }

    String _randomString(int length){
      var rand = new Random();
      var codeUnits = new List.generate(length, (index){
          return rand.nextInt(33)+89;
      });
      return new String.fromCharCodes(codeUnits);
    }

  //   Future<void> _captureAndSharePng() async {
  //   try {
  //     RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
  //     var image = await boundary.toImage();
  //     ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
  //     Uint8List pngBytes = byteData.buffer.asUint8List();

  //     final tempDir = await getTemporaryDirectory();
  //     final file = await new File('${tempDir.path}/image.png').create();
  //     await file.writeAsBytes(pngBytes);

  //     final channel = const MethodChannel('channel:me.alfian.share/share');
  //     channel.invokeMethod('shareFile', 'image.png');

  //   } catch(e) {
  //     print(e.toString());
  //   }
  // }

    @override
      void initState() {
        print(_randomString(10));
        super.initState();
      }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: Text("Order Products"),
        ),
        body: Container(
          child: Theme(
            data: ThemeData(
              fontFamily: "Hind-Regular"
            ),
            child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Hero(
                        tag: "users-profile-image",
                        child: CircleAvatar(
                          radius: 78,
                          child: Image.asset(users[0].profileURL),
                          backgroundColor: Theme.of(context).accentColor,
                        ),
                      ),
                    ],
                  ),
                  
                  //NAME OF THE USER AND PHONE NUMBER
                  SizedBox(height: 10,),
                  Text(users[0].name),
                  Text(users[0].phone),

                  //SATISFIED ICON, OK.
                  //IF SCANNER GETS RESULT, DISPLAY TEXT AND ICON TO SHOW SUCCESSFUL MESSAGE
                  displayResult ? Column(
                    children: <Widget>[
                      SizedBox(height: 20,),
                      result == "http://en.m.wikipedia.org" ? Icon(Icons.check_circle,color: Colors.green,size: 70,) :
                      Icon(Icons.highlight_off, color: Colors.red, size: 70),
                    ],
                  ) : Container(),
                  

                  //THANK YOU TEXT
                  SizedBox(height: 15,),
                  Text(result,style: TextStyle(fontFamily: "Hind-Regular",fontSize: 15),),

                  //BARCODE SCANNER BUTTON
                  SizedBox(height: 20,),
                  Material(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    textStyle: TextStyle(fontStyle: FontStyle.normal),
                    child: MaterialButton(
                      elevation: 10,
                      height: 40,
                      padding: EdgeInsets.all(15.0),
                      onPressed: (){
                        scanQRcode();
                      },
                      child: Text("scan code", style: TextStyle(color: Colors.white),),
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                ],
              )
            ],
      ),
          ),
        ),
    );
  }
  }
