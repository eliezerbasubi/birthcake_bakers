import 'package:flutter/material.dart';

import 'package:birthcake_bakers/models/products_model.dart';

class Details extends StatefulWidget {
   final keyTitle ;
  Details(this.keyTitle);

  @override
  DetailsState createState() {
    return new DetailsState();
  }
}

class DetailsState extends State<Details> {
  List<Model> detailsList = List<Model>();
  @override
    void initState() {
      super.initState();
      
      for (var i = 0; i < data.length; i++) {
        bool distinct = false;
        for(var j = 0; j< i; j++){
          if (data[i].name == widget.keyTitle) {
            detailsList.add(
                Model(
                  name: data[i].name,
                  price: data[i].price,
                  desc: data[i].desc,
                  prodURL: data[i].prodURL,
                  monthYear: data[i].monthYear,
                  discount: data[i].discount,
                  oldPrice: data[i].oldPrice, 
                  quantity: data[i].quantity 
                ));
              }
        }
        if(!distinct){
          //print("value not found");
        }
      }
    }

  @override
  Widget build(BuildContext context) {
    //String prodName = data[keyTitle].name;

    final spaces = SizedBox(height: 20.0,);

    final priceRow = Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("Price",style:TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold,fontSize: 20.0),softWrap: true,),
                SizedBox(width: 130.0,),
                Text("\$ ${detailsList[0].price}.00", style: TextStyle(fontSize: 18.0)),
              ],
            );

    final oldPriceRow = Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("Old Price",style:TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold,fontSize: 20.0),softWrap: true,),
                SizedBox(width: 90.0,),
                Text("\$ ${detailsList[0].oldPrice}.00", style: TextStyle(fontSize: 18.0)),
              ],
            );

    final discountRow = Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("Discount",style:TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold,fontSize: 20.0),softWrap: true,),
                SizedBox(width: 80.0,),
                Text("${detailsList[0].discount}% ", style: TextStyle(fontSize: 18.0)),
              ],
            );

    final addToCart = Container(
      //margin: EdgeInsets.symmetric(horizontal: 50.0),
        child:  Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
               Material(
                 elevation: 7.0,
                 borderRadius: BorderRadius.all(Radius.circular(20.0)),
                 child: MaterialButton(
                   onPressed: (){

                   },
                   child: Text("Add to cart",textAlign: TextAlign.center,style: TextStyle(fontSize: 18.0),),
                   height: 50.0,
                   minWidth: 230.0,
                 ),
               )
              ],
            ),
    );
   

    return Scaffold(
    
      body: Container(
        margin: EdgeInsets.all(10.0),
        child: ListView(
            children: <Widget>[
              Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(detailsList[0].prodURL,width: 500.0,height: 400.0, fit: BoxFit.cover,),
              spaces,

              //title of product
              Text(detailsList[0].name, style: TextStyle(fontSize: 18, fontFamily: "Hind-Regular", fontWeight: FontWeight.w700),),
              spaces,
              //Product description
              Text(detailsList[0].desc+"lorem dfjkjdl dkfeopr ldjfksdjkoeiru djfdjsklj eierddjflj",
               style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.normal,fontSize: 16.0),softWrap: true,),
              SizedBox(height: 10.0,),
              //row of stars
              Row(
                children: <Widget>[
                  Icon(Icons.star,color: Colors.yellowAccent,size: 45,),
                  Icon(Icons.star,color: Colors.yellowAccent,size: 45,),
                  Icon(Icons.star,color: Colors.yellowAccent,size: 45,),
                  Icon(Icons.star,color: Colors.yellowAccent,size: 45,),
                  Icon(Icons.star_half,color: Colors.yellowAccent,size: 45,),
                  
                  SizedBox(width: 30.0),
                  Text("4.8", style: TextStyle(fontSize: 18.0),)
                ],
                
              ),
              SizedBox(height: 10.0,),
              //row of price
              priceRow,
              SizedBox(height: 10.0,),
              oldPriceRow,
              SizedBox(height: 10.0,),
              discountRow,
              SizedBox(height: 20.0,),
              addToCart
            ],
          ),
            ],
             
        ),
      ),
    );
  }
}