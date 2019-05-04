import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// void main(){
//   runApp( MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return  MaterialApp(
//       title: 'myApp',
//       color: Colors.grey,
//       home:  TestAppHomePage(),
//       theme:  ThemeData(
//         primarySwatch: Colors.lightBlue,
//       ),
//     );
//   }
// }

class OrderTimeLine extends StatefulWidget {
 // const TestAppHomePage({this.comicCharacter});
  //final SuperHeros comicCharacter;
  @override
  OrderTimeLineState createState() =>  OrderTimeLineState();
}

class OrderTimeLineState extends State<OrderTimeLine>
    with TickerProviderStateMixin {
  //ScrollController _scrollController =  ScrollController();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body:  ListView(
        shrinkWrap: true,
        children: <Widget>[
           Padding(padding:  EdgeInsets.only(top: 20.0),
           child:  MyTimeLine("Ready to pickup","Order from BirthCake Bakers", "11:00 pm",Icon(Icons.shopping_basket)),),
           MyTimeLine("Order Processed","We are preparing your order","11:20 PM",Icon(Icons.assignment_ind)),
           MyTimeLine("Payment confirmed","Your payment has been confirmed","12:00 PM",Icon(Icons.attach_money)),
           MyTimeLine("Order Placed","Order successfully received","12:20 PM",Icon(Icons.check_circle)),
        ],
      ),
    );
  }
}

class VerticalSeparator extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return  Container(
        margin:  EdgeInsets.symmetric(vertical: 4.0),
        height: 60.0,
        width: 1.0,
        color: Colors.brown
    );
  }
}

class MyTimeLine extends StatefulWidget{
  final String header,body,time;
  final Icon icon;
  MyTimeLine(this.header,this.body,this.time,this.icon);
  @override
  _TimeLineState createState() => _TimeLineState();
}

class _TimeLineState extends State<MyTimeLine>{

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding:  EdgeInsets.symmetric(horizontal: 10.0),
      child:  Column(
        children: <Widget>[
           Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
               Container(
                width: 30.0,
                child:  Center(
                  child:  Stack(
                    children: <Widget>[
                       Padding(padding:  EdgeInsets.only(left: 12.0), child:  VerticalSeparator(),),
                      // Container(padding:  EdgeInsets.only(), child:  widget.icon, decoration:  BoxDecoration( color:  Colors.brown,shape: BoxShape.circle),)
                      //White container wraps icons to hide line which passes through icons
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white
                        ),
                        child: Container(
                          padding:  EdgeInsets.only(), 
                          child:  widget.icon,)),
                      
                    ],
                  ),
                ),
              ),
               Expanded(
                 //Column for body
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                     Padding(
                      padding:  EdgeInsets.only(left: 20.0, top: 5.0),
                      child:  Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            widget.header,
                            style:  TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16.0
                            ),
                          ),

                          Row(
                            children: <Widget>[
                              Icon(Icons.access_time,size: 15, color: Colors.grey,),
                              SizedBox(width: 5.0,),

                              Text(
                                widget.time, 
                                style: TextStyle(
                                  fontStyle: FontStyle.normal,
                                  color: Colors.grey,
                                ),)
                            ],
                          ),

                        ],
                      ),
                    ),
                     Padding(
                      padding:  EdgeInsets.only(left: 20.0, top: 5.0),
                      child:  Text(
                        widget.body
                      ),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class Transactions extends StatefulWidget {
  final String month, product, price;

  Transactions(this.month,this.product,this.price);
  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  @override
  Widget build(BuildContext context) {
    return  Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(widget.month, style: TextStyle(
                  color: Colors.grey,
                )),

                Container(
                  width: 170,
                  //alignment: Alignment.center,
                  child: Text(widget.product, style: TextStyle(
                        //color: Colors.black,
                        fontSize: 15,
                        fontFamily: "Hind-Regular"
                      ),
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      maxLines: 1,
                      textAlign: TextAlign.justify,
                  ),
                ),

                Text("\$${widget.price}", style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 18,
                  fontFamily: "Hind-Regular"
                )),
              ],
            ),
          ],
        ),
      );
  }
}