import 'package:birthcake_bakers/screens/details_controller.dart';
import 'package:birthcake_bakers/tools/firebase_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchProduct extends StatefulWidget {
  @override
  _SearchProductState createState() => _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {
  QuerySnapshot queryResultSet, recentQuery, searchedProduct;
  var recentProducts = [], recentIDs = [], allProducts = [], allIDs = [];
  TextEditingController queryController = TextEditingController();
  String query = "";

  @override
  void initState() {
    super.initState();

    initQueries();
  }
  
  @override
  void dispose(){
    super.dispose();

    queryController.dispose();
    query = "";
  }

  initQueries() {
    FirebaseHandler.recentlySearchedCakes().then((results) {
      setState(() {
        recentQuery = results;

        for (var i = 0; i < recentQuery.documents.length; i++) {
          recentProducts.add(recentQuery.documents[i].data["name"]);
          recentIDs.add(recentQuery.documents[i].documentID);
          // allProducts.add(re)
        }

      });
    });


    FirebaseHandler.searchByProductName().then((results){
      setState(() {
          queryResultSet = results;

          for (var i = 0; i < queryResultSet.documents.length; i++) {
            allProducts.add(queryResultSet.documents[i].data["name"]);
            allIDs.add(queryResultSet.documents[i].documentID);
          } 
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = query.isEmpty ? recentProducts : allProducts.where((search)=> search.toLowerCase().trim().startsWith(query)).toList();
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width - 100,
            alignment: Alignment.center,
            child: TextField(
              autofocus: true,
              cursorColor: Colors.white,
              controller: queryController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration.collapsed(
                hintText: "Search product",
                hintStyle: TextStyle(color: Colors.white70),
              ),
              onChanged: (search) {
                setState(() {
                  query = search;
                });
              },
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.clear,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                queryController.clear();
                query="";
              });
            },
          )
        ],
      ),

      body: Container(
        child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, index) => ListTile(
                      onTap: () {
                        setState(() {
                          // indexProduct = snapshot.data.document[index].toString();
                          final itemName = suggestions[index];

                          //Get item name from firestore and send it to detail page
                          FirebaseHandler.singleItemDetailsByName(itemName).then((results){
                            setState(() {
                              searchedProduct = results;

                              if(searchedProduct != null){
                                Navigator.push(context, MaterialPageRoute(
                                builder: (context)=>DetailsController(
                                  itemId: searchedProduct.documents[0].documentID,
                                  keyTitle: itemName,
                                )));
                              }
                            });
                          });
                        });
                      },
                      leading: Icon(Icons.cake),
                      // leading: CircleAvatar(
                      //   backgroundImage: AssetImage(data[index].prodURL),
                      // ),
                      title: RichText(
                        text: TextSpan(
                            text: suggestions[index].substring(0, query.length),
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                  text: suggestions[index].substring(query.length),
                                  style: TextStyle(color: Colors.grey))
                            ]),
                      ),
                    )
                )
         
      ),
    );
  }
}
