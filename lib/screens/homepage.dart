import 'dart:math';

import 'package:birthcake_bakers/details/category_list.dart';
import 'package:birthcake_bakers/models/local_methods.dart';
import 'package:birthcake_bakers/models/products_model.dart';
import 'package:birthcake_bakers/screens/details_controller.dart';
import 'package:birthcake_bakers/screens/home.dart';
import 'package:birthcake_bakers/screens/admin_part.dart';
import 'package:birthcake_bakers/tools/firebase_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  final Function addProductToCart;

  HomePage({this.addProductToCart});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String title, keyID;
  var rand = new Random();
  var randIndex;
  QuerySnapshot products;
  var romantics, weddings, birthdays, recents;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    randIndex = List.generate(4, (int index) => rand.nextInt(data.length))
        .toSet()
        .toList();

    initMethods();

    //Scroll
    scrollController.addListener((){
      // scrollController.animateTo(1236.0, curve: Curves.bounceIn, duration: Duration(milliseconds: 1000));
      // print(scrollController.position.maxScrollExtent);
      // var minScreen = MediaQuery.of(context).size.width - 70;
      // var scrollValue = scrollController.offset.round();
      // var scrollMax = scrollController.position.maxScrollExtent;
      
      // if(scrollValue < 350){
      //   scrollController.jumpTo(minScreen);
      // }else if(scrollValue < 750 ){
      //   scrollController.jumpTo(minScreen * 2);
      // }else if(scrollValue < 1050 ){
      //   scrollController.jumpTo(minScreen * 3);
      // }else if(scrollValue < 1350 ){
      //   scrollController.jumpTo(minScreen * 4);
      // }

      // scrollController.position.moveTo(750);
      
    });

    super.initState();
  }

  initMethods() {
    //initialize query snapshot to retrieve all products
    FirebaseHandler.popularProducts().then((results) {
      setState(() {
        products = results;
      });
    });

    //Fecth romantic cakes only
    FirebaseHandler.fetchWeddingCakes().then((results) {
      setState(() {
        weddings = results;
      });
    });

    FirebaseHandler.fetchBirhdayCakes().then((results) {
      setState(() {
        try {
          if (results != null) {
            birthdays = results;
          } else {}
        } catch (e) {}
      });
    });

    FirebaseHandler.fetchRomanticCakes().then((results) {
      setState(() {
        try {
          if (results != null) {
            romantics = results;
          } else {}
        } catch (e) {}
      });
    });

    //retrieve recent cakes
    FirebaseHandler.recentCakes().then((results) {
      setState(() {
        recents = results;
      });
    });
  }

  @override
  void dispose() {
    // products.documents.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if(products == null || recents == null || birthdays == null || romantics == null || weddings ==null){
      return Center(child: CircularProgressIndicator());
    }


    return SingleChildScrollView(
      child: new ConstrainedBox(
        constraints: new BoxConstraints(),
        child: new Column(children: <Widget>[
          //Top description of screen for recently baked cakes

          Padding(
            padding: EdgeInsets.all(15.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Recently baked cakes",
                  style: TextStyle(fontSize: 16.0, fontFamily: "Hind-Regular"),
                ),
                InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AdminPart()));
                    },
                    child: Container(
                        //color: Colors.lightBlueAccent,
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(23.0)),
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Text(
                          "VIEW ALL(" + data.length.toString() + ")",
                          style: TextStyle(
                              fontSize: 14.0,
                              fontFamily: "Hind-Regular",
                              color: Colors.white),
                        ))),
              ],
            ),
          ),

          //Horizontal listview to display recently baked cakes

          Container(
            height: 240,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: StreamBuilder(
                  stream: recents,
                  builder: (context, snapshot) {
                    //Check if there's recent cakes
                    if (!snapshot.hasData || snapshot.data.documents == null)
                      return Text("Loading...");
                    if (snapshot.data != null) {
                      return ListView.builder(
                          itemCount: snapshot.data.documents.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          controller: scrollController,
                          itemBuilder: (context, index) => Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      child: Stack(
                                        children: <Widget>[
                                          Container(
                                            height: 210,
                                            width: MediaQuery.of(context).size.width - 60, //160
                                            child: CachedNetworkImage(
                                              imageUrl: snapshot.data.documents[index].data["productURL"],
                                              fit: BoxFit.cover,
                                            ),
                                          ),

                                          //Position of gradient color for product background color
                                          Positioned(
                                            left: 0.0,
                                            bottom: 0.0,
                                            width: MediaQuery.of(context).size.width - 60, //160
                                            height: 210,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                                colors: [
                                                  Colors.black,
                                                  Colors.black.withOpacity(0.0)
                                                ],
                                              )),
                                            ),
                                          ),

                                          //Bottom layout for product details
                                          Positioned(
                                            left: 10.0,
                                            bottom: 10.0,
                                            right: 10.0,
                                            child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: <Widget>[
                                                    Container(
                                                      width: 160,
                                                      child: Text(
                                                        LocalMethods.capitalize(snapshot.data.documents[index].data["name"]),
                                                        style: TextStyle(
                                                            fontWeight:FontWeight.bold,color: Colors.white,
                                                            fontFamily: "Hind-Regular",fontSize: 18.0),
                                                        overflow: TextOverflow.ellipsis, softWrap: true,
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisSize:MainAxisSize.max,
                                                      mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                      children: <Widget>[
                                                        Text(
                                                          data[index].monthYear,
                                                          style: TextStyle( fontWeight:FontWeight.normal,
                                                              color:Colors.white,fontSize: 14.0),
                                                        ),
                                                        
                                                        Container(
                                                          padding: EdgeInsets.symmetric(horizontal:6.0,vertical:2.0),
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape.rectangle,
                                                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                              color: Colors.white),
                                                          child: Text(
                                                              "${snapshot.data.documents[index].data["discount"]}%",
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.normal, color: Colors.black,
                                                                  fontSize:14.0)),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                          )
                                        ],
                                      ),
                                    ),
                                    //Adding new price and old price
                                    Row(
                                      mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        SizedBox(
                                          width: 5.0,
                                        ),
                                        Text(
                                            '\$ ${snapshot.data.documents[index].data["price"]}.00',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontSize: 15.0)),
                                        SizedBox(
                                          width: 5.0,
                                        ),
                                        Text('(\$' +snapshot.data.documents[index].data["oldPrice"] +".00)",
                                            style: TextStyle(decoration: TextDecoration.lineThrough, fontWeight: FontWeight.normal,
                                                color: Colors.grey,
                                                fontSize: 15.0)),
                                      ],
                                    )
                                  ],
                                ),
                              ));
                    }
                  }),
            ),
          ),

          //Body
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Popular cakes",
                  style: TextStyle(fontSize: 16.0, fontFamily: "Hind-Regular"),
                ),
                Text(
                  "see more",
                  style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: "Hind-Regular",
                      color: Colors.blue),
                ),
              ],
            ),
          ),

          //Start popular cakes
          products == null
              ? Text("Loading...")
              : Container(
                  key: Key("popular"),
                  child: GridView.builder(
                    padding: screenWidth < 365
                        ? EdgeInsets.all(0.0)
                        : const EdgeInsets.all(10.0),
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: products.documents.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                          elevation: 0.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Stack(
                                // alignment: Alignment.topLeft,
                                children: <Widget>[
                                  //Add InkWell to allow image expansion when user clicks on it
                                  InkWell(
                                    child: Hero(
                                        tag: index,
                                        child: CachedNetworkImage(
                                          imageUrl: products.documents[index]
                                              .data["productURL"],
                                          width: 400.0,
                                          height:
                                              screenWidth < 365 ? 100 : 120.0,
                                          fit: BoxFit.cover,
                                        )),
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(PageRouteBuilder(
                                              opaque: false,
                                              pageBuilder: (context, _, __) {
                                                return Material(
                                                  color: Colors.black38,
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.all(30.0),
                                                    child: InkWell(
                                                      child: Hero(
                                                        tag: index,
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl:
                                                              products
                                                                      .documents[
                                                                          index]
                                                                      .data[
                                                                  "productURL"],
                                                          width: 300.0,
                                                          height: 300.0,
                                                          alignment:
                                                              Alignment.center,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ),
                                                );
                                              }));
                                    },
                                  ),

                                  //Position discount on top left corner
                                  Positioned(
                                    top: 0.0,
                                    left: 0.0,
                                    child: Container(
                                      padding: EdgeInsets.all(5.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(15.0)),
                                        color: Colors.red.withOpacity(0.7),
                                      ),
                                      child: Text(
                                        "${products.documents[index].data["discount"]} %",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Hind-Regular",
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  //End discount on top left corner

                                  //Start favorite button on top right corner
                                  AddFavorite()
                                  //End favorite button on top right corner
                                ],
                              ),

                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Container(
                                  width: 180,
                                  child: Text(
                                    LocalMethods.capitalize(products.documents[index].data["name"]),
                                    style: TextStyle(
                                        fontSize: screenWidth < 365 ? 15.0 : 13.0,
                                        fontFamily: "Hind-Regular"),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                    '\$ ${products.documents[index].data["price"]}'),
                              ),
                              //Text(data[index].desc),
                              //Row to display add cart and view detail
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    FlatButton.icon(
                                      icon: Icon(
                                        Icons.shopping_cart,
                                        size: screenWidth < 365 ? 15 : null,
                                      ),
                                      label: Text(
                                        "add",
                                        style: TextStyle(
                                            fontSize:
                                                screenWidth < 365 ? 11 : null),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          title = products
                                              .documents[index].data["name"];
                                          //incrementCart();
                                          widget.addProductToCart(index);
                                        });
                                      },
                                      // color: Theme.of(context).primaryColor,
                                    ), //Add to cart button

                                    Expanded(
                                      child: FlatButton.icon(
                                        icon: Icon(
                                          Icons.info_outline,
                                          size: screenWidth < 365 ? 15 : null,
                                        ),
                                        label: Text(
                                          "Detail",
                                          style: TextStyle(
                                              fontSize: screenWidth < 365
                                                  ? 11
                                                  : null),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              new MaterialPageRoute(
                                                  builder: (BuildContext
                                                          context) =>
                                                      DetailsController(
                                                        keyTitle: products.documents[index].data["name"],
                                                        itemId: products
                                                            .documents[index]
                                                            .documentID,
                                                      )));

                                          // for (var item in prodID) {
                                          //   print(item);
                                          // }
                                          //print("Number of products added to history = "+prodID.toString());
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ));
                    },
                  ),
                ),
          //End popular cakes

          Padding(
            padding: EdgeInsets.all(15.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Wedding cakes",
                  style: TextStyle(fontSize: 16.0, fontFamily: "Hind-Regular"),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      keyID = "wedding";
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CategoryDetails(keyID: keyID)));
                    });
                  },
                  child: Text(
                    "see more",
                    style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: "Hind-Regular",
                        color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),

          //Start wedding cakes
          Container(
            height: 280,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: weddings == null
                    ? Text("Loading wedding cakes...")
                    : ListView.builder(
                        itemCount: weddings.documents.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) => Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DetailsController(
                                                  keyTitle: weddings.documents[index].data["name"],
                                                  itemId: weddings
                                                      .documents[index]
                                                      .documentID,
                                                )));
                                  });
                                },
                                child: Card(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        height: 180,
                                        width: 160,
                                        // child: Image.asset(
                                        //   data[index].prodURL,
                                        //   fit: BoxFit.cover,
                                        child: Hero(
                                          tag: "$keyID$index",
                                          child: new CachedNetworkImage(
                                            imageUrl: weddings.documents[index]
                                                .data["productURL"],
                                            placeholder:
                                                new CircularProgressIndicator(),
                                            errorWidget: new Icon(
                                              Icons.error,
                                              color: Colors.red,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 9.0),
                                        width: 160,
                                        child: Text(
                                          LocalMethods.capitalize(weddings.documents[index].data["name"]),
                                          //cake name
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        width: 160,
                                        child: Text(
                                          "${weddings.documents[index].data["price"]}\$",
                                          style: TextStyle(color: Colors.black),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5.0,
                                                    vertical: 2.0),
                                                decoration: BoxDecoration(
                                                    color: Colors.brown
                                                        .withOpacity(0.8),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            bottomLeft:
                                                                Radius
                                                                    .elliptical(
                                                                        20.0,
                                                                        10.0),
                                                            topRight: Radius
                                                                .elliptical(
                                                                    20.0,
                                                                    20.0))),
                                                child: Text(
                                                  "4.5",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                            Icon(
                                              Icons.star,
                                              color: Colors.yellow,
                                            ),
                                            SizedBox(
                                              width: 60,
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 4.0,
                                                  vertical: 2.0),
                                              decoration: BoxDecoration(
                                                  color: Colors.red
                                                      .withOpacity(0.8),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.elliptical(
                                                                  20.0, 10.0),
                                                          bottomRight:
                                                              Radius.elliptical(
                                                                  20.0, 10.0))),
                                              child: Text(
                                                "${weddings.documents[index].data["discount"]}%",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                      )),
          ),
          //End wedding cakes

          //Start Birthday cakes
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Birthday cakes",
                  style: TextStyle(fontSize: 16.0, fontFamily: "Hind-Regular"),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      keyID = "birthday";
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CategoryDetails(keyID: keyID)));
                    });
                  },
                  child: Text(
                    "see more",
                    style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: "Hind-Regular",
                        color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: 280,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: birthdays == null
                    ? Text("Loading birthday cakes...")
                    : ListView.builder(
                        itemCount: birthdays.documents.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) => Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DetailsController(
                                                  itemId: birthdays
                                                      .documents[index]
                                                      .documentID,
                                                  keyTitle: birthdays.documents[index].data["name"],
                                                )));
                                  });
                                },
                                child: Card(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        height: 180,
                                        width: 160,
                                        child: CachedNetworkImage(
                                          imageUrl: birthdays.documents[index]
                                              .data["productURL"],
                                          placeholder:
                                              CircularProgressIndicator(),
                                          errorWidget: Icon(Icons.error,
                                              color: Colors.red),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 9.0),
                                        child: Text(
                                          LocalMethods.capitalize(birthdays.documents[index].data["name"]),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          "${birthdays.documents[index].data["price"]}\$",
                                          style: TextStyle(color: Colors.black),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5.0,
                                                    vertical: 2.0),
                                                decoration: BoxDecoration(
                                                    color: Colors.brown
                                                        .withOpacity(0.8),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            bottomLeft:
                                                                Radius
                                                                    .elliptical(
                                                                        20.0,
                                                                        10.0),
                                                            topRight: Radius
                                                                .elliptical(
                                                                    20.0,
                                                                    20.0))),
                                                child: Text(
                                                  "4.5",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                            Icon(
                                              Icons.star,
                                              color: Colors.yellow,
                                            ),
                                            SizedBox(
                                              width: 60,
                                            ),
                                            Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 4.0,
                                                    vertical: 2.0),
                                                decoration: BoxDecoration(
                                                    color: Colors.red
                                                        .withOpacity(0.8),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft:
                                                                Radius
                                                                    .elliptical(
                                                                        20.0,
                                                                        10.0),
                                                            bottomRight: Radius
                                                                .elliptical(
                                                                    20.0,
                                                                    10.0))),
                                                child: Text(
                                                  "${birthdays.documents[index].data["discount"]}%",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ))
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                      )),
          ),
          //End Birthday cakes

          //Start Romantic cakes
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Romantic cakes",
                  style: TextStyle(fontSize: 16.0, fontFamily: "Hind-Regular"),
                ),
                InkWell(
                    onTap: () {
                      setState(() {
                        keyID = "romantic";
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CategoryDetails(keyID: keyID)));
                      });
                    },
                    child: Text(
                      "see more",
                      style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: "Hind-Regular",
                          color: Colors.blue),
                    )),
              ],
            ),
          ),

          Container(
            height: 280,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: romantics == null
                    ? Text("Loading...")
                    : ListView.builder(
                        itemCount: romantics.documents.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) => Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DetailsController(
                                                  itemId: romantics
                                                      .documents[index]
                                                      .documentID,
                                                  keyTitle: romantics.documents[index].data["name"],
                                                )));
                                  });
                                },
                                child: Card(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                          height: 180,
                                          width: 160,
                                          child: CachedNetworkImage(
                                            imageUrl: romantics.documents[index]
                                                .data["productURL"],
                                            errorWidget: Icon(Icons.error),
                                            fit: BoxFit.cover,
                                          )),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 9.0),
                                        width: 160,
                                        child: Text(
                                          LocalMethods.capitalize(romantics.documents[index].data["name"]),
                                          style: TextStyle(color: Colors.black),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          romantics
                                              .documents[index].data["price"],
                                          style: TextStyle(color: Colors.black),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5.0,
                                                    vertical: 2.0),
                                                decoration: BoxDecoration(
                                                    color: Colors.brown
                                                        .withOpacity(0.8),
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            bottomLeft:
                                                                Radius
                                                                    .elliptical(
                                                                        20.0,
                                                                        10.0),
                                                            topRight: Radius
                                                                .elliptical(
                                                                    20.0,
                                                                    20.0))),
                                                child: Text(
                                                  "4.5",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                            Icon(
                                              Icons.star,
                                              color: Colors.yellow,
                                            ),
                                            SizedBox(
                                              width: 60,
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 4.0,
                                                  vertical: 2.0),
                                              decoration: BoxDecoration(
                                                  color: Colors.red
                                                      .withOpacity(0.8),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.elliptical(
                                                                  20.0, 10.0),
                                                          bottomRight:
                                                              Radius.elliptical(
                                                                  20.0, 10.0))),
                                              child: Text(
                                                "${romantics.documents[index].data["discount"]} %",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                      )),
          ),
          //End Romantic cakes
        ]),
      ),
    );
  }
}
