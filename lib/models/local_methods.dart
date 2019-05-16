import 'dart:math';

import 'package:birthcake_bakers/tools/my_strings.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocalMethods {
  //initDist is the distance before the driver starts to ride
  static double dist, initDist, hours, minutes, seconds;
  static var speed = 53;
  static var initialDistance;

  static capitalize(String word) {
    List<String> input = word.split(" ");
    StringBuffer sb = StringBuffer();
    String result = "", output= "";
    try {
      for (var res in input) {
        result = res.substring(0, 1).toUpperCase() + res.substring(1);
        sb.write(result + " ");
      }

       output = sb.toString();
    } catch (e) {}

    return output;
  }

   static double deg2rad(double deg) {
      return (deg * pi / 180.0);
  }

  static double rad2deg(double rad) {
      return (rad * 180.0 / pi);
    }
  
  //Pass two parameters to distanceInkm method, customer current position and 
  //Driver current position
  static distanceInKm(clientLat, driverLat, clientLong, driverLong){
      // var R = 6371; // km
      var lat1 = clientLat, lat2 = driverLat;
      var lon1 = clientLong, lon2 = driverLong;
     double theta = lon1 - lon2;
     dist = sin(deg2rad(lat1)) * sin(deg2rad(lat2)) + cos(deg2rad(lat1)) 
                    * cos(deg2rad(lat2)) * cos(deg2rad(theta));
      dist = acos(dist);
      dist = rad2deg(dist);
      dist = dist * 60 * 1.1515;
      // if (unit == 'K') {
        dist = dist * 1.609344;
      // } else if (unit == 'N') {
        // dist = dist * 0.8684;
        // } formula of time = distance / speed
      return (dist.toStringAsFixed(2));
  }

  static estimatedTime(){
    var estimated ;

    if(dist != null){
        var time = dist / speed;
        hours = time / 3600;
        minutes = time * 3600 / 60;

        seconds = minutes.remainder(3);

        seconds = seconds * 60;

        //Check if seconds is greater than 60, then convert it back to 60
        if(seconds > 60){
          seconds = seconds / 60;
          seconds =  seconds.remainder(3);
        }

        // print("${hours.round()} : ${minutes.round()} : $seconds");
        
        if (hours.round() == 0) {
          estimated = "${minutes.round()}min ${seconds.round()}s";
        } else {
          estimated = "${hours.round()}h ${minutes.round()}min";
        }
      }
    return estimated;
  }

  static getInitialDistance(cLat, dLat, cLong, dLong){
    var lat1 = 0.2846263, lat2 = 0.2846263;
      var lon1 = 32.6065395, lon2 = 32.6565395;
     double theta = lon1 - lon2;
     initDist = sin(deg2rad(lat1)) * sin(deg2rad(lat2)) + cos(deg2rad(lat1)) 
                    * cos(deg2rad(lat2)) * cos(deg2rad(theta));
      initDist = acos(initDist);
      initDist = rad2deg(initDist);
      initDist = initDist * 60 * 1.1515;
      // if (unit == 'K') {
      initDist = initDist * 1.609344;

      initialDistance = initDist.toStringAsFixed(2);
      return (initDist.toStringAsFixed(2));
  }

  static arrivalStatus(){
    var status = "";
    if(dist != null){
      var distance = double.parse(dist.toStringAsFixed(2));
      //the real or initial distance between driver and customer
      if (distance >= 50.0) {
        status = Strings.onMyWay;
      } else if(dist <= (dist / 2)) {
        status = Strings.almostThere;
      }else if(dist <= 1.500){
        status = Strings.closeToYou;
      }else {
        status = Strings.alreadyThere;
      }
      // print("The get initial distance is $initialDistance and distance $distance");

    }
    return status;
  }

  static hasDriverArrived(LatLng clientLocation, LatLng driverLocation){
    // double cLat = clientLocation.latitude;
    // double dLat =  driverLocation.latitude;
    // double cLong =  clientLocation.longitude;
    // double dLong =  driverLocation.longitude;


  }
}



/*
import 'dart:async';
import 'dart:math';

import 'package:birthcake_bakers/database/database_handler.dart';
import 'package:birthcake_bakers/models/local_methods.dart';
import 'package:birthcake_bakers/chat/custom_chat.dart';
import 'package:birthcake_bakers/tools/firebase_methods.dart';
import 'package:birthcake_bakers/tools/my_strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cached_network_image/cached_network_image.dart';
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
  Timer _timer;
  TextEditingController reviewController =TextEditingController();

  @override
  void initState() {
    super.initState();

    // mapController = MapController();
    // Get current user location
    getCurrentLocation().then((position){
      userLocation = position;
    });

    currentLocationStream();
    currentUserProfile();
    // if (isLocationEnabled) 
    distance = LocalMethods.distanceInKm(customerPosition?.latitude, 0.2846263, customerPosition?.longitude,32.6565395);
    
    LocalMethods.estimatedTime();

    //set initial distance, in order to evaluate delivery process
    getInitialDistance();
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

  getInitialDistance(){
    var lat1 = customerPosition.latitude, lat2 = 0.2846263;
      var lon1 = customerPosition.longitude, lon2 = 32.6565395;
     double theta = lon1 - lon2;
     initDist = sin(LocalMethods.deg2rad(lat1)) * sin(LocalMethods.deg2rad(lat2)) + cos(LocalMethods.deg2rad(lat1)) 
                    * cos(LocalMethods.deg2rad(lat2)) * cos(LocalMethods.deg2rad(theta));
      initDist = acos(initDist);
      initDist = LocalMethods.rad2deg(initDist);
      initDist = initDist * 60 * 1.1515;
      // if (unit == 'K') {
        initDist = initDist * 1.609344;
      return (initDist.toStringAsFixed(2));
  }

  arrivalStatus(){
    // setState(() {
     var dist = double.parse(distance);
      var initial = double.parse(getInitialDistance());
      //the real or initial distance between driver and customer
      if (dist == initial || dist > (initial / 2)) {
        status = Strings.onMyWay;
      } else if(dist == (initial / 2)) {
        status = Strings.almostThere;
      }else if(dist < 1.500 && dist > 0.50){
        status = Strings.closeToYou;
      }else {
        status = Strings.alreadyThere;
      }
      print("The get initial distance is $initial and distance $distance"); 

      if(status == Strings.alreadyThere){
       _timer =  Timer(Duration(seconds: 5), (){
          scaffoldKey.currentState.showBottomSheet((context){
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))
              ),
              child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Container(
                        child: Column(
                          children: <Widget>[
                            Visibility(
                              visible: showRating,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black
                                    ),
                                    child: InkWell(
                                      onTap: (){
                                        Navigator.pop(context);
                                      },
                                      child: Icon(Icons.clear, color: Colors.white,))),
                                ),
                              ),
                            ),
                            Icon(Icons.check_circle_outline, color: Colors.lightGreen, size: 120,),
                            Text(delivery, style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: "Hind Regular", fontWeight: FontWeight.bold),),
                            SizedBox(height: 20,),
                            
                          ],
                        ),
                      ),

                      Visibility(
                        visible: hideBtnDelivery,
                        child: RaisedButton(
                          color: Colors.blue[900],
                          // materialTapTargetSize: MaterialTapTargetSize.padded,
                          padding: EdgeInsets.all(10.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)
                          ),
                          child: Text("Confirm delivery", style: TextStyle(color: Colors.white),),
                          onPressed: (){
                            setState(() {
                              delivery = Strings.delivered; 
                              txtDelivery = Strings.rateTxt;
                              showRating = !showRating;
                              hideBtnDelivery = !hideBtnDelivery; 

                             updateShippingStatus(); 
                            });
                          },
                    ),
                  ),

                    Container(
                      padding: EdgeInsets.all(10.0),
                      child: Text(txtDelivery,
                      style: TextStyle(color: Colors.grey,fontStyle: FontStyle.italic), textAlign: TextAlign.center, overflow: TextOverflow.clip,),
                    ),

                      //Toggle product rating
                      Visibility(visible: showRating,
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
                        
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: reviewController,
                            validator: (txt){
                              if(txt.isEmpty){
                                return "Write down something";
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "Say something about the product",
                             ),
                          ),
                        ),

                        RaisedButton(
                          color: Colors.blue[900],
                          child: Text("Submit", style: TextStyle(color: Colors.white),),
                          onPressed: (){
                            review = reviewController.text;

                            if (review.isNotEmpty) {
                              reviewController.clear();

                               //Add review to products ordered
                              //check for duplicates before inputting reviews
                              // FirebaseHandler.doesUserAlreadyRewiew(userID,"-LZwLlYqXn8ZGiZcmlhx").then((valid){
                              //     userHasReviewed = valid;

                              //     if(userHasReviewed){
                              //       print("Has reviewed this product $userHasReviewed");
                              //     }
                              // });
                            }else{
                              print("review is empty");
                            }
                            
                          },
                        ),
                      ],),
                      ),
                    ],
                  ),
            );
          }).closed.whenComplete((){
            if(mounted){
              _timer.cancel();
            }
          });
        });
      }
    // });

    // return status;
  }

  Future<Map<String, double>> getCurrentLocation() async {
    var currentLocation = <String, double>{};
    try {
      currentLocation = await location.getLocation();
      isLocationEnabled = await location.hasPermission();

      if(isLocationEnabled){
        customerPosition = LatLng(currentLocation["latitude"], currentLocation["longitude"]);
        distance = LocalMethods.distanceInKm(customerPosition.latitude, 0.2846263, customerPosition.longitude,32.6565395);
      }else{
        //Will be  replaced or deleted later
        customerPosition = LatLng(0.2846263, 32.6565395);
      }
      //Just for now set manually driver position as we don't have any database to handle his position
      driverPosition = LatLng(0.2846263, 32.6565395);

      _kGooglePlex = CameraPosition(
          target: customerPosition,
          zoom: 14.4746,
        );
  
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }


  void currentLocationStream(){
    location.onLocationChanged().listen((value) {
         currentLocation = value; 
         customerPosition = LatLng(currentLocation["latitude"], currentLocation["longitude"]);

          //Refresh distance everytime it is changed
        distance = LocalMethods.distanceInKm(customerPosition.latitude, 0.2846263, customerPosition.longitude,32.6565395);
      });
      //if current position equals to old position after 10min, alert,i was in jam
    
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

    //Refresh distance and arrival status everytime it is changed
    // if(isLocationEnabled)
    distance = LocalMethods.distanceInKm(customerPosition.latitude, 0.2846263, customerPosition.longitude,32.6065395);
    
    arrivalStatus();

    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Container(
          child: 
          // !isLocationEnabled ? Container(
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: <Widget>[
          //       Icon(Icons.location_off, size: 54,color: Colors.grey,),
          //       Text("Unable to load map,\n Please go to Settings -> Location -> then switch it on",
          //         textAlign: TextAlign.center,
          //       )
          //     ],
          //   ),
          // )
          // :
          
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
                          subtitle: Text(status),//status : getting ready to come, i'm on my way, i'm almost there, where are you
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
*/