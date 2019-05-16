import 'dart:async';
// import 'dart:math';

import 'package:birthcake_bakers/database/database_handler.dart';
import 'package:birthcake_bakers/models/local_methods.dart';
import 'package:birthcake_bakers/chat/custom_chat.dart';
import 'package:birthcake_bakers/tools/firebase_methods.dart';
import 'package:birthcake_bakers/tools/my_strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:latlong/latlong.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';


class OrderMaps extends StatefulWidget {
  @override
  _OrderMapsState createState() => _OrderMapsState();
}

/* To validate delivery, customer should click on "confirm delivery" button on his side
    and driver should also click on "confirm transaction" on his side 
    then the system will validate the delivery.
    Once the client has confirmed that he/she has received the product, the confirmation key
    will be sent to database. Then should wait for the driver to confirm in order to pop 
    successful message to the client.
    */

class _OrderMapsState extends State<OrderMaps> {

  // Location myLocation;
  static var location =Location(),currentLocation = <String, double>{},
      userLocation= <String,double>{};

  var username="", userpicture="", estimatedTime, distance, initDist;

  QuerySnapshot userProfile;
  ProductDatabase pdb = ProductDatabase();
  var eraseProductsInCart, cachedEraser, productIDs;

  bool isLocationEnabled =false, showRating = false, hideBtnDelivery = true,
        userHasReviewed = false, hasReview = false;

  String userID ="", status = "", delivery = Strings.reached, txtDelivery = Strings.confirmText, review;

  static LatLng customerPosition, driverPosition = LatLng(0.2846263, 32.6565395);

  // Google map controllers
  GoogleMapController mapController;

  Completer<GoogleMapController> _controller = Completer();
   CameraPosition _kGooglePlex = CameraPosition(
      target: LatLng(0.2846263, 32.6065395),
      zoom: 14.4746,
    );
  
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  // Timer _timer;
  TextEditingController reviewController =TextEditingController();

  @override
  void initState() {
    super.initState();

    currentLocationStream();
    currentUserProfile();
    // if (isLocationEnabled) 
    // distance = LocalMethods.distanceInKm(customerPosition?.latitude, 0.2846263, customerPosition?.longitude,32.6565395);
    
    // LocalMethods.estimatedTime();

    //set initial distance, in order to evaluate delivery process
    initDBComponents();
  }

  //Initialize sqflite database
  void initDBComponents() async{
   try {
      eraseProductsInCart = await pdb.getProductsInCart();
      setState(() {
        cachedEraser = eraseProductsInCart;
        for (var i = 0; i < cachedEraser.length; i++) {
          productIDs = cachedEraser[i].id;
        }
      });
   } catch (e) {
   }
  }

  void currentLocationStream(){
    location.onLocationChanged().listen((value) {
         currentLocation = value; 
         customerPosition = LatLng(currentLocation["latitude"], currentLocation["longitude"]);

          // Let's pass the distance returned from distanceInKm method into a variable distance
          // distance = LocalMethods.distanceInKm(customerPosition.latitude, 0.2846263, customerPosition.longitude,32.6565395);
          // print("the distance is $distance");

          //Let's Update the camera each time the position changes
          _kGooglePlex = CameraPosition(
            target: customerPosition,
            zoom: 14.4746,
          );
      });
    
    // Let's call changing distance method to update the distance when the app first runs
    // Then reload the UI
    setState(() {
     changingDistance(); 
    });
  }

  // Let's create a method which changes the distance between driver and customer
  void changingDistance(){
    if (customerPosition != null){
      distance = LocalMethods.distanceInKm(customerPosition.latitude, 0.2846263, customerPosition.longitude,32.6565395);
    }
  }

  void currentUserProfile(){
    FirebaseAuth.instance.currentUser().then((userInfo){
      setState(() {
       userID = userInfo.uid; 

       FirebaseHandler.getUserInfo(userID).then((results){
          userProfile = results;

          username =userProfile.documents[0].data["firstname"];
          userpicture =userProfile.documents[0].data["profilePic"];
        });
      });
    });
  }

  void updateShippingStatus(){
    cachedEraser.forEach((e){
      FirebaseHandler.updateOrderShippingStatus(productIDs, {"status":"delivered"}).whenComplete((){
        setState(() {
          delivery = Strings.delivered; 
          txtDelivery = Strings.rateTxt;
          showRating = !showRating;
          hideBtnDelivery = !hideBtnDelivery; 

          //Then delete all products in cart and send to home page
          pdb.deleteProductToCart(productIDs).then((onValue){

          });

        });
        print("Order table successfully updated");
      });
    });
  }
  // void on
  Future<void> _onMapCreated(GoogleMapController controller) async{
     mapController = await _controller.future;
    _controller.complete(controller); 
  }

  
  @override
  Widget build(BuildContext context) {

    //Refresh distance and arrival status everytime the UI changes
    changingDistance();

    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Container(
          child: 
          customerPosition == null ? Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.location_off, size: 54,color: Colors.grey,),
                Text("Unable to load map,\n Please go to Settings -> Location -> then switch it on",
                  textAlign: TextAlign.center,
                )
              ],
            ),
          )
          :
          
          Column(
            children: <Widget>[ 
                Expanded(
                  flex: 8,
                  child: GoogleMap(
                      mapType: MapType.normal,
                      trackCameraPosition: true,
                      myLocationEnabled: true,
                      compassEnabled: true,
                      cameraTargetBounds: CameraTargetBounds(LatLngBounds(
                        southwest: LatLng(0.2846263, 32.6065395),//customer
                        northeast: LatLng(0.2846263, 32.6565395), // driver
                      )),
                      initialCameraPosition: _kGooglePlex,
                      onMapCreated: _onMapCreated,
                      markers: {
                        Marker(
                          position:  customerPosition, //customer position
                          icon: BitmapDescriptor.defaultMarker,
                          markerId: MarkerId("source"),
                          infoWindow: InfoWindow(title: "Me",anchor: Offset(0.8, 0.8),snippet: "Transaction"),
                        ),

                        Marker(
                          position:  LatLng(0.2846263, 32.6565395),
                          icon: BitmapDescriptor.defaultMarker,
                          markerId: MarkerId("destination"),
                          infoWindow: InfoWindow(title: "Driver",anchor: Offset(0.8, 0.8),snippet: "Transaction"),
                        )
                      },
                    ),
                ),

                Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10.0),
                    // height: 200,
                    child: Column(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(children: <Widget>[
                            Icon(Icons.location_on, color: Colors.blue,),
                            Container(
                              child: Text("Kampala, Uganda"),
                            )
                          ],),
                        ),
                        ListTile(
                          leading: CachedNetworkImage(imageUrl: userpicture,fit: BoxFit.cover,width:40, height: 40,),
                          title: Text(username, overflow:TextOverflow.ellipsis),
                          subtitle: Text(LocalMethods.arrivalStatus()),//status : getting ready to come, i'm on my way, i'm almost there, where are you
                          trailing: Column(
                            children: <Widget>[
                              InkWell(
                                onTap: (){},
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.blue[900],
                                  child: Icon(Icons.phone, size: 15),
                                ),
                              ),
                              SizedBox(height: 5,),
                              InkWell(
                                onTap: (){
                                  Navigator.push(context, CupertinoPageRoute(
                                    builder: (context){
                                      return ChatWindow();
                                    }
                                  ));
                                },
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.green[900],
                                  child: Icon(Icons.message, size: 15,),
                                ),
                              )
                            ],
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Text("Estimated Time : "),
                              Text(LocalMethods.estimatedTime()),
                            ],
                          ),
                        ),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Text("Total  Distance : "),
                            Text("$distance km"),
                          ],
                        ),

                        MaterialButton(
                          color: Colors.red[900],
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                          minWidth: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(10.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)
                          ),
                          child: Text("Cancel Order", style: TextStyle(color: Colors.white),),
                          onPressed: (){
                            //Order can be cancelled only if the ride has not started yet or if 
                            //delivery is complete
                            scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text("Action cannot be performed")
                            ));
                          },
                        )
                      ],
                    ),
                  ),
                ),
              
            ],
          ),
        ),
      ),
    );
  }
}

/*
    Navigator.of(context).push(PageRouteBuilder(
            opaque: false,
            maintainState: true,
            pageBuilder: (context, _, __) {
              return Material(
                color: Colors.black38,
                child: Container(
                    padding: EdgeInsets.all(30.0),
                    alignment: Alignment.center,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      // height: 450,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white,
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          Container(
                            child: Column(
                              children: <Widget>[
                                Icon(Icons.check_circle_outline, color: Colors.lightGreen, size: 120,),
                                Text(delivery, style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: "Hind Regular", fontWeight: FontWeight.bold),),
                                SizedBox(height: 20,),
                                
                              ],
                            ),
                          ),

                          Visibility(
                            visible: isConfirmDelivery,
                            child: MaterialButton(
                              color: Colors.blue[900],
                              materialTapTargetSize: MaterialTapTargetSize.padded,
                              minWidth: MediaQuery.of(context).size.width - 280,
                              padding: EdgeInsets.all(10.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)
                              ),
                              child: Text("Confirm delivery", style: TextStyle(color: Colors.white),),
                              onPressed: (){
                                setState(() {
                                  if(Navigator.canPop(context)){
                                    Navigator.pop(context);
                                  }
                                 delivery = Strings.delivered; 
                                 isConfirmDelivery = !isConfirmDelivery;
                                });
                              },
                        ),
                          ),

                        Container(
                          padding: EdgeInsets.all(10.0),
                          child: Text("Confirm whether the driver you have received the product your requested for",
                          style: TextStyle(color: Colors.grey,fontStyle: FontStyle.italic), textAlign: TextAlign.center, overflow: TextOverflow.clip,),
                        ),

                          //Toggle product rating
                          Visibility(visible: true,
                          child: Column(children: <Widget>[
                            Text("Rate this product"),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.star, color: Colors.yellow),
                                Icon(Icons.star, color: Colors.yellow),
                                Icon(Icons.star, color: Colors.yellow),
                                Icon(Icons.star, color: Colors.yellow),
                                Icon(Icons.star, color: Colors.yellow),
                              ],
                            ),
                            
                            TextFormField(
                              decoration: InputDecoration(
                                hintText: "Say something about the product",
                                
                              ),
                            )
                          ],),
                          ),
                        ],
                      ),
                    )),
              );
            })
            );
 */