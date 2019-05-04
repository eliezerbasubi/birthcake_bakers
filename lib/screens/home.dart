import 'package:birthcake_bakers/database/database_handler.dart';
import 'package:birthcake_bakers/models/products_model.dart';
import 'package:birthcake_bakers/screens/cart_history.dart';
import 'package:birthcake_bakers/chat/custom_chat.dart';
import 'package:birthcake_bakers/screens/favorites_cakes.dart';
import 'package:birthcake_bakers/screens/homepage.dart';
import 'package:birthcake_bakers/screens/login.dart';
import 'package:birthcake_bakers/screens/search_product.dart';
import 'package:birthcake_bakers/screens/user_profile.dart';
import 'package:birthcake_bakers/tools/firebase_methods.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// import 'package:birthcake_bakers/screens/data_search.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  // AnimationController _animationController;
  String title,appTitle = "Products", userID="", username ="", userEmail ="", userPicture ="";
  int incrementer = 0;
  List<Model> prodID = new List<Model>();
  List<Model> cartList = new List<Model>();

  List<String> popupMenu = new List<String>();
  bool distinct, isfavorite = false, showDefaultDrawer = false;
  int _currentIndex = 0;

  QuerySnapshot products, currentUserAccount;
  ProductDatabase productDatabase;

  @override
  void initState() {
    super.initState();
    productDatabase =ProductDatabase();

    productDatabase.initDB();
   
    initMethods();
    initDBComponents();
  }

  void initDBComponents() async{
    try {
      cartList =await productDatabase.getProductsInCart();
      
      setState(() {
        incrementer = cartList.length;
      });
    } catch (e) {
    }
  }

  initMethods(){
    //  _animationController = new AnimationController(vsync: this, duration: Duration(milliseconds: 800));

    showDefaultDrawer = true;
    popupMenu = ["Profile", "Settings", "Logout"];

    //initialize product database
    productDatabase =ProductDatabase();

    FirebaseHandler.popularProducts().then((results){
      setState(() {
        products = results;
        
        if(products != null){}
      });
    });

    //Get current user details
    FirebaseAuth.instance.currentUser().then((userInfo){
      setState(() {
       userID = userInfo.uid; 

       FirebaseHandler.getUserInfo(userID).then((results){
          setState(() {
            currentUserAccount = results;
          });
        });
      });
    });
  }

  void incrementCart() {
    setState(() {
      incrementer++;
    });
  }

  //Remove product to cart. this method is called and executed in cart history
  void removeToCart() {
    setState(() {
      incrementer--;
      //print("Item $incrementer removed from cart");
    });
  }

  ///Check if user has added a product to cart
  Widget verifyBadge() {
    //setState(() {
    if (incrementer > 0) {
      return new CircleAvatar(
        radius: 10.0,
        backgroundColor: Colors.red,
        child: new Text(
          incrementer.toString(),
          style: new TextStyle(
              color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return Container();
    }
    //});
  }

  void addProductToCart(index){
    productDatabase.addToCart(
      Model(
        id: products.documents[index].documentID,
        name: products.documents[index].data["name"],
        price: double.parse(products.documents[index].data["price"]),
        prodURL: products.documents[index].data["productURL"],
        quantity: 1,
        discount: double.parse(products.documents[index].data["discount"])
      )
    ).then((result){
      incrementCart();
    });
  }
  
   checkForEmptyFields(){
    // setState(() {
     if(currentUserAccount != null){
       username =currentUserAccount.documents[0].data["firstname"];
       userEmail =currentUserAccount.documents[0].data["email"];
       userPicture =currentUserAccount.documents[0].data["profilePic"];
     }
      
    // });
  }

  @override
  Widget build(BuildContext context) {
    // incrementer = cartList.length;

    checkForEmptyFields();

    final searchIcon = IconButton(
        onPressed: () {
          // showSearch(
          //   context: context,
          //   delegate: DataSearch(),
          // );
          setState(() {
           Navigator.push(context,MaterialPageRoute(builder: (context) => SearchProduct()));
          });
        },
        icon: Icon(Icons.search));

    final cartIcon = new Stack(
      alignment: Alignment.topRight,
      children: <Widget>[
        IconButton(
          onPressed: () {
            // Send to cart history
            // if (incrementer > 0) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CartHistory(productID:prodID, decreaseCartCounter: removeToCart, showAppBar: true)));
            // }
          },
          icon: Icon(
            Icons.shopping_cart,
            color: Colors.white,
          ),
          //Badge count will be here
        ),
        //Verify if shopping cart has a product
        verifyBadge()
      ],
    );

    final tabPages = [
      //Start widget one for Home
      HomePage(addProductToCart: addProductToCart),
      //End wiget one for Home

      //Start Widget Two for contaner
      Favorites(),
      //End widget Two

      //Start widget Three
      Container(
          child: incrementer == 0
              ? Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Image.asset("images/empty.png", width: 85, height: 85, fit:BoxFit.cover),
                      Text("No product added to Shopping cart"),
                      Text("Click on home to see products")
                    ],
                  ),
                )
              : CartHistory(productID:prodID, decreaseCartCounter : removeToCart, showAppBar : false)),
      //End widget Three

      //Start widget Four
      Profile()
      //End widget Four
    ];

    return Scaffold(
        appBar: AppBar(
          title: Text(appTitle),
          elevation: 7.0,
          actions: <Widget>[
            searchIcon,
            cartIcon,
            PopupMenuButton<String>(
              onSelected: (String item) {
                if (item == popupMenu[0]) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Profile()));
                }

                if (item == popupMenu[1]) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ChatWindow()));
                }

                if (item == popupMenu[2]) {
                  FirebaseAuth.instance.signOut().then((out){
                    setState(() {
                      Navigator.pop(context);
                      Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Login())); 
                    });
                  });
                }
              },
              itemBuilder: (context) {
                return popupMenu.map((String menuItems) {
                  return PopupMenuItem<String>(
                    child: Text(menuItems),
                    value: menuItems,
                  );
                }).toList();
              },
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
            )
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  radius: 45,
                  backgroundImage: CachedNetworkImageProvider(userPicture),
                ),
                accountName: Text(username),
                accountEmail: Text(userEmail),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("images/runner.png"),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.srgbToLinearGamma()
                        )),
                onDetailsPressed: () {
                  setState(() {
                    // showDefaultDrawer = !showDefaultDrawer;
                    // _animationController.forward();
                  });
                },
                otherAccountsPictures: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      "F",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  CircleAvatar(
                    child: Icon(Icons.track_changes),
                    backgroundColor: Colors.green,
                  ),
                  CircleAvatar(child: Text("P"), backgroundColor: Colors.red),
                ],
              ),
              
              //  !showDefaultDrawer ? 
               ListView(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  children: <Widget>[
                    InkWell(
                      onTap: (){
                        setState(() {
                         Navigator.push(context, CupertinoPageRoute(
                           builder: (context)=> CartHistory(productID:prodID, decreaseCartCounter : removeToCart, showAppBar : true)
                         ));
                        });
                      },
                      child: ListTile(
                        leading: Icon(Icons.local_grocery_store),
                        title: Text("Shopping Cart"),
                        trailing: Container(
                            padding: EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            child: Text(
                              "$incrementer",
                              style: TextStyle(color: Colors.white),
                            )),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.local_shipping),
                      title: Text("Orders"),
                    ),
                    ListTile(
                      leading: Icon(Icons.monetization_on),
                      title: Text("Transactions"),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatWindow()));
                      },
                      child: ListTile(
                        leading: Icon(Icons.message),
                        title: Text("Messages"),
                        trailing: Container(
                            padding: EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            child: Text(
                              "$incrementer",
                              style: TextStyle(color: Colors.white),
                            )),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.notifications),
                      title: Text("Notifications"),
                      trailing: Container(
                          padding: EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: Text(
                            "$incrementer",
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                    ListTile(
                      leading: Transform.rotate(
                          angle: 45, child: Icon(Icons.credit_card)),
                      title: Text("Payments"),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: Text("Settings"),
                    ),
                    ListTile(
                      leading: Icon(Icons.help_outline),
                      title: Text("Help and Feedback"),
                    ),
                  ],
                )
                // : SizeTransition(
                //   sizeFactor: CurvedAnimation(
                //     curve: Curves.easeOut,
                //     parent: _animationController
                //   ),
                //   child: Column(
                //     children: <Widget>[
                //       ListTile(
                //       leading: Icon(Icons.add),
                //       title: Text("Add another Account"),
                //     ),

                //     ListTile(
                //       leading: Icon(Icons.settings),
                //       title: Text("Manage Accounts"),
                //     ),
                //     ],
                //   ),
                // ),
              
            ],
          ),
        ),
        body: tabPages[_currentIndex],

        //Bottom navigation bar
        bottomNavigationBar: Container(
          color: Theme.of(context).primaryColor,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.shifting,
            onTap: (index) {
              setState(() {
                _currentIndex = index;

                switch (index) {
                  case 0:
                    appTitle = "Products";
                    break;
                  case 1:
                    appTitle = "Favorites";
                    break;
                  case 2:
                    appTitle = "Cart";
                    break;
                  case 3:
                    appTitle = "My Account";
                    break;
                  default:
                }
              });
            },
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  title: Text(
                    "Home",
                    style: bottomNavigationBarStyle(),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  activeIcon: Icon(
                    Icons.home,
                    size: 20,
                  )),
              BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  title: Text(
                    "Favorites",
                    style: bottomNavigationBarStyle(),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  activeIcon: Icon(
                    Icons.favorite,
                    size: 20,
                  )),
              BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_basket),
                  title: Text(
                    "Cart",
                    style: bottomNavigationBarStyle(),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  activeIcon: Icon(
                    Icons.shopping_basket,
                    size: 20,
                  )),
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle),
                  title: Text(
                    "Account",
                    style: bottomNavigationBarStyle(),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  activeIcon: Icon(
                    Icons.account_circle,
                    size: 20,
                  ))
            ],
          ),
        ));
  }

  TextStyle bottomNavigationBarStyle() => TextStyle(
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.bold,
      fontFamily: "Hind-Regular");
}

class AddFavorite extends StatefulWidget {
  @override
  _AddFavoriteState createState() => _AddFavoriteState();
}

class _AddFavoriteState extends State<AddFavorite> {
  bool isfavorite = false;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 4.0,
      top: 1.0,
      child: InkWell(
        onTap: () {
          setState(() {
            isfavorite = !isfavorite;
          });
        },
        child: !isfavorite
            ? Icon(Icons.favorite_border)
            : Icon(
                Icons.favorite,
                color: Colors.red,
              ),
      ),
    );
  }
}
