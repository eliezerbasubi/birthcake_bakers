import 'dart:async';

import 'package:birthcake_bakers/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Steppers extends StatefulWidget {
  @override
  _SteppersState createState() => _SteppersState();
}

class _SteppersState extends State<Steppers>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  String txtBtn = "Next";
  String visited = "";

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 5, initialIndex: 0);
  }

  // @override
  // void dispose(){
  //   // _tabController.dispose();
  //   super.dispose();
  // }

  //Save status of activity, if the user has or has not visited the app
  //For the first the boolean visited is false, then when user clicks on GOT IT,
  //It becomes true, and this page will not load for the second time he'll open the app.
  Future<bool> saveVisit(String visited) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("visited", visited);

    return true;
  }

  @override
  Widget build(BuildContext context) {
    var icons = <Widget>[
      Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Hero(
              tag: "steppers logo",
              //child: CircleAvatar(
              //radius: 200,
              child: Icon(
                Icons.cake,
                size: 180,
              ),
              // ),
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              "Ready for cakes",
              style: TextStyle(
                  fontFamily: "Hind-Regular",
                  fontSize: 25,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
                "Shop as many as possible cakes you need for your Birthday,"
                "\n Wedding or any event you are planning to celebrate.\n"
                "Healthy cakes cost more than anything",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: "Hind-Regular", fontSize: 15)),
          ],
        ),
      ),
      Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Hero(
              tag: "steppers logo",
              //child: CircleAvatar(
              //radius: 200,
              child: Icon(
                Icons.restaurant_menu,
                size: 180,
              ),
              // ),
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              "Make an Order",
              style: TextStyle(
                  fontFamily: "Hind-Regular",
                  fontSize: 25,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
                "Request for a cake that meets your requirements.\n"
                "Provide additional details of how you want your cake to be baked.\n"
                "Customer satisfaction is our need ! ",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: "Hind-Regular", fontSize: 15)),
          ],
        ),
      ),
      Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Hero(
              tag: "steppers logo",
              //child: CircleAvatar(
              //radius: 200,
              child: Icon(
                Icons.location_on,
                size: 180,
              ),
              // ),
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              "Farest Places",
              style: TextStyle(
                  fontFamily: "Hind-Regular",
                  fontSize: 25,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
                "Distance does not matter for us, just one click on location,"
                "\n And we will locate you in right time and right place.\n"
                "A far far better thing that we do.",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: "Hind-Regular", fontSize: 15)),
          ],
        ),
      ),
      Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Hero(
              tag: "steppers logo",
              //child: CircleAvatar(
              //radius: 200,
              child: Icon(
                Icons.credit_card,
                size: 180,
              ),
              // ),
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              "Affordable Payment",
              style: TextStyle(
                  fontFamily: "Hind-Regular",
                  fontSize: 25,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
                "Wondering how to pay ?,"
                "\n Pay using PayPal and Mobile money or cash on delivery.\n"
                "We give the best prices. We guarantee.",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: "Hind-Regular", fontSize: 15)),
          ],
        ),
      ),
      Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Hero(
              tag: "steppers logo",
              //child: CircleAvatar(
              //radius: 200,
              child: Icon(
                Icons.tag_faces,
                size: 180,
              ),
              // ),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "Enjoy Cake",
              style: TextStyle(
                  fontFamily: "Hind-Regular",
                  fontSize: 25,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
                "Enjoy your cake, Don't forget to shop more cakes at anytime ,"
                "\nFeel the moment, feel the delicious taste.\n"
                "Delicious Taste is your right.",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: "Hind-Regular", fontSize: 15)),

            //got it button
            SizedBox(
              height: 10,
            ),
            MaterialButton(
              minWidth: 120,
              padding: EdgeInsets.all(10.0),
              color: Colors.black,
              onPressed: () {
                setState(() {
                  visited = "Visited";
                  saveVisit(visited).then((value) {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Login()));

                        print("the status from steppers is $visited");
                  });
                  
                });
              },
              child: Text("GOT IT",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: "Hind-Regular",
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    ];

    return DefaultTabController(
      key: Key("steppers"),
        length: icons.length,
        child: Builder(
          builder: (context) => Padding(
                padding: EdgeInsets.all(8.0),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    //SKIP BUTTON
                    Positioned(
                        right: 4.0,
                        top: 25.0,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.black.withOpacity(0.7),
                          child: IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: 15,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _tabController = DefaultTabController.of(context);
                              if (!_tabController.indexIsChanging) {
                                _tabController.animateTo(icons.length - 1);
                              }
                            },
                          ),
                        )),

                    //This column below produces error, scrollableState error

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: TabBarView(
                              //controller: _tabController,
                              children: icons),
                        ),
                    //     //tab selector widget
                        Flexible(
                            flex: 1,
                            child: TabPageSelector(
                              selectedColor: Colors.black,
                            )),
                      ],
                    ),

                    //Positioned widget for next button
                    //  Positioned(
                    //    left: 10.0,
                    //    bottom: 5.0,
                    //    width: MediaQuery.of(context).size.width,
                    //   child: Row(
                    //     mainAxisSize: MainAxisSize.max,
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: <Widget>[
                    //       //NEXT BUTTON
                    //       MaterialButton(
                    //         minWidth: MediaQuery.of(context).size.width,
                    //         padding: EdgeInsets.all(20.0),
                    //         color: Colors.black,

                    //       onPressed: (){

                    //       },

                    //        child: Text(txtBtn,style: TextStyle(
                    //             color: Colors.white, fontSize: 16,fontFamily: "Hind-Regular",
                    //             fontWeight: FontWeight.w700)),
                    //         ),
                    //     ],
                    //   ),
                    //  )
                  ],
                ),
              ),
        ));
  }
}
