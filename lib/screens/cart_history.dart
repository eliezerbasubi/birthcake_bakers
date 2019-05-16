//import 'package:birthcake_bakers/screens/checkout_cart.dart';
import 'package:birthcake_bakers/database/database_handler.dart';
import 'package:birthcake_bakers/screens/payment_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:birthcake_bakers/models/products_model.dart';
import 'package:flutter/rendering.dart';

//_CartHistoryState globalState = new _CartHistoryState();
//flutter clean, to clean up bugs
class CartHistory extends StatefulWidget {
  final List<Model> productID;
  final Function decreaseCartCounter;
  final bool showAppBar;

  CartHistory({this.productID, this.decreaseCartCounter, this.showAppBar});

  @override
  _CartHistoryState createState() => _CartHistoryState();
}

class _CartHistoryState extends State<CartHistory> {
  var item;
  double totalAmount = 0.0,
      augmentedPrice =
          0.0; //AugmentedPrice is the price of an item                                                   //multiply by quantity
  int validateCheckBox = 0;
  bool isChecked = false,
      isShownButton = true,
      isStateAdded =
          true; //isStateAdded is set to true, so that quantity can be incremented
  bool increase;
  // bool _isVisible = true;
  bool isAppBarVisible;
  var nProduct, toCheckout;
  var quantity = 1,size;

  List<Model> checkOutList = new List<Model>();
  List<Model> cartList = new List<Model>();
  List<Model> cachedList = new List<Model>();

  Map<String, bool> list = new Map<String, bool>();
  List<int> baseQuantity = new List<int>();

  ScrollController _scrollController;
  ProductDatabase productDatabase =ProductDatabase();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  void initDBComponents() async{
   try {
      cartList = await productDatabase.getProductsInCart();
      size = cartList.length;
      
      setState(() {
        cachedList = cartList;

        cachedList.forEach((elt){
          quantity = elt.quantity;
        });

        initValidateCart();
      });
      
    } on Exception catch (e) {
      print(e);
    }
  }

  void initValidateCart(){
    setState(() {
      for (var i = 0; i < cachedList.length; i++) {
        item = cachedList[i].name;
        //print("valid items $item");
        list.putIfAbsent(item, () => false);

        //Add price of each product in list
        totalAmount += cachedList[i].quantity * cachedList[i].price;
        quantity =cachedList[i].quantity;

        //Fetch quantity and add it to list
        baseQuantity.add(cachedList[i].quantity);
      } 
    });
  }

  @override
  void initState() {
    nProduct = widget.productID;
    isAppBarVisible = widget.showAppBar;
    productDatabase = ProductDatabase();

    initDBComponents();
    
    super.initState();
  }

  

  @override
  void didUpdateWidget(CartHistory oldWidget) {
    nProduct = widget.productID;
    isAppBarVisible = widget.showAppBar;
    for (var i = 0; i < cartList.length; i++) {
      item = cartList[i].name;

      list.putIfAbsent(item, () => false);
      //print("Widget updated with items $item");
    }
    super.didUpdateWidget(oldWidget);
  }

  void setChecking(int index, bool value) {
    setState(() {
      try {
        String key = list.keys.elementAt(index);
        list[key] = value;

        // RangeError.index(
        //   index,
        //   index
        // );
        print("quantity is ${baseQuantity[index]}");
        if(value){
          isChecked = true;

          toCheckout = Model(
              id: cartList[index].id,
              name: cartList[index].name,
              price: cartList[index].price,
              prodURL: cartList[index].prodURL,
              quantity: baseQuantity[index]
            );
          productDatabase.cartUpdate(toCheckout);
        }
        
      } catch (e) {
        print("Error is ${e.toString()}");
      }
    });
  }

  //Callback method add items to cart, it is called and executed in quantity counter class
  //bool state, gives the state of the button, whether to increase or decrease quantity
  callback(index, quantity) {
    setState(() {
      // baseQuantity.add(index);
      try {
        // RangeError.value(quantity);

        if (isStateAdded) {
          augmentedPrice = cachedList[index].price * quantity;
          // totalAmount += nProduct[index].price + augmentedPrice;
          totalAmount += cachedList[index].price;
        }

        baseQuantity.insert(index, quantity + 1);
      } catch (e) {
        print(e);
      }
    });
  }

  callbackDecrease(index, quantity) {
    setState(() {
      // baseQuantity.add(index);
      try {
        // RangeError.value(quantity);

        if (quantity > 1) {
          // augmentedPrice = nProduct[index].price * quantity;
          augmentedPrice = cachedList[index].price;
          totalAmount -= cachedList[index].price;
          // totalAmount = totalAmount - augmentedPrice;
        }

        baseQuantity.insert(index, quantity + 1);
      } catch (e) {
        print(e);
      }
    });
  }

  
  @override
  Widget build(BuildContext context) {
   size = cartList.length;
    return Scaffold(
      key: scaffoldKey,
      appBar: isAppBarVisible
          ? AppBar(
              title: Text("Cart History"),
              centerTitle: true,
            )
          : null,

      body: size == 0 ? Center(
        child: Container(
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
        ),
      )
      : Container(
        margin: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 8,
              child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: size,
                itemBuilder: (context,index){
                    return Dismissible(
                      key: Key(cartList[index].name),
                      direction: DismissDirection.startToEnd,
                      onDismissed: (direction){
                         widget.decreaseCartCounter();
                        Scaffold.of(context).showSnackBar(new SnackBar(
                        content: Text("${cartList[index].name} removed from cart"),)); 

                          cartList.removeAt(index);// remove item
                          callbackDecrease(index, quantity); // reduce quantity
                      },
                        child: Card(
                        elevation: 5.0,
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Stack(
                                    children: <Widget>[
                                      CachedNetworkImage(imageUrl : cartList[index].prodURL,width: 120,height: 120,fit: BoxFit.cover,),
                                      
                                    ],
                                  ),

                                  SizedBox(width: 20.0,),
                                  
                                  //COLUMN FOR PRODUCT NAME AND QUANTITY
                                  //Text to display product names
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      //Item product name
                                      Container(
                                        width: MediaQuery.of(context).size.width /3,
                                        child: Text("${cartList[index].name}",softWrap: true, style: TextStyle(fontFamily: "Hind-Regular", fontSize: 16,fontWeight: FontWeight.bold),)),

                                      //Item price
                                      Text("\$ ${cartList[index].price}",softWrap: true, style: TextStyle(fontFamily: "Hind-Regular", fontSize: 16, color: Colors.red),),

                                      //quantity counter
                                      QuantityCounter(index: index,dbQuantity: cartList[index].quantity,callback: callback, callbackDecrease: callbackDecrease)
                                      
                                    ],
                                  ),
                                  
                                  Spacer(),

                              //COLUMN FOR removing product to cart and for selecting items to order
                                  Column(
                                  
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(Icons.remove_shopping_cart,size: 30,),
                                        color: Colors.red,
                                        onPressed: (){
                                          setState(() {
                                               widget.decreaseCartCounter();

                                              //Delete item from sqflite database
                                              productDatabase.deleteProductToCart(cartList[index].id).then((isSuccessful){
                                                Scaffold.of(context).showSnackBar(new SnackBar(
                                                content: Text("${cartList[index].name} removed from cart"),)); 
                                                  
                                                  cartList.removeAt(index);  //Remove item
                                                  callbackDecrease(index, quantity); //Dicrease quantity  
                                                  totalAmount += cachedList[index].price; //Update total amount 
                                              });
                                                
                                          });
                                        },
                                      ),

                                      Checkbox(
                                        onChanged: (bool val){
                                          setChecking(index, val);
                                        },
                                        value: list.values.elementAt(index),
                                      )
                                    ],
                                  ) 
                                ],
                              ),

                            ],
                          ),
                      ),
                    );
                }
              ),
            ),
            //End list of products

            Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Total Amount",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontFamily: "Hind-Regular",
                        )),
                    Text("\$ $totalAmount",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontFamily: "Hind-Regular",
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    elevation: 7.0,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    color: Colors.brown,
                    child: MaterialButton(
                      onPressed: () {

                        if(isChecked){
                          productDatabase.cartUpdate(toCheckout);
                          Navigator.push(
                            context,MaterialPageRoute( builder: (context) =>Payment()));
                        }
                        // Toast a message if user does not select any product
                        else{
                           scaffoldKey.currentState.showSnackBar(new SnackBar(
                          content: Text("No product selected"),));
                        }
                        
                      },
                      child: Text(
                        "Checkout",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                      minWidth: MediaQuery.of(context).size.width - 80,
                    ),
                  ),
                ),
              ],
            )),
            
          ],
        ),
      ),
    );
  }
}

class QuantityCounter extends StatefulWidget {
  final index, dbQuantity;
  final Function(int, int) callback, callbackDecrease;

  QuantityCounter({this.index, this.dbQuantity, this.callback, this.callbackDecrease});
  @override
  _QuantityCounterState createState() => _QuantityCounterState();
}

class _QuantityCounterState extends State<QuantityCounter> {
  var quantity , size;
  bool isStateAdded;
  List<Model> cartList = List<Model>();
  List<Model> cachedList = List<Model>();

  ProductDatabase productDatabase =ProductDatabase(); 


  // void initDBComponents() async{
  //  try {
  //     cartList = await productDatabase.getProductsInCart();
  //     size = cartList.length;
      
      
  //     setState(() {
  //       cachedList = cartList;

  //       for (var i = 0; i < cachedList.length; i++) {
  //         quantity = cachedList[i].quantity;
  //         print("quantity on start is ${cachedList.length}");
  //       }
  //     });
      
  //   } on Exception catch (e) {
  //     print(e);
  //   }
  // }

  void initComponents(){
    // for (var i = 0; i < cachedList.length; i++) {
      quantity = widget.dbQuantity;
    // }
  }

  @override
  void initState() {
    initComponents();
    productDatabase = ProductDatabase();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // int quantity = widget.dbQuantity;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text("Qty"),
        SizedBox(
          width: 20,
        ),
        GestureDetector(
          child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: BorderDirectional(
                      start: BorderSide(color: Colors.grey, width: 1),
                      top: BorderSide(color: Colors.grey, width: 1),
                      end: BorderSide(color: Colors.grey, width: 1),
                      bottom: BorderSide(color: Colors.grey, width: 1))),
              child: Icon(Icons.remove)),
          onTap: () {
            if (quantity > 1) {
             setState(() {
               widget.callbackDecrease(widget.index, quantity--); 
             });
            }
          },
        ),

        Container(
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                border: BorderDirectional(
                    start: BorderSide(color: Colors.grey, width: 1),
                    top: BorderSide(color: Colors.grey, width: 1),
                    end: BorderSide(color: Colors.grey, width: 1),
                    bottom: BorderSide(color: Colors.grey, width: 1))),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "$quantity",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    textBaseline: TextBaseline.ideographic),
              ),
            )),

        GestureDetector(
          child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: BorderDirectional(
                      start: BorderSide(color: Colors.grey, width: 1),
                      top: BorderSide(color: Colors.grey, width: 1),
                      end: BorderSide(color: Colors.grey, width: 1),
                      bottom: BorderSide(color: Colors.grey, width: 1))),
              child: Icon(Icons.add)),
          onTap: () {
            if (quantity < 4) {
              setState(() {
                 widget.callback(widget.index, quantity++);
                 print(quantity);
              });
             
            }
          },
        ),
      ],
    );
  }
}

/*
Container(
        margin: EdgeInsets.all(10.0),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              itemCount: size,
              itemBuilder: (context,index){
                  return Dismissible(
                    key: Key(data[index].name),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (direction){
                       widget.decreaseCartCounter();
                      Scaffold.of(context).showSnackBar(new SnackBar(
                      content: Text("${nProduct[index].name} removed from cart"),)); 
                        nProduct.removeAt(index);
                    },
                      child: Card(
                      elevation: 5.0,
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Stack(
                                  children: <Widget>[
                                    Image.asset(nProduct[index].prodURL,width: 120,height: 120,fit: BoxFit.cover,),

                                  ],
                                ),

                                SizedBox(width: 20.0,),
                                
                                //COLUMN FOR PRODUCT NAME AND QUANTITY
                                //Text to display product names
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    //Item product name
                                    Text("${nProduct[index].name}",softWrap: true, style: TextStyle(fontFamily: "Hind-Regular", fontSize: 16,fontWeight: FontWeight.bold),),

                                    //Item price
                                    Text("\$ ${nProduct[index].price}",softWrap: true, style: TextStyle(fontFamily: "Hind-Regular", fontSize: 16, color: Colors.red),),

                                    //quantity counter
                                    QuantityCounter(index: index,callback: callback, callbackDecrease: callbackDecrease)
                                    
                                  ],
                                ),
                                
                                Spacer(),

                            //COLUMN FOR removing product to cart and for selecting items to order
                                Column(
                                
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(Icons.remove_shopping_cart,size: 30,),
                                      color: Colors.red,
                                      onPressed: (){
                                        setState(() {
                                             widget.decreaseCartCounter();
                                            Scaffold.of(context).showSnackBar(new SnackBar(
                                            content: Text("${nProduct[index].name} removed from cart"),)); 
                                              nProduct.removeAt(index);       
                                        });
                                      },
                                    ),

                                    Checkbox(
                                      onChanged: (bool val){
                                        setChecking(index, val);
                                      },
                                      value: list.values.elementAt(index),
                                    )
                                  ],
                                ) 
                              ],
                            ),

                          ],
                        ),
                    ),
                  );
              }
            ),
            //End list of products

            //button
            Positioned(
              bottom: 0.0,
              right: 0.0,
              left: 0.0,
              //width: MediaQuery.of(context).size.width,
              child: Visibility(
                visible: isShownButton,
                  child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.black))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Total Amount", style: TextStyle(
                              color: Colors.black, fontSize: 17, fontFamily: "Hind-Regular",)),

                            Text("\$ $totalAmount", style: TextStyle(
                              color: Colors.red, fontSize: 18, fontFamily: "Hind-Regular",fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Material(
                            elevation: 7.0,
                            borderRadius: BorderRadius.all(Radius.circular(20.0)),
                            color: Colors.brown,
                            child: MaterialButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> Payment(paymentListProduct: checkOutList)));
                              },
                              child: Text(
                                "Checkout",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18.0,color: Colors.white),
                              ),
                              minWidth: MediaQuery.of(context).size.width - 80,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
//Manage position of scroll listview.
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        setState(() {
          //_isVisible = true;
          isShownButton = false;
          //print("**** $_isVisible up");
        });
      }

      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        setState(() {
          //_isVisible = false;
          isShownButton = true;
          //print("**** $_isVisible down");
        });
      }
    });
*/
