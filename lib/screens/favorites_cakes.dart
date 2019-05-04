import 'package:birthcake_bakers/database/database_handler.dart';
import 'package:birthcake_bakers/models/products_model.dart';
import 'package:birthcake_bakers/screens/details_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:birthcake_bakers/models/local_methods.dart';

class Favorites extends StatefulWidget {
  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  List<Model> product = new List<Model>();
  List<Model> productCache = new List<Model>();
  ProductDatabase pDB = ProductDatabase();

  var size;

  void initializer() async {
    try {
      product = await pDB.retrieveFavorites();
      size = product.length;
    } on Exception catch (e) {
      print(e);
    }
    setState(() {
      productCache = product;
    });
  }


  @override
  void initState() {
    product = [];
    productCache = [];
    pDB = ProductDatabase();
    size = product.length;

    initializer();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = product.length;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: <Widget>[
          Container(
              alignment: Alignment.topRight,
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: "${product.length}  ",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                      text: "Favorite Items",
                      style: TextStyle(color: Colors.grey))
                ]),
              )),

          size == 0
              ? Container(
                alignment: Alignment.center,
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Hero(
                          tag: "empty_favorite",
                          child: Icon(
                            Icons.favorite_border,
                            size: 60,
                          ),
                        ),
                        Text("You have no favorite products",
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        Text(
                            "Go to home page, click on detail for any product"),
                        Text(
                            "Then click on favorite icon on top, in the app bar")
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: product.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(product[index].name),
                      direction: DismissDirection.startToEnd,
                      onDismissed: (direction) {
                        Scaffold.of(context).showSnackBar(new SnackBar(
                          content:
                              Text("${product[index].name} removed from cart"),
                        ));
                         product.remove(product[index]);
                        //  ProductDatabase pDB = ProductDatabase();
                        //  pDB.deleteProduct(product[index].id);
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
                                    Hero(
                                        tag: product[index].id,
                                        child: CachedNetworkImage(
                                          imageUrl : product[index].prodURL,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        )),
                                  ],
                                ),

                                SizedBox(
                                  width: 20.0,
                                ),

                                //COLUMN FOR PRODUCT NAME AND QUANTITY
                                //Text to display product names
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    //Item product name
                                    Text(
                                      LocalMethods.capitalize(product[index].name),
                                      softWrap: true,
                                      style: TextStyle(
                                          fontFamily: "Hind-Regular",
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),

                                    //Item price
                                    Text(
                                      "\$ ${product[index].price}",
                                      softWrap: true,
                                      style: TextStyle(
                                          fontFamily: "Hind-Regular",
                                          fontSize: 16,
                                          color: Colors.grey),
                                    ),
                                  ],
                                ),

                                Spacer(),

                                //COLUMN FOR removing product to cart and for selecting items to order
                                Column(
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        size: 30,
                                      ),
                                      color: Colors.grey,
                                      onPressed: () {
                                        setState(() {
                                          //delete product in db
                                          ProductDatabase pDB =
                                              ProductDatabase();
                                          pDB.deleteProduct(product[index].id);

                                          Scaffold.of(context)
                                              .showSnackBar(new SnackBar(
                                            content: Text(
                                                "${product[index].name} removed from cart"),
                                          ));
                                          product.remove(product[index]);
                                        });
                                      },
                                    ),

                                    //Arrow down button for more details
                                    IconButton(
                                      icon: Icon(Icons.keyboard_arrow_down),
                                      onPressed: (){
                                        setState(() {
                                          Navigator.push(context, CupertinoPageRoute(
                                            builder: (context) =>DetailsController(
                                              itemId: product[index].id,
                                              keyTitle:  product[index].name,
                                            )
                                          )); 
                                        });
                                      },
                                    )
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
        ],
      ),
    );
  }
}
