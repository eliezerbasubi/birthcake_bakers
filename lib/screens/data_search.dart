// import 'package:birthcake_bakers/models/products_model.dart';
import 'package:birthcake_bakers/screens/details.dart';
import 'package:birthcake_bakers/tools/firebase_methods.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//import 'package:arrow_resto/models/products_model.dart';

class DataSearch extends SearchDelegate<String> {
  var queryResultSet, recentProducts;
  var initQuery = [];
  DataSearch() {
    initQueries();
  }

  initQueries() {
    
    FirebaseHandler.searchByProductName().then((results) {
      queryResultSet = results;
      
    }).catchError((onError){});
    
    FirebaseHandler.recentCakes().then((results) {
      recentProducts = results;
    });
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Details(1);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty ? recentProducts : queryResultSet;

    return StreamBuilder(
        stream: suggestions,
        builder: (context, snapshot) {
          //Check if there's recent cakes
          if (!snapshot.hasData || snapshot.data.documents == null)
            return Text("Loading...");
          if (snapshot.data != null) {
            return ListView.builder(
                itemCount: 5,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) => ListTile(
                      onTap: () {
                        // indexProduct = snapshot.data.document[index].toString();
                        print(snapshot.data.documents[index].documentID);
                        // showResults(context);
                      },
                      leading: Icon(Icons.cake),
                      // leading: CircleAvatar(
                      //   backgroundImage: AssetImage(data[index].prodURL),
                      // ),
                      title: RichText(
                        text: TextSpan(
                            text: snapshot.data.documents[index].data["name"]
                                .substring(0, query.length),
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                  text: snapshot
                                      .data.documents[index].data["name"]
                                      .substring(query.length),
                                  style: TextStyle(color: Colors.grey))
                            ]),
                      ),
                    ));
          }
        });
  }
}

/*
  final List<String>products = new List<String>();
  //final recentProducts = ['Malipu cake','Gracias cake', 'Colide cake'];
  List recentProducts = new List<String>();
  var indexProduct;

  DataSearch(){
    for (var i = 0; i < data.length; i++) {
      products.add(data[i].name.toString());
     // print(products.toString());
    }

    //Get recent products
    //for (var i = 0; i < 5; i++) {
      recentProducts =  products.sublist(data.length -4,data.length);
   //print(recentProducts);
    //}
  }
  @override
  List<Widget> buildActions(BuildContext context) {
    // Actions to be performed when we click on close in search icon
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: (){
         query ="";
        },),
    
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Back arrow icon to be displayed when the search is on focus
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: (){
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Results to be displayed 
    return Details(indexProduct);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    //  Suggestions to be displayed when we are searching
    final suggestions = query.isEmpty ? recentProducts : products.where((p) => p.toLowerCase().trim().startsWith(query)).toList();
    
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context,int index)=> ListTile(
        onTap: (){
          indexProduct = suggestions[index].toString();
          print(suggestions[index].toString());
          showResults(context);
        },
        leading: Icon(Icons.cake),
        // leading: CircleAvatar(
        //   backgroundImage: AssetImage(data[index].prodURL),
        // ),
        title: RichText(
          text: TextSpan(
            text: suggestions[index].substring(0,query.length),
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            children: [TextSpan(
                text: suggestions[index].substring(query.length),
                style: TextStyle(color: Colors.grey)
            )]
          ),
        ),
      )
    );
  }

*/
