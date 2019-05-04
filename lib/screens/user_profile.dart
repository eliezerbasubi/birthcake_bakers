import 'package:birthcake_bakers/models/products_model.dart';
// import 'package:birthcake_bakers/models/users_model.dart';
import 'package:birthcake_bakers/screens/timeline_ui.dart';
import 'package:birthcake_bakers/tools/firebase_methods.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List<Model> products = new List<Model>();
  QuerySnapshot userDetails;
  String uid;
  var username = "", userEmail = "", userPhone = "", userLocation = "", profileImage = "";

  @override
  void initState() {
     super.initState();

     initUserProfile();
  }

  initUserProfile(){
    for (var i = 0; i < 7; i++) {
      products.add(data[i]);
    }

    FirebaseAuth.instance.currentUser().then((userInfo){
      setState(() {
       uid =userInfo.uid; 

        FirebaseHandler.getUserInfo(uid).then((results){
          setState(() {
            userDetails =results;
          });
        });

      });
    });

    
    // initBuildDetails();
  }

  initBuildDetails(){
    if(userDetails != null){
      username =userDetails.documents[0].data["firstname"];
      userEmail =userDetails.documents[0].data["email"];
      userPhone =userDetails.documents[0].data["phone"];
      userLocation =userDetails.documents[0].data["location"];
      profileImage =userDetails.documents[0].data["profilePic"];
    }
  }

  @override
  Widget build(BuildContext context) {
    initBuildDetails();

    if(userDetails ==null){
      return Center(
        child: CircularProgressIndicator()
      );
    }

    return Scaffold(
      body: ListView(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  //Start profile image
                  ClipPath(
                    clipper: CustomShapeClipper(),
                    child: Container(
                      height: 300.0,
                      color: Theme.of(context).primaryColor,
                      child: Image.asset("images/runner.png",
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover),
                    ),
                  ),
                  //End profile image

                  //Start circular image profile
                  Positioned(
                    left: MediaQuery.of(context).size.width / 3,
                    top: 220,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                              opaque: false,
                              pageBuilder: (context, _, __) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Material(
                                    color: Colors.black38,
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: Hero(
                                          tag: "profile-image",
                                          child: CachedNetworkImage(
                                            imageUrl : profileImage),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        );
                      },
                      child: Hero(
                        tag: "profile-image",
                        child: CircleAvatar(
                          radius: 45,
                          backgroundImage: CachedNetworkImageProvider(profileImage),
                        ),
                      ),
                    ),
                  )
                  //End circular image profile
                ],
              ),
              //End Stack

              //Start profile details
              //SizedBox(height: 10.0,),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Card(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      child: Column(
                        children: <Widget>[
                          //Username
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                username,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {},
                              )
                            ],
                          ),

                          //Email
                          Text(userEmail),

                          //Phone Number
                          Text(userPhone),

                          //Location
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.location_on,
                                color: Colors.red,
                              ),
                              Text(userLocation),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              //End profile details

              //Start Credit card information
              //Start credit card header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                child: Text(
                  "Credit Card Information",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.normal),
                  textAlign: TextAlign.start,
                ),
              ),
              //End credit card header
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 6,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(5.0),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.blueGrey.shade800,
                              Colors.black87,
                            ]
                          ),
                          image: DecorationImage(
                            image: AssetImage("images/map.png")
                          )
                        ),
                     child: Column(
                     children: <Widget>[
                        //Row for my card type
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Primary Card",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Hind-Regular",
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                                textAlign: TextAlign.start,
                              ),
                              Icon(Icons.credit_card),
                            ],
                          ),
                        ),
                        //End row for my card type

                        //Start Card number text and expiration date text row
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Card Number",
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                "Card Number",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        //End card number and expiration date row

                        //Start card number and exp date row
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("XXXX - XXXX - XXXX - 3003",
                                  style: TextStyle(
                                    fontFamily: "Hind-Regular",
                                    fontWeight: FontWeight.bold,
                                  )),
                              Text(
                                "03/30",
                                style: TextStyle(
                                    fontFamily: "Hind-Regular",
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        //End card number and exp date row

                        //Start Card holder name and CVV/CVC text
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Card Holder Name",
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                "CVV / CVC",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        //End Card holder name and cvv/cvc text

                        //Start Card holder name and cvv/cvc info
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                username,
                                style: TextStyle(
                                    fontFamily: "Hind-Regular",
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "330",
                                style: TextStyle(
                                    fontFamily: "Hind-Regular",
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        //End card holder name and cvv/cvc info
                    ],
                  ),
                  )),
                ),
              ),
              //End Credit card information

              //Start delivery address
              //Start order history header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                child: Text(
                  "Delivery Address",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 17,
                      fontWeight: FontWeight.normal),
                  textAlign: TextAlign.start,
                ),
              ),
              //End order history header
              Container(
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              //column for house icon
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Image.asset("images/house.png", height : 60, width : 60),
                                ],
                              ),

                              //Column for address info
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, bottom: 8.0),
                                    child: Text(
                                      "Delivery Address",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                                  Text(
                                    "Home, Work & Other Address",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "House No: 3003, 3rd Floor Block A",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey),
                                  ),
                                  Text(
                                    "Kampala, Uganda",
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ))),
              //End delivery address

              //Start order history details

              //Start order history header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                child: Text(
                  "Orders History",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 17,
                      fontWeight: FontWeight.normal),
                  textAlign: TextAlign.start,
                ),
              ),
              //End order history header

              Container(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    child: ListView(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: MyTimeLine(
                              "Ready to pickup",
                              "Order from BirthCake Bakers",
                              "11:00 pm",
                              Icon(Icons.shopping_basket)),
                        ),
                        MyTimeLine(
                            "Order Processed",
                            "We are preparing your order",
                            "11:20 PM",
                            Icon(Icons.assignment_ind)),
                        MyTimeLine(
                            "Payment confirmed",
                            "Your payment has been confirmed",
                            "12:00 PM",
                            Icon(Icons.attach_money)),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: MyTimeLine(
                              "Order Placed",
                              "Order successfully received",
                              "12:20 PM",
                              Icon(Icons.check_circle)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              //End order history details
            ],
          ),

          //Start transactions details

          //Start transaction header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            child: Text(
              "Transactions Details",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 17,
                  fontWeight: FontWeight.normal),
              textAlign: TextAlign.start,
            ),
          ),
          //End transaction header

          Container(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                child: ListView(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  children: <Widget>[
                    Transactions("Jan 01", products[0].name,
                        products[0].price.toString()),
                    Transactions("Feb 13", products[4].name,
                        products[4].price.toString()),
                    Transactions("Mar 30", products[3].name,
                        products[3].price.toString()),
                    Transactions("May 31", products[1].name,
                        products[1].price.toString()),
                    Transactions("Dec 12", products[5].name,
                        products[5].price.toString()),
                  ],
                ),
              ),
            ),
          ),
          //End transaction details
        ],
      ),
    );
  }
}

class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = new Path();

    path.lineTo(0.0, size.height);

    var firstEndPoint = Offset(size.width * .5, size.height - 30.0);
    var firstController = Offset(size.width * 0.25, size.height - 50.0);

    path.quadraticBezierTo(firstController.dx, firstController.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 80.0);
    var secondController = Offset(size.width * 0.75, size.height - 10.0);

    path.quadraticBezierTo(secondController.dx, secondController.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
