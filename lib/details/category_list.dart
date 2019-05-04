import 'package:birthcake_bakers/models/local_methods.dart';
import 'package:birthcake_bakers/screens/details_controller.dart';
import 'package:birthcake_bakers/tools/firebase_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CategoryDetails extends StatefulWidget {
  final String keyID;

  CategoryDetails({this.keyID});

  @override
  _CategoryDetailsState createState() => _CategoryDetailsState();
}

class _CategoryDetailsState extends State<CategoryDetails>
    with SingleTickerProviderStateMixin {
      
  String keyId;
  QuerySnapshot category;
  Animation animation, delayAnimation, muchDelayAnimation;
  AnimationController animationController;
  @override
  void initState() {
    initCategory();
    initAnimation();

    super.initState();
  }

  initAnimation() {
    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    animation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        curve: Curves.fastOutSlowIn, parent: animationController));
  }

  initCategory() {
    setState(() {
      keyId = widget.keyID;
    });

    FirebaseHandler.singleCategory(keyId).then((results) {
      setState(() {
        category = results;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocalMethods.capitalize("$keyId cakes"),
          style: TextStyle(),
          softWrap: true,
        ),
        centerTitle: true,
      ),
      body: category == null
          ? Center(child: Text("Loading..."))
          : GridView.builder(
              itemCount: category.documents.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 0.0,
                  mainAxisSpacing: 0.0,
                  childAspectRatio: 0.75),
              itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.all(8.0),
                  child: OnProductTapped(
                    index: index,
                    category: category,
                  )),
            ),
    );
  }
}

class OnProductTapped extends StatefulWidget {
  final category, index;

  OnProductTapped({this.index, this.category});
  @override
  _OnProductTappedState createState() => _OnProductTappedState();
}

class _OnProductTappedState extends State<OnProductTapped>
    with SingleTickerProviderStateMixin {
  Animation animationLeft, animationRight, animation;
  AnimationController animationController;
  var category, index, keyId;

  @override
  void initState() {
    super.initState();

    // print(FieldValueType.serverTimestamp);

    initAnimator();
    initComponents();
  }

  @override
  void dispose(){
    super.dispose();

    animationController.dispose();
  }
  initAnimator() {
    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));

    //Animation starts to left if the the product has an index of odd number
    //Else it starts to right
    animationLeft = Tween(begin: -8.0, end: 0.0).animate(CurvedAnimation(
        curve: Curves.fastOutSlowIn, parent: animationController));
    
    animationRight = Tween(begin: 8.0, end: 0.0).animate(CurvedAnimation(
        curve: Curves.fastOutSlowIn, parent: animationController));
    
    animation = animationLeft; //Default animation when the screen opens
  }

  initComponents() {
    setState(() {
      category = widget.category;
      index = widget.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (category == null) return Text("Loading...");
    return Stack(
      children: <Widget>[
        InkWell(
          onTap: () {
            setState(() {
              animationController.forward();
              if (index % 2 == 0) {
               animation = animationLeft;
                // print("even number $index and animationLeft");
              } else {
                animation = animationRight;
                // print("odd number $index and animationRight");
              }
            });
          },
          child: Container(
            child: Hero(
              tag: "$keyId$index",
              child: CachedNetworkImage(
                imageUrl: category.documents[index].data["productURL"],
                errorWidget: Icon(
                  Icons.error,
                  color: Colors.red,
                ),
                fadeInCurve: Curves.easeInCirc,
                fit: BoxFit.cover,
                height: 300,
              ),
            ),
          ),
        ),

        //add on tap action
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          bottom: 0.0,
          child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Transform(
                  transform:
                      Matrix4.translationValues(animationLeft.value * 80, 0.0, 0.0),
                  child: InkWell(
                    onTap: (){
                      setState(() {
                       animationController.reverse(); 
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.black87, Colors.black26],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            category.documents[index].data["name"],
                            style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: "Hind-Regular"),
                            softWrap: true,
                            textAlign: TextAlign.center,
                          ),

                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: Colors.white
                              ),
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "\$${category.documents[index].data["price"]}",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 18),
                              softWrap: true,
                            ),
                          ),

                          IconButton(
                            icon: Icon(Icons.info_outline, color: Colors.white, size: 45,),
                            onPressed: (){
                              setState(() {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context)=> DetailsController(
                                      itemId: category.documents[index].documentID,
                                      keyTitle: category.documents[index].data["name"],
                                    )
                                )); 
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
        )
      ],
    );
  }
}
