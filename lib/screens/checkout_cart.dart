import 'package:birthcake_bakers/models/products_model.dart';
//import 'package:arrow_resto/screens/generate_qr_code.dart';
//import 'package:birthcake_bakers/screens/order_product.dart';
import 'package:birthcake_bakers/screens/payment_manager.dart';
import 'package:flutter/material.dart';

class CheckOut extends StatefulWidget {
  final List<Model>receiveCheckOut;

  CheckOut(this.receiveCheckOut);
  @override
  _CheckOutState createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  double total =0;
  var i;
  bool sortProducts = true, requestFocus = false;
  TextEditingController _quantityController;
  String initialQty;

  final textStyle = TextStyle(
       fontSize: 16,
       fontStyle: FontStyle.normal,
       fontWeight: FontWeight.w700,
       fontFamily: "Hind-Regular"
  );
  
  @override
    void initState() {
      for (i = 0; i < widget.receiveCheckOut.length; i++) {
        total += widget.receiveCheckOut[i].price;

        _quantityController = TextEditingController(text: "${widget.receiveCheckOut[i].quantity}");
      }

      super.initState();
    }

    @override
      void didUpdateWidget(CheckOut oldWidget) {
        for (i = 0; i < widget.receiveCheckOut.length; i++) {
        total += widget.receiveCheckOut[i].price;

        _quantityController = TextEditingController(text: "${widget.receiveCheckOut[i].quantity}");
      }
        super.didUpdateWidget(oldWidget);
      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("CheckOut cart history"),
          centerTitle: true,
        ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(0.0),
            child: Stack(
              children: <Widget>[
                ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    Container(
                      //padding: EdgeInsets.all(10.0),
                      child: DataTable(
                        sortColumnIndex: 1,
                        sortAscending: sortProducts,
                        columns: <DataColumn>[
                          DataColumn(
                            label: Text("", style: textStyle,),
                            numeric: false,
                            tooltip: "Takes images only"
                          ),

                           DataColumn(
                            label: Text("Product", style:  textStyle,),
                            numeric: false,
                            tooltip: "Takes name only",
                            onSort: (i,b){
                              setState(() {
                                  sortProducts = !sortProducts;

                                  //Ascending order
                                  sortProducts ? widget.receiveCheckOut.sort((a,z)=> a.name.compareTo(z.name))
                                               : widget.receiveCheckOut.sort((a,z)=> z.name.compareTo(a.name));

                                 });
                            }
                          ),

                           DataColumn(
                            label: Text("Qty", style: textStyle,),
                            numeric: false,
                            tooltip: "Takes quantity only"
                          ),

                           DataColumn(
                            label: Text("Price", style: textStyle,),
                            numeric: false,
                            tooltip: "Takes price only"
                          ),
                        ],

                        rows: widget.receiveCheckOut.map((e)=>
                         DataRow(cells: [
                           DataCell(Image.asset(e.prodURL,height: 60, width: 60, fit: BoxFit.cover),onTap: (){}),
                           DataCell(Text(e.name),onTap: (){}),
                           DataCell(
                             TextFormField(
                                initialValue: "${e.quantity}",
                                //autofocus: requestFocus,
                                enabled: requestFocus,
                                keyboardType: TextInputType.number,
                               // controller: _quantityController,
                                textInputAction: TextInputAction.done,
                                maxLength: 1,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  counterText: ""
                                  ),
                                validator: (value){
                                  if(int.parse(value) > 3){
                                    print("value is too big");
                                  }
                                },

                                onEditingComplete: (){
                                  //print("$initialQty product quantity");
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                },

                             ),
                             showEditIcon: true,
                             onTap: (){
                               setState(() {
                                  requestFocus = !requestFocus;
                                  initialQty = _quantityController.text;
                                });
                             }),
                           DataCell(Text(e.price.toString()),onTap: (){})
                         ])).toList(),
                      ),
                    ),
                  ],
                ),

                //ROW FOR TOTAL PRODUCTS
              Positioned(
                left: 10.0,
                bottom: 50.0,
                width: MediaQuery.of(context).size.width,
                child: Container(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    MaterialButton(
                      color: Theme.of(context).primaryColor,
                      minWidth: 30,
                      padding: EdgeInsets.all(10.0),
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context)=> Payment()
                          ));
                        },
                        child: Text("Proceed to checkout", style: TextStyle(color: Colors.white),),
                    ),
                    Text("Total : ",style: TextStyle(fontSize: 28),),
                    Text("\$ $total",style: TextStyle(fontSize: 30,),)
                  ],
                ),
              ),
              )
              
              ],
            ),
          ),
    );
  }
}