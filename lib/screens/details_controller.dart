import 'dart:async';

import 'package:birthcake_bakers/database/database_handler.dart';
import 'package:birthcake_bakers/models/local_methods.dart';
import 'package:birthcake_bakers/screens/cart_history.dart';
import 'package:birthcake_bakers/tools/firebase_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:birthcake_bakers/models/products_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeAgo;
// import 'package:intl/intl.dart';
  

class DetailsController extends StatefulWidget {
  final  keyTitle;
  final String itemId;
  DetailsController({this.keyTitle, this.itemId});
  @override
  _DetailsControllerState createState() => _DetailsControllerState();
}

class _DetailsControllerState extends State<DetailsController> {
  int counter = 0, favCounter = 0;
  bool isfavorite = false,
      isExisted = false,
      isSmall = false,
      isMedium = false,
      isLarge = false;
  bool hasReview = true, userHasReviewed;//hasReview, check if the item has review
  var itemName, itemId, resultDetails, favoriteItems, numberOfReviews, retrieveAllReviews;
  var  productName = "", productDescription ="", productDiscount, productPrice, 
        productOldPrice, productImage ="", productFavored;

  var defaultImage = "https://firebasestorage.googleapis.com/v0/b/cakeapp-a3433.appspot.com/o/product_images%2F_img1549280911979456?alt=media&token=335469f8-2a5f-4abe-b484-7406fd70b065";

  //Firebase variables
  DocumentSnapshot documentSnapshot;
  var userDetailsReview, duplicates, snapshotReviews;
  QuerySnapshot getItemDetailBySearch;//holds name and profile of current user

  List<Model> detailProduct = new List<Model>();
  Map<String, dynamic> reviews = new Map<String, dynamic>();
  Map<String, dynamic> favorites = new Map<String, dynamic>();
  List<String> loader = new List<String>();
  String userID, reviewTxt, userProfile, userName;

  TextEditingController reviewController = TextEditingController();

  //Variables for sqflite, favorite button
  SharedPreferences preferences;
  GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();
  ProductDatabase pdb;

  //End variables declaration

  Future<List<String>> loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> visit = prefs.getStringList("Favorites");

    return visit;
  }

  @override
  void dispose() {
    // pdb.closeDB();
    super.dispose();
  }

  @override
  void initState() {
    itemId = widget.itemId;
    itemName = widget.keyTitle;

    pdb = ProductDatabase();
    pdb.retrieveItem("$itemId").then((value) {
      setState(() {
        try {
          isfavorite = value.favored;
        } catch (e) {
          // print(e);
        }
      });
    });

    //Retrieve item details from firestore
    initDetails();

    //Retrieve user review id

    super.initState();
  }

  initDetails() {
      FirebaseHandler.singleItemDetails(itemId).then((results) {
        setState(() {
          documentSnapshot = results;
        });
      });
    
    
    //Get current user ID
    FirebaseAuth.instance.currentUser().then((user) {
      setState(() {
        userID = user.uid;

      });
    });

    //Get recent reviews
    FirebaseHandler.latestReviews(itemId).then((latest){
      setState(() {
        snapshotReviews = latest; 
      });
    });

    //Get current user details to add to his review
    FirebaseHandler.currentUserDetails(userID).then((details){
      setState(() {
          userDetailsReview = details;
        
          userProfile = userDetailsReview.documents[0].data["profilePic"];
          userName = userDetailsReview.documents[0].data["firstname"];
        
      });
    });

    //check for duplicates before inputting reviews
    FirebaseHandler.doesUserAlreadyRewiew(userID, itemId).then((valid){
      setState(() {
        userHasReviewed = valid;
      });
    });

    //check if item has already been reviewed, if it exists in review table
    FirebaseHandler.doesItemAlreadyReviewed(itemId).then((exists){
      setState(() {
          hasReview = exists;
      });
    });

    FirebaseHandler.sizeOfReviews(itemId).then((length){
      setState(() {
        numberOfReviews = length;
      });
    });

    FirebaseHandler.getAllReviews(itemId).then((results){
      setState(() {
        retrieveAllReviews = results; 
      });
    });

    // //load favorite
    // FirebaseHandler.itemAlreadyFavored(userID,itemId).then((isfavored){
    //   setState(() {
    //    isfavorite= isfavored; 

    //    print(isfavorite);
    //   });
    // });
  }
  

  initVariables(){
    setState(() {
      if (documentSnapshot != null) {
          productName = documentSnapshot.data["name"];
          productDescription = documentSnapshot.data["description"];
          productDiscount = documentSnapshot.data["discount"];
          productPrice = documentSnapshot.data["price"];
          productOldPrice = documentSnapshot.data["oldPrice"];
          productImage = documentSnapshot.data["productURL"];
          // isfavorite = documentSnapshot.data["isfavored"];
          // productFavored = documentSnapshot.data["isfavored"];
        }
    });
  }

  String capitalizeFirstLetters(String letters){
    return letters[0].toUpperCase() + letters.substring(1);
  }

  //Remove product to cart. this method is called and executed in cart history
  void removeToCart() {
    setState(() {
      counter--;
      //print("Item $incrementer removed from cart");
    });
  }

  Widget verifyBadge() {
    //setState(() {
    if (counter > 0) {
      return new CircleAvatar(
        radius: 10.0,
        backgroundColor: Colors.red,
        child: new Text(
          counter.toString(),
          style: new TextStyle(color: Colors.white, fontSize: 12.0),
        ),
      );
    } else {
      return Container();
    }
    //});
  }
  

  Widget noReviewToDisplay (){
    if(!hasReview)
      return Text("No review yet");
    else
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    Icon favoriteIcon = Icon(Icons.favorite);
    Icon borderFavorite = Icon(Icons.favorite_border);
    // var index = widget.keyTitle;
    initVariables();

    if(documentSnapshot ==null || snapshotReviews ==null || numberOfReviews ==null || userDetailsReview ==null){
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    void moreBadge() {
      // setState(() {
      //   counter = 1;
      //   detailProduct.add(
      //     Model(
      //         name: data[index].name,
      //         price: data[index].price,
      //         desc: data[index].desc,
      //         prodURL: data[index].prodURL,
      //         monthYear: data[index].monthYear,
      //         discount: data[index].discount,
      //         oldPrice: data[index].oldPrice,
      //         quantity: quantity),
      //   );

      //   //Check if the product has been successfully added
      //   //To avoid duplicate
      //   for (var i = 0; i < detailProduct.length; i++) {
      //     bool distinct = false;
      //     for (var j = 0; j < i; j++) {
      //       if (detailProduct[i].name == detailProduct[j].name) {
      //         distinct = true;
      //         detailProduct.removeAt(i);
      //         break;
      //       }
      //     }

      //     if (!distinct) {}
      //   }
      // });
    }

    final addToCart = Padding(
        padding: EdgeInsets.fromLTRB(8.0, 7.0, 8.0, 7.0),
        child: Material(
          elevation: 7.0,
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          child: MaterialButton(
            onPressed: () {
              moreBadge();
            },
            child: Text(
              "Add to cart",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0),
            ),
            height: 50.0,
            elevation: 8.0,
          ),
        ));

    return Scaffold(
      key: scaffoldkey,
      //Check if documentSnapshot is not null, if true return a loading text as body
      body: CustomScrollView(
              primary: true,
              slivers: <Widget>[
               
                //App bar with two icons : favorite and cart
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  automaticallyImplyLeading: true,
                  expandedHeight: 300.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Hero(
                      tag: productName,
                      child: CachedNetworkImage(
                        imageUrl: productImage != null ? productImage : defaultImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                    collapseMode: CollapseMode.parallax,
                    title: Container(
                      width: 200,
                      child: Text(LocalMethods.capitalize(productName),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    centerTitle: false,
                  ),
                  // title: Text("Product is busy"),

                  actions: <Widget>[
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isfavorite = true;
                          favCounter++;

                          if (favCounter == 2) {
                            isfavorite = false;
                            favCounter = 0;
                          }

                          //If product is favoured, add it to sqlite database
                          if (isfavorite) {
                            pdb.addProductToFavorites(Model(
                                id: "$itemId",
                                name: productName,
                                price: double.parse(productPrice),
                                prodURL: productImage,
                                favored: true
                                )).then((added){
                                  scaffoldkey.currentState.showSnackBar(SnackBar(
                                    content: Text("$productName added to wishlist")
                                  ));
                                });
                          }

                          //else delete the item
                          if (!isfavorite) {
                            pdb.deleteProduct("$itemId").then((deleted){
                              scaffoldkey.currentState.showSnackBar(SnackBar(
                                    content: Text("$productName deleted to wishlist"),
                                  ));
                            });
                          }

                          //Check if product is favored to firestore database
                          // favorites = {
                          //   "favoredID" : itemId,
                          //   "favoredName" : productName,
                          //   "favoredURL" : productImage,
                          //   "favoredPrice" : productPrice,
                          //   "favoredUser" : userID,
                          //   "isfavored": true
                          // };
                          
                          // if(!isfavorite){ //if user has already favored the item
                          //   FirebaseHandler.addWishlist(favorites).then((values){
                          //     scaffoldkey.currentState.showSnackBar(SnackBar(
                          //       content: Text("$productName added to wishlist"),
                          //     ));
                          //   });
                          // }       

                                           
                        });
                      },
                      icon: isfavorite ? favoriteIcon : borderFavorite,
                    ),
                    new Stack(
                      alignment: Alignment.topRight,
                      children: <Widget>[
                        new IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CartHistory(
                                          productID:detailProduct, decreaseCartCounter: removeToCart, showAppBar: true)));
                            },
                            icon: Icon(Icons.add_shopping_cart)),
                        //Verify if add to cart button is pressed, and display the badge counter
                        verifyBadge()
                      ],
                    ), //End of icons
                  ],
                ), //End of app bar

                //Body
                SliverList(
                  delegate: SliverChildListDelegate(<Widget>[
                    //Card for product details
                    SizedBox(
                      height: 20,
                    ),
                    Card(
                      elevation: 6.0,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            //Start First Column for product name, status and rating stars
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(LocalMethods.capitalize(productName),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "Hind-Regular",
                                      fontWeight: FontWeight.bold),
                                ),
                                Text("Available",
                                    style:
                                        TextStyle(fontStyle: FontStyle.italic)),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.star,
                                      color: Colors.yellowAccent,
                                      size: 25,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: Colors.yellowAccent,
                                      size: 25,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: Colors.yellowAccent,
                                      size: 25,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: Colors.yellowAccent,
                                      size: 25,
                                    ),
                                    Icon(
                                      Icons.star_half,
                                      color: Colors.yellowAccent,
                                      size: 25,
                                    ),
                                    SizedBox(width: 30.0),
                                    Text(
                                      "4.8",
                                      style: TextStyle(fontSize: 15.0),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            //End First Column for product name, status and rating stars

                            //Start Second Column for product name, status and rating stars
                            //price
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(20.0)),
                                  ),
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                      "$productDiscount % Off",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ),

                                //Item discount
                                Text(
                                  "\$ $productOldPrice",
                                  style: TextStyle(
                                      decoration: TextDecoration.lineThrough),
                                ),

                                //Item price
                                Text(
                                  "\$ $productPrice",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )

                            //End Second Column for product name, status and rating stars
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 10,
                    ),

                    Card(
                      elevation: 6.0,
                      child: Container(
                        height: 240,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ListView.builder(
                              itemCount: 4,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) => Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: CachedNetworkImage(
                                      imageUrl: productImage != null ? productImage : defaultImage,
                                      fit: BoxFit.cover,
                                      width: 180,
                                    ),
                                  )),
                        ),
                      ),
                    ),

                    //Start Card for product description
                    Card(
                      elevation: 6.0,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Description",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: "Hind-Regular"),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            //Description goes here
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(productDescription,
                                 softWrap: true, overflow: TextOverflow.clip, textAlign: TextAlign.justify,),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    //End card for product description

                    //Start Card for size and quantity
                    Card(
                      elevation: 6.0,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Sizes",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: "Hind-Regular"),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isSmall = !isSmall;

                                      if (isSmall) {
                                        isMedium = false;
                                        isLarge = false;
                                      }
                                    });
                                  },
                                  child: Chip(
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.padded,
                                    label: Text("Small"),
                                    avatar: CircleAvatar(
                                      backgroundColor:
                                          isSmall ? Colors.redAccent : null,
                                      child: Container(
                                        child: isSmall
                                            ? Icon(Icons.check)
                                            : Text("S"),
                                      ),
                                    ),
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isMedium = !isMedium;

                                      if (isMedium) {
                                        isSmall = false;
                                        isLarge = false;
                                      }
                                    });
                                  },
                                  child: Chip(
                                    label: Text("Medium"),
                                    avatar: CircleAvatar(
                                      backgroundColor:
                                          isMedium ? Colors.redAccent : null,
                                      child: Container(
                                        child: isMedium
                                            ? Icon(Icons.check)
                                            : Text("M"),
                                      ),
                                    ),
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isLarge = !isLarge;

                                      if (isLarge) {
                                        isSmall = false;
                                        isMedium = false;
                                      }
                                    });
                                  },
                                  child: Chip(
                                    label: Text("Large"),
                                    avatar: CircleAvatar(
                                      backgroundColor:
                                          isLarge ? Colors.redAccent : null,
                                      child: Container(
                                        child: isLarge
                                            ? Icon(Icons.check)
                                            : Text("L"),
                                      ),
                                    ),
                                  ),
                                ),
                                //End of chips size
                              ],
                            ), //End of row chips size

                            //Start quantity increase and decrease
                            SizedBox(
                              height: 10,
                            ),

                            Divider(
                              indent: 10.0,
                              height: 6.0,
                              color: Colors.black45,
                            ),

                            SizedBox(
                              height: 10,
                            ),

                            Text(
                              "Quantity",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: "Hind-Regular"),
                            ),

                            SizedBox(
                              height: 10,
                            ),

                            IncreasedQuantity(),
                            //End quantity increase and decrease
                          ],
                        ),
                      ),
                    ),
                    //End size and quantity card

                    //Start product reviews

                    Card(
                      elevation: 6.0,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top : 10.0, left: 8.0),
                              child: Text(
                                "Reviews",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: "Hind-Regular"),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),

                            //row which will take two columns one for review and one for stars
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal : 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  //Column for rating bar ids
                                  Column(
                                    children: <Widget>[
                                      Text("5"),
                                      SizedBox(
                                        height: 7,
                                      ),
                                      Text("4"),
                                      SizedBox(
                                        height: 7,
                                      ),
                                      Text("3"),
                                      SizedBox(
                                        height: 7,
                                      ),
                                      Text("2"),
                                      SizedBox(
                                        height: 7,
                                      ),
                                      Text("1"),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  //End column for ids
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        height: 20,
                                        width: 170,
                                        key: Key("1"),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            color: Colors.cyanAccent[700]),
                                      ),
                                      Container(
                                        height: 20,
                                        width: 150,
                                        margin: EdgeInsets.only(top: 5.0),
                                        key: Key("2"),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            color: Colors.teal),
                                      ),
                                      Container(
                                        height: 20,
                                        width: 120,
                                        margin: EdgeInsets.only(top: 5.0),
                                        key: Key("3"),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            color: Colors.yellow),
                                      ),
                                      Container(
                                        height: 20,
                                        width: 80,
                                        margin: EdgeInsets.only(top: 5.0),
                                        key: Key("4"),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            color: Colors.orangeAccent[400]),
                                      ),
                                      Container(
                                        height: 20,
                                        width: 30,
                                        margin: EdgeInsets.only(top: 5.0),
                                        key: Key("5"),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            color: Colors.red[600]),
                                      ),
                                    ],
                                  ),
                                  
                                  //Start Big rating bar text
                                  Expanded(
                                    flex: 8,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text("4.8",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            starsRating(),
                                          ],
                                        ),

                                        //Row containing icon and text
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(Icons.supervisor_account),
                                            SizedBox(width: 10,),
                                            
                                            StreamBuilder(
                                              stream: numberOfReviews,
                                              builder: (context, snapshot) {
                                                if(!snapshot.hasData || snapshot.data.documents == null) return Text("Loading...");
                                                if (snapshot.data != null) { 
                                                  return Text("${snapshot.data.documents.length} total", style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold
                                                  ),);
                                                }
                                              }
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                  //End Big rating bar text
                                ],
                              ),
                            ), //end rating row

                            //Start rating users list
                            SizedBox(
                              height: 20,
                            ),

                            //Start Container for recent reviews
                            Container(
                              alignment: Alignment.center,
                              child: Text(
                                "Recent Reviews Highlights",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontFamily: "Hind-Regular"),
                              ),
                            ),
                            //End Row for recent reviews
                            Column(
                              children: <Widget>[
                                //If there's no review return a text else return list of reviews
                               noReviewToDisplay(),

                               StreamBuilder(
                                  stream: snapshotReviews,
                                  builder: (context, snapshot) {
                                    if(!snapshot.hasData || snapshot.data.documents == null) return Text("Loading...");
                                    if (snapshot.data != null) { 
                                    return  ListView.builder(
                                            physics: ClampingScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: snapshot.data.documents.length,
                                            itemBuilder: (context, index) {
                                              return ListTile(
                                                leading: CircleAvatar(
                                                  radius: 30,
                                                  minRadius: 25,
                                                  backgroundImage: CachedNetworkImageProvider(
                                                    snapshot.data.documents[index].data["userProfile"],
                                                  ),
                                                ),
                                                title: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: <Widget>[
                                                    Container(
                                                      width: 150,
                                                      child: Text(
                                                        LocalMethods.capitalize(snapshot.data.documents[index].data["username"]),
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black),
                                                        softWrap: true,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),

                                                    Text("${timeAgo.format(snapshot.data.documents[index].data["timeStamp"])}",
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontStyle:
                                                                FontStyle.italic)),
                                                  ],
                                                ),
                                                subtitle: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: <Widget>[
                                                    Text(snapshot.data.documents[index].data["reviewsTxt"],
                                                    style: TextStyle(), maxLines: 2,),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    starsRating(),
                                                    Divider(),

                                                    SizedBox(
                                                      height: 15,
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                    }
                                  }
                                ),
                                    

                                //Start More button
                                Container(
                                  margin: EdgeInsets.only(top: 8.0),
                                  alignment: Alignment.center,
                                  child: FlatButton.icon(
                                    label: Text("Read more"),
                                    icon: Icon(Icons.keyboard_arrow_down),
                                    onPressed: () {
                                      //If there's no reviews for the product, return null
                                      if(!hasReview) return null;
                                      //Open bottom sheet to display all reviews
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context){
                                          return Container(
                                            // height: MediaQuery.of(context).size.height / 2,
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                  padding: EdgeInsets.all(8.0),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.rectangle,
                                                    color: Theme.of(context).accentColor
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.max,
                                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                    children: <Widget>[
                                                    Icon(Icons.clear, size:35, color: Colors.white,),
                                                    Container(
                                                      width: MediaQuery.of(context).size.width - 300,
                                                      child: Text(LocalMethods.capitalize(productName), style: TextStyle(
                                                        color: Colors.white, 
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: "Hind-Regular",
                                                         fontSize: 18
                                                      ),
                                                      overflow: TextOverflow.clip,
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),

                                                    starsRating()
                                                  ],
                                              ),
                                             ),

                                              Expanded(
                                                flex: 8,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                                  child: StreamBuilder(
                                                    stream: retrieveAllReviews,
                                                    builder: (context, snapshot) {
                                                      if(!snapshot.hasData || snapshot.data.documents == null) return CircularProgressIndicator();
                                                      if(snapshot.hasData){
                                                          return ListView.builder(
                                                          shrinkWrap: true,
                                                          itemCount: snapshot.data.documents.length,
                                                          itemBuilder: (context, index){
                                                            return ListTile(
                                                                leading: CircleAvatar(
                                                                radius: 35,
                                                                backgroundImage: CachedNetworkImageProvider(
                                                                  snapshot.data.documents[index].data["userProfile"],
                                                                ),
                                                              ),
                                                              title: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                mainAxisSize: MainAxisSize.max,
                                                                children: <Widget>[
                                                                  Container(
                                                                    width: 160,
                                                                    child: Text(
                                                                      LocalMethods.capitalize(snapshot.data.documents[index].data["username"]),
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color: Colors.black),
                                                                      softWrap: true,
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),

                                                                  Text("${timeAgo.format(snapshot.data.documents[index].data["timeStamp"])}",
                                                                      style: TextStyle(
                                                                          color: Colors.grey,
                                                                          fontStyle:
                                                                              FontStyle.italic)),
                                                                ],
                                                              ),
                                                              subtitle: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                mainAxisSize: MainAxisSize.max,
                                                                children: <Widget>[
                                                                  Text(snapshot.data.documents[index].data["reviewsTxt"],
                                                                  style: TextStyle(), maxLines: 3,),
                                                                  SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  starsRating(),

                                                                  SizedBox(
                                                                    height: 15,
                                                                  )
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      }
                                                     
                                                    }
                                                  ),
                                                ),
                                              )

                                              ],
                                            ),
                                          );
                                        }
                                      );
                                    },
                                  ),
                                ),
                                //End More button

                                //start enter your review for this product
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      Flexible(
                                        child: TextField(
                                          controller: reviewController,
                                          maxLines: 3,
                                          onChanged: (text) {
                                            setState(() {
                                              reviewTxt = text;
                                            });
                                          },
                                          decoration: InputDecoration(
                                            hasFloatingPlaceholder: true,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10.0)
                                            ),
                                            hintText:
                                                 "Enter your review for this cake",
                                            filled: true,
                                            suffix: InkWell(
                                        onTap: () {
                                          setState(() {
                                            //add review
                                            reviews = {
                                              "productID": itemId,
                                              "reviewsTxt": reviewTxt,
                                              "timeStamp": DateTime.now(),
                                              "userID" : userID,
                                              "username" : userName,
                                              "userProfile" : userProfile
                                            };
                                          });
                                          
                                          //Verify first if the user has already written a review for this item
                                          //if true, allow user to write else toast a popup
                                          if (userHasReviewed) {
                                            scaffoldkey.currentState.showSnackBar(SnackBar(
                                              content: Text("Sorry, you have already reviewed $productName"),));

                                              //clear the text field
                                              reviewController.clear();
                                          } else {
                                            //validate review if text is not empty
                                            if(reviewTxt.isNotEmpty){
                                                  FirebaseHandler.writeReview(reviews)
                                                  .then((values) {
                                                setState(() {
                                                  reviewController.clear();
                                                  hasReview = true; //Make no review text disappear
                                                  print("Sent");
                                                });
                                              });
                                            }
                                         }
                                        },
                                        child: Icon(Icons.send),
                                      )
                                          ),
                                        ),
                                      ),
                                      
                                    ],
                                  ),
                                )
                                //end entery your review for this product
                              ],
                            )
                            //End rating users list
                          ],
                        ),
                      ),
                    ), //End Reviews card

                    //Start add to cart button
                    addToCart
                    //End add to cart button
                  ]),
                )
              ],
            ),
    );
  }

  Container starsRating() {
    return Container(
            height: 30,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child : ListView.builder(
                  itemCount: 5,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => 
                  Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.0),
                         child: Icon(Icons.star, color: Colors.yellowAccent,)
                  )
               )
             )   
          );
  }
}

class IncreasedQuantity extends StatefulWidget {
  @override
  _IncreasedQuantityState createState() => _IncreasedQuantityState();
}

class _IncreasedQuantityState extends State<IncreasedQuantity> {
  var quantity = 1;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        CircleAvatar(
          child: GestureDetector(
            child: Icon(Icons.remove),
            onTap: () {
              setState(() {
                if(quantity > 1)
                  quantity--;
              });
            },
          ),
        ),

        //Quantity text below
        Text(
          "$quantity",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),

        CircleAvatar(
          child: GestureDetector(
            child: Icon(Icons.add),
            onTap: () {
              setState(() {
                if(quantity < 3)
                  quantity++;
              });
            },
          ),
        ),
      ],
    );
  }
}
