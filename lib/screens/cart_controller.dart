import 'package:birthcake_bakers/screens/checkout_cart.dart';
import 'package:flutter/material.dart';
import 'package:birthcake_bakers/models/products_model.dart';
import 'package:flutter/rendering.dart';


class CartController extends StatefulWidget {
  final List<Model> productID;
  final Function decreaseCartCounter;
  
  CartController(this.productID,this.decreaseCartCounter);

  @override
  _CartControllerState createState() => _CartControllerState();
}

class _CartControllerState extends State<CartController> {
  var item;
  int validateCheckBox = 0;
  bool isChecked = false;
  bool increase;
  bool _isVisible = true;
  var nProduct;
  var quantity = 1;

  List<Model> checkOutList = new List<Model>();
  Map<String,bool> list = new Map<String,bool>();
  ScrollController _scrollController;
  
  @override
    void initState() {
      nProduct = widget.productID;
      for (var i = 0; i < nProduct.length; i++) {
        item = nProduct[i].name;
        //print("valid items $item");
        list.putIfAbsent(item, ()=> false);
      }

      //Manage position of scroll listview.
      _scrollController = ScrollController();
      _scrollController.addListener((){
          if(_scrollController.position.userScrollDirection == ScrollDirection.reverse){
            setState((){
              _isVisible = true;
            //print("**** $_isVisible up");
            });
          }

          if(_scrollController.position.userScrollDirection == ScrollDirection.forward){
            setState((){
              _isVisible = false;
              //print("**** $_isVisible down");

            });
          }
      });
      
      super.initState();
    }

    @override
      void didUpdateWidget(CartController oldWidget) {
        nProduct = widget.productID;
        for (var i = 0; i < nProduct.length; i++) {
          item = nProduct[i].name;

          list.putIfAbsent(item, ()=> false);
          //print("Widget updated with items $item");
        }
        super.didUpdateWidget(oldWidget);
      }

    void setChecking(int index, bool value){
      setState(() {
        try {
          String key = list.keys.elementAt(index);
          list[key] = value;


          if(value){
            checkOutList.add(
              Model(
               name: nProduct[index].name,
               price: nProduct[index].price,
               desc: nProduct[index].desc,
               prodURL: nProduct[index].prodURL,
               monthYear: nProduct[index].monthYear,
               discount: nProduct[index].discount,
               oldPrice: nProduct[index].oldPrice,  
               quantity: nProduct[index].quantity
              ),
            );
            print(QuantityCounter(index));
          }else{
            checkOutList.removeAt(index);
            //print("checked value is false");
          }
        } catch (e) {
          print("Error is ${e.toString()}");
        }
              
        });
    }

    
  @override
  Widget build(BuildContext context) {
    var size = widget.productID.length;
    return  Scaffold(
      // appBar: AppBar(
      //   title: Text("Cart History"),
      // ),
      
      floatingActionButton: Opacity(
        opacity: _isVisible ? 1.0 : 0.0,
        child: FloatingActionButton(
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> CheckOut(checkOutList)));
          },
          child: Icon(Icons.check, color: Colors.white,),
          isExtended: false,
        ),
      ),

      body: Container(
        margin: EdgeInsets.all(10.0),
        child: ListView.builder(
          controller: _scrollController,
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
                                Text("${nProduct[index].name}",softWrap: true, style: TextStyle(fontFamily: "Hind-Regular", fontSize: 16),),

                                //quantity counter
                                QuantityCounter(index)
                                
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

                                // IconButton(
                                //   color: Colors.lightGreen,
                                //   onPressed: (){
                                //     setState(() {
                                //         validateCheckBox++;
                                //         isChecked = true;
                                //         if (validateCheckBox == 2) {
                                //           validateCheckBox = 0;
                                //           isChecked = false;
                                //         }                            
                                //     });
                                //   },
                                //   icon: !isChecked ? Icon(Icons.check_box_outline_blank, size: 30,) : Icon(Icons.check_circle, size: 30,),
                                // ),

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
    );
    
  }
}

class QuantityCounter extends StatefulWidget {
  final index;

  QuantityCounter(this.index);
  @override
  _QuantityCounterState createState()=> _QuantityCounterState();
}

  class _QuantityCounterState extends State<QuantityCounter> {
    var quantity;
    @override
      void initState() {
        quantity = data[widget.index].quantity;
        super.initState();
      }
    @override
    Widget build(BuildContext context) {
      // int quantity = data[widget.index].quantity;
      return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
            Text("Quantity"),
            Opacity(
              opacity: quantity > 1 ? 1.0 : 0.0,
              child: IconButton(
              icon: Icon(Icons.remove),
              onPressed: (){
              setState(() {
                if (quantity > 1) {
                quantity--;
                }
              });
          },),
       ),

            Text("$quantity",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,textBaseline: TextBaseline.ideographic),),
            GestureDetector(
            child: Icon(Icons.add),
            onTap: (){
                setState(() {
                quantity++;                                    
                });
              },
          ),
          ],
     );
   }
    
  }
  
