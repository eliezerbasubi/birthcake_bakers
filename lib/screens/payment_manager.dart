import 'dart:async';

import 'package:birthcake_bakers/database/database_handler.dart';
import 'package:birthcake_bakers/maps/track_maps_location.dart';
import 'package:birthcake_bakers/models/products_model.dart';
import 'package:birthcake_bakers/tools/firebase_methods.dart';
import 'package:birthcake_bakers/tools/input_formatters.dart';
import 'package:birthcake_bakers/tools/my_strings.dart';
import 'package:birthcake_bakers/tools/payment_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dropdown.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

class Payment extends StatefulWidget {
  // final List<Model> paymentListProduct;
  // Payment({this.paymentListProduct});

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  bool savedMyCard = true, doesCardExist =false, savedDelivery = true, isPaymentSuccessful = false;
  bool isStateActiveOne = false,
      isStateActiveTwo = false,
      isStateActiveThree = false,
      autoValidate = false, autovalidCredit = false,
      showPaymentBox = false,
      canConfirm = false,
      isCachOnDelivery =false,
      avoidDuplicates = false,
      errorFetchingImage = false;

  int _currentIndex = 0, selectedType = 0, paySelected = 0;
  int indexController = 0; //Controls the number of time Next button is clicked.
  int totalQty = 0; //Get each item quantity and multiply it by the initial

  double totalDiscount = 0.0, initialPrice = 0.0, deliveryCost = 0.0, orderTotal = 0.0;
  String btnNext = "NEXT";
  bool isLocationEnabled = false;


  QuerySnapshot userDetails;
  var currentUserID = "", username="", userAddress="", userPicture;
  String dateStamp, timeStamp;
  Map<String, dynamic> orderedProducts = Map<String, dynamic>();

  //order variables
  var localAddress, localZipCode, localCity, localState, creditCardType, creditCardNumber,
                    creditCardName, creditCardExpiration, creditCardCvv, last4Digits;

  TextEditingController address, zipCode, city, state, cardType, cardNumber
                    , cardName, cardExpiration, cardCvv;
  

  StepState completeState = StepState.complete;
  var successKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var secondFormKey = GlobalKey<FormState>();
  var paymentCard =PaymentCard();
  var location = Location();

  List<Model> productsPayment = new List<Model>();
  List<Model> cachedPaidProducts = new List<Model>();

  List<double> radioPrice = [8.0, 5.0, 0.5];

  List<Container> payIcons = [
    Container(width: 40, height: 40,child: Image.asset("images/mastercard.png")),
    Container(width: 40, height: 40,child: Image.asset("images/visa.png")),
    Container(width: 40, height: 40,child: Image.asset("images/american_express.png")),
    Container(width: 40, height: 40,child: Image.asset("images/discover.png")),
    Container(width: 40, height: 40,child: Image.asset("images/handshake.png")),
  ];

  List<String> paymentTitle = [
      "MasterCard",
      "Visa",
      "AmericanExpress",
      "Discover",
      "Cash On Delivery"
    ];

  ProductDatabase productDatabase = ProductDatabase();

  void onChanged(int value) {
    setState(() {
      selectedType = value;

      deliveryCost = radioPrice[value];
      orderTotal = initialPrice + deliveryCost - totalDiscount;
    });
  }

  void onPaymentChanged(int value) {
    setState(() {
      paySelected = value;
      cardType.text = paymentTitle[value];
    });
  }

  void initDBComponents() async{ 
    try{
      productsPayment = await productDatabase.getProductsInCart();  

      setState(() {
       cachedPaidProducts = productsPayment; 

       for (var i = 0; i < cachedPaidProducts.length; i++) {
          // totalDiscount += cachedPaidProducts[i].discount / cachedPaidProducts.length ;
          totalQty += cachedPaidProducts[i].quantity;
          initialPrice += cachedPaidProducts[i].quantity * cachedPaidProducts[i].price;//Get each item price and multiply it by the length of products 
          orderTotal = initialPrice + deliveryCost - totalDiscount;
        }

      });
    } on Exception catch (e){
      print(e);
    }
  }
  
  void initVariables(){
    address =TextEditingController();
    state =TextEditingController();
    city =TextEditingController();
    zipCode =TextEditingController();
    cardType =TextEditingController();
    cardName =TextEditingController();
    cardNumber =TextEditingController();
    cardExpiration =TextEditingController();
    cardCvv = TextEditingController();

    //add listener to cardNumber
    cardNumber.addListener(getCardTypeFrmNumber);
  }

  initMethods(){
    // setState(() {
    
    isPaymentSuccessful = false;
    selectedType = 0;
    deliveryCost = radioPrice[selectedType];

    //Load current user details   
    FirebaseAuth.instance.currentUser().then((userInfo){
      setState(() {
       currentUserID = userInfo.uid; 

       FirebaseHandler.getUserInfo(currentUserID).then((results){
          // setState(() {
            userDetails = results;
          // });
        });

        //Load and check if payment card already exists
        FirebaseHandler.paymentCardExists(creditCardNumber).then((exists){
          doesCardExist = exists;
        });
      });
    });
    

    
    // });
  }

  void validateLocation(){
    setState(() {
      final FormState form = formKey.currentState;
      localAddress = address.text;
      localCity = city.text;
      localZipCode = zipCode.text;
      localState = state.text;
      
      if(!form.validate()){
       autoValidate = true;
       _currentIndex = 0;
      }else{
        form.save();
        showPaymentBox = true; //Display payment box
        indexController++;
      }
    });
  }

  void validateCreditCard(){
    setState(() {
      try {
        final FormState form = secondFormKey.currentState;
        creditCardType = cardType.text;
        creditCardNumber = cardNumber.text;
        creditCardName = cardName.text;
        creditCardExpiration = cardExpiration.text;
        creditCardCvv = cardCvv.text;
        
        if(!form.validate()){
        autovalidCredit = true;
        _currentIndex = 1;
        // indexController = 2;
        //  btnNext = "NEXT";
        }else{
          form.save();
          canConfirm = true;
          indexController++;
        }
      
        } catch (e) {
        }
    });
      
  }

   void getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(cardNumber.text);
    CardType cardType = CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      this.paymentCard.type = cardType;
    });
  }

  sendOrderProducts(){
    cachedPaidProducts.forEach((e){
      // FirebaseHandler.orderProduct(
      //   {
      //     "userID" :currentUserID,
      //     "productName" : e.name,
      //     "quantity": e.quantity,
      //     "price" : e.price,
      //     "status" : "shipping",
      //     "amount" :orderTotal,
      //     "date" :dateStamp,
      //     "time" :timeStamp
      //   }
      // ).then((onValue){
        print("added success");
        avoidDuplicates = true;
      // });
    });

  }
  
  addMyPaymentCard(){
    if(savedMyCard && doesCardExist){
      FirebaseHandler.savePaymentCard({
        "userID" :currentUserID,
        "cardType" :creditCardType,
        "cardName" :creditCardName,
        "cardNumber": creditCardNumber,
        "cardExpiration" :creditCardExpiration,
        "cardCvv" :creditCardCvv
      }).then((onValue){
        print("card was valid");
      });
    }
  }
 
  Future<Map<String, double>> getCurrentLocation() async {
    var currentLocation = <String, double>{};
    try {
      isLocationEnabled = await location.hasPermission();

  
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }
 
 
  @override
  void initState() {
    //Initiate and load items passed from checkout cart to paymentProducts list
    // productsPayment = widget.paymentListProduct;
    productDatabase =ProductDatabase();

    initDBComponents();

    initMethods();

    initVariables();

    getCurrentLocation();
    
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();

    cardNumber.removeListener(getCardTypeFrmNumber);
    isPaymentSuccessful = false;
  }

  @override
  Widget build(BuildContext context) {

    if(userDetails != null){
      username = userDetails.documents[0].data["firstname"];
      userAddress =userDetails.documents[0].data["location"];
      userPicture =userDetails.documents[0].data["profilePic"];
    }
        
    Widget _buildDropdownItem(Country country) => Container(
          child: Row(
            children: <Widget>[
              CountryPickerUtils.getDefaultFlagImage(country),
              SizedBox(
                width: 8.0,
              ),
              Text("+${country.phoneCode}(${country.isoCode})"),
            ],
          ),
        );

    List<String> radioTitle = [
      "Regular (5 Days)",
      "Express (3 Days)",
      "Priority (1 day)"
    ];

    List<Widget> radioDelivery() {
      List<Widget> radio = List<Widget>();

      assert(radioTitle.length == radioPrice.length);

      for (var i = 0; i < radioTitle.length; i++) {
        radio.add(RadioListTile(
          value: i,
          onChanged: (value) {
            onChanged(value);
          },
          groupValue: selectedType,
          title: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                radioTitle[i],
                style: TextStyle(),
              ),
              Text("+\$${radioPrice[i]}")
              //end text which holds price
            ],
          ),
        ));
      }
      return radio;
    }

    List<Widget> paymentRadio() {
      List<Widget> radio = List<Widget>();

      assert(paymentTitle.length == payIcons.length);

      for (var i = 0; i < paymentTitle.length; i++) {
        radio.add(RadioListTile(
          value: i,
          onChanged: (value) {
            onPaymentChanged(value);
            paySelected = value;

            switch (value) {
              case 0:
                isCachOnDelivery = false;
                Navigator.of(context).pop();
                break;
              case 1:
                isCachOnDelivery = false;
                Navigator.of(context).pop();
                break;
              case 2:
                isCachOnDelivery = false;
                Navigator.of(context).pop();
                break;
              case 3:
                isCachOnDelivery = false;
                Navigator.of(context).pop();
                break;
              case 4:
                //If the payment will be done on delivery,skip payment stepper
                _currentIndex = 2;
                indexController = 2;
                canConfirm = true;
                isCachOnDelivery = true; //If cash on delivery, skip payment stepper on back pressed
                btnNext = Strings.processPayment;
                Navigator.of(context).pop();
                break;
              default:
            }
          },
          groupValue: paySelected,
          title: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                paymentTitle[i],
                style: TextStyle(),
              ),
              payIcons[i]
              //end text which holds price
            ],
          ),
        ));
      }
      return radio;
    }

    Widget successBox() {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0,),
        margin: EdgeInsets.all(0.0),
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5.0)),
        child: Column(
          children: <Widget>[
            //Cancel button
            GestureDetector(
              child: CircleAvatar(
                radius: 15,
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),

              onTap: (){
                setState(() {
                  isPaymentSuccessful = false;
                  Navigator.of(context).pop();             
               });

              },
            ),
            Text("Thank You!",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                    fontFamily: "Hind-Regular")),
            Text(
              "Your transaction was successful",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            Divider(),

            SizedBox(
              height: 15,
            ),

            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("DATE", style: TextStyle(color: Colors.grey)),
                Text("TIME", style: TextStyle(color: Colors.grey))
              ],
            ),

            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(dateStamp, style: TextStyle(color: Colors.black)),
                Text(timeStamp, style: TextStyle(color: Colors.black))
              ],
            ),

            SizedBox(
              height: 20,
            ),

            ListTile(
              title: Text("To", style: TextStyle(color: Colors.grey)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(username,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                  Text(userAddress,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold))
                ],
              ),
              trailing: CircleAvatar(
                radius: 35,
                backgroundImage: !errorFetchingImage ? CachedNetworkImageProvider(
                  userPicture,
                  errorListener: (){
                    setState(() {
                      // If image failed to load, show default image
                     errorFetchingImage = true; 
                    });
                  }
                  ) : Image.asset("images/avatar-user.login.jpg"),
              ),
            ),

            SizedBox(
              height: 15,
            ),

            Align(
                alignment: Alignment.topLeft,
                child: Text("AMOUNT", style: TextStyle(color: Colors.grey))),

            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("\$$orderTotal",
                      style: TextStyle(color: Colors.black,fontSize: 17)),
                ),
                Text("SHIPPING", style: TextStyle(color: Colors.grey))
              ],
            ),

            SizedBox(
              height: 10,
            ),

            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.teal),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    payIcons[paySelected], //Currency icon

                    SizedBox(
                      width: 10.0,
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text("${paymentTitle[paySelected]}",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                        Text("${paymentTitle[paySelected]} ending ***3",
                            style: TextStyle(color: Colors.white))
                      ],
                    ),
                  ],
                ),
              ),
            ),

            
            MaterialButton(
              color: Colors.brown,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)
              ),
              minWidth: MediaQuery.of(context).size.width,
              onPressed: (){
                setState(() {
                 Navigator.push(context, CupertinoPageRoute(
                   builder: (context)=> OrderMaps()
                 )); 
                });
              },
              child: Text("View Order transaction",style: TextStyle(color: Colors.white),),
            )
          ],
        ),
      );
    }
    
    List<Step> steps = [
      Step(
          title: Text("Shipping"),
          state: !isStateActiveOne ? StepState.editing : completeState,
          isActive: isStateActiveOne,
          content: Form(
            // padding: const EdgeInsets.all(2.0),
            key: formKey,
            autovalidate: autoValidate,
            child: ListView(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("Shipping Address",
                      style: TextStyle(
                        color: Colors.grey,
                      )),
                ),
                TextFormField(
                  autofocus: false,
                  controller: address,
                  decoration: InputDecoration(
                    labelText: "Address",
                    hintText: "Locality where you stay",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2.0),
                        borderSide: BorderSide(color: Colors.grey)),
                  ),
                  onSaved: (value){
                    localAddress = value;
                  },
                  validator: (valueKey){
                    if(valueKey.isEmpty)
                      return "Address cannot be empty";
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Country",
                  style: TextStyle(color: Colors.grey),
                ),
                Row(
                  children: <Widget>[
                    CountryPickerDropdown(
                      initialValue: 'cd',
                      itemBuilder: _buildDropdownItem,
                      onValuePicked: (Country country) {
                        //print("${country.name}");
                      },
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        controller: zipCode,
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                            labelText: "ZIP Code (optional)",
                            hintText: "Where should we reach you",
                            counterText: "",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(2.0))),
                            onSaved: (value){
                                localAddress =value;
                              },
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  autofocus: false,
                  controller: city,
                  decoration: InputDecoration(
                    labelText: "City",
                    hintText: "Which city are you in",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onSaved: (value){
                    localAddress =value;
                  },
                  validator: (valueKey){
                    if(valueKey.isEmpty)
                      return "City cannot be empty";
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  autofocus: false,
                  controller: state,
                  decoration: InputDecoration(
                    labelText: "State",
                    hintText: "State / Province",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onSaved: (value){
                    localAddress =value;
                  },
                  validator: (valueKey){
                    if(valueKey.isEmpty)
                      return "State cannot be empty";
                  },
                ),
                    
                SizedBox(
                  height: 20,
                )
              ],
            ),
          )),
      //End shipping details step

      //Start Payment Step
      Step(
          title: Text("Payment"),
          state: !isStateActiveTwo ? StepState.editing : completeState,
          isActive: isStateActiveTwo,
          content: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Form(
              key: secondFormKey,
              autovalidate: autovalidCredit,
              child: ListView(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text("Payment Address",
                        style: TextStyle(
                          color: Colors.grey,
                        )),
                  ),
                  Container(
                    alignment: Alignment.topRight,
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        //Change payment currency when selected
                        Text("${paymentTitle[paySelected]}",style: TextStyle(
                          fontWeight: FontWeight.bold,fontFamily: "Hind-Regular"),),

                        SizedBox(width: 10.0,),
                        //Set icon
                        payIcons[paySelected]
                      ],
                    ),
                  ),
                  TextFormField(
                    autofocus: false,
                    controller: cardType,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: "Card Type",
                      hintText: "What's your credit card type",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(2.0),
                          borderSide: BorderSide(color: Colors.grey)),
                      suffixIcon: payIcons[paySelected]
                    ),
                    onSaved: (value){
                      creditCardType = value;
                    },
                    validator: (valueKey){
                      if(valueKey.isEmpty)
                        return "Card Type cannot be empty";
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    autofocus: false,
                    controller: cardNumber,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Card Number",
                      hintText: "What's the number on your card",
                      suffixIcon: Icon(Icons.credit_card),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(2.0),
                          borderSide: BorderSide(color: Colors.grey)),
                    ),
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(19),
                      CardNumberInputFormatter()
                    ],
                    onSaved: (value){
                      creditCardNumber = value;
                      paymentCard.number = CardUtils.getCleanedNumber(value);
                    },
                    validator: CardUtils.validateCardNum,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    autofocus: false,
                    controller: cardName,
                    decoration: InputDecoration(
                      labelText: "Name",
                      hintText: "What's the name on your card",
                      suffixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    onSaved: (value){
                      creditCardName = value;
                    },
                    validator: (valueKey){
                      if(valueKey.isEmpty)
                        return "Holder's name cannot be empty";
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          autofocus: false,
                          controller: cardExpiration,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                            CardMonthInputFormatter()
                          ],
                          decoration: InputDecoration(
                            labelText: "Expired Date",
                            hintText: "MM/YY",
                            suffixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          onSaved: (value){
                            creditCardExpiration = value;
                            List<int> expiryDate = CardUtils.getExpiryDate(value);
                            paymentCard.month = expiryDate[0];
                            paymentCard.year = expiryDate[1];
                          },
                          validator: CardUtils.validateDate,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextFormField(
                          autofocus: false,
                          controller: cardCvv,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4)
                          ],
                          decoration: InputDecoration(
                            labelText: "CVV",
                            hintText: "What's the CVV on your card",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(2.0),
                                borderSide: BorderSide(color: Colors.grey)),
                          ),
                          onSaved: (value){
                            creditCardCvv = value;
                            paymentCard.cvv = int.parse(value);
                          },
                          validator: CardUtils.validateCVV,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(),
                  SwitchListTile(
                    value: savedMyCard,
                    onChanged: (value) {
                      setState(() {
                        savedMyCard = value;
                      });
                    },
                    title: Text("Save my Card Details"),
                  ),
                ],
              ),
            ),
          )),
      //End Payment Step

      Step(
          title: Text("Confirm"),
          state: !isStateActiveThree ? StepState.indexed : completeState,
          isActive: isStateActiveThree,
          content: Padding(
            padding: const EdgeInsets.all(2.0),
              child: ListView(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                children: <Widget>[
                  Padding(padding: const EdgeInsets.all(2.0), child: Container()),

                  //Start display column for shipping details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Shipping To:",
                              style: TextStyle(
                                color: Colors.grey,
                              )),
                          Text("Edit",
                              style: TextStyle(
                                color: Colors.blue,
                              )),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("$username",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("$localAddress, $localCity, $localState, $localZipCode",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Divider()
                    ],
                  ),
                  //End display column for shipping details

                  //Start display column payment details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Payment Details:",
                              style: TextStyle(
                                color: Colors.grey,
                              )),
                          Text("Edit",
                              style: TextStyle(
                                color: Colors.blue,
                              )),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("XXXX - XXXX - XXXX - ${creditCardNumber.toString()}",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                      Divider()
                    ],
                  ),
                  //End display column payment details

                  //Start ListBuilder to display products ordered
                  Column(
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Product(s) Ordered:",
                              style: TextStyle(
                                color: Colors.grey,
                              )),
                          Text("Edit",
                              style: TextStyle(
                                color: Colors.blue,
                              )),
                        ],
                      ),
                      ListView.builder(
                          itemCount: productsPayment.length,
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemBuilder: (context, index) => Column(
                                children: <Widget>[
                                  ListTile(
                                    leading: CachedNetworkImage(imageUrl:productsPayment[index].prodURL,
                                        width: 50.0,
                                        height: 50.0,
                                        fit: BoxFit.cover),
                                    title: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          width: 100,
                                          child: Text("${productsPayment[index].name}",
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            overflow: TextOverflow.ellipsis,
                                            ),
                                        ),
                                        Text("\$${productsPayment[index].price * productsPayment[index].quantity }",
                                            style: TextStyle(
                                              color: Colors.black,
                                            )),
                                      ],
                                    ),
                                    subtitle: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Text("Size : L",
                                            style: TextStyle(
                                              color: Colors.grey,
                                            )),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text("Quantity : ${productsPayment[index].quantity}",
                                            style: TextStyle(
                                              color: Colors.grey,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Divider()
                                ],
                              )),
                    ],
                  ),
                  //End ListBuilder to display products ordered

                  //Start Delivery product column

                  Text("Delivery Product:",
                      style: TextStyle(
                        color: Colors.grey,
                      )),

                  //Start delivery type column
                  Column(
                    children: <Widget>[
                      Column(children: radioDelivery()),
                      Divider()
                    ],
                  ),
                  //End delivery type column

                  //Start Discount row
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Product Discount",
                            style: TextStyle(
                              color: Colors.grey,
                            )),
                        Text("-\$$totalDiscount",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.normal
                            )),
                      ],
                    ),
                  ),
                  //End discount row

                  Divider(),

                  //Start product cost row
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Product Cost",
                            style: TextStyle(
                              color: Colors.grey,
                            )),
                        Text("\$$initialPrice",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.normal
                            )),
                      ],
                    ),
                  ),
                  //End product cost row

                  Divider(),

                  //Start Order total row
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Order Total",
                            style: TextStyle(
                              color: Colors.grey,
                            )),
                        Text("\$$orderTotal",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.bold
                            )),
                      ],
                    ),
                  ),
                  //End Order total  row

                  //Display progress bar
                  Visibility(
                    visible: isPaymentSuccessful,
                    child: Column(
                      children: <Widget>[
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 5,
                        )
                      ],
                    ),
                  )
                  //End display progress bar
                ],
                //End Delivery Product column
              ),
            ),
          ),
      //End Confirmation step
    ];

    return Scaffold(
      key: successKey,
      appBar: AppBar(
        title: Text("Checkout"),
        centerTitle: true,
      ),
      body: Container(
          child: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentIndex,
        controlsBuilder: (BuildContext context,
            {onStepContinue, onStepCancel}) {
          return  Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      color: Colors.brown.withOpacity(0.9),
                      child: FlatButton(
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_currentIndex > 0) {
                              _currentIndex--;
                            }

                            //Skip payment step
                            if(isCachOnDelivery){_currentIndex = 0;}
                              

                            switch (_currentIndex) {
                              case 0:
                                isStateActiveTwo = false;
                                btnNext = Strings.next;
                                indexController = 0; //Start index controller to zero
                                break;
                              case 1:
                                isStateActiveThree = false;
                                indexController--; //Decrease index controller to prevent progress bar to start
                                btnNext = Strings.next;
                                break;
                              default:
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.brown,
                        child: FlatButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                btnNext,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Hind-Regular"),
                              ),
                              Icon(Icons.arrow_forward, color: Colors.white)
                            ],
                          ),
                          onPressed: () {
                            setState(() {
                              if (_currentIndex < steps.length - 1) {
                                _currentIndex++;
                              }

                              //Check for the payment validation
                              if(canConfirm){indexController++;}
                              
                              switch (_currentIndex) {
                                case 1:
                                  isStateActiveOne = true;

                                  //Display choose payment method
                                  validateLocation();
                                  if(showPaymentBox){
                                    paymentDialogBox(context, paymentRadio);
                                  }
                                  break;
                                case 2:
                                  //validate credit card
                                  validateCreditCard();
                                  isStateActiveTwo = true;
                                  //Change next button to process payment
                                  if(canConfirm){  
                                    btnNext = Strings.processPayment;
                                  }
                                
                                  break;
                                default:
                              }

                              // if(indexController == 2){
                              //   validateCreditCard();
                              // }

                              print("current step is $_currentIndex and index controller is $indexController");

                              if (indexController == 3 ) {
                                //_currentIndex = 2;
                                //Show circular progress bar and display payment success dialog box
                                isPaymentSuccessful = true;
                                isStateActiveThree = true;//Active step 3

                                if(savedMyCard){
                                  // print("save my card");
                                }
                                 //Get current time or timestamp
                                DateTime now = DateTime.now();
                                // dateStamp = DateTime();
                                var formatter = new DateFormat('yyyy-MM-dd');
                                dateStamp = formatter.format(now);

                                var formatTime = new DateFormat.jm();
                                timeStamp =formatTime.format(now);

                                  //Now validate inputs and load data to firestore database
                                  sendOrderProducts();
                                
                                  //After 3 seconds, display payment success box
                                  if(avoidDuplicates){
                                      Timer(Duration(seconds: 3), () {
                                      Navigator.of(context).push(PageRouteBuilder(
                                          opaque: false,
                                          maintainState: true,
                                          pageBuilder: (context, _, __) {
                                            return Material(
                                              color: Colors.black38,
                                              child: Container(
                                                  padding: EdgeInsets.all(30.0),
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    width: MediaQuery.of(context)
                                                        .size
                                                        .width,
                                                    height: 450,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.rectangle,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      color: Colors.white,
                                                    ),
                                                    child: ListView(
                                                      shrinkWrap: true,
                                                      children: <Widget>[
                                                        successBox(),
                                                      ],
                                                    ),
                                                  )),
                                            );
                                          }));
                                    });
                                  }
                                }
                            });
                          },
                        ),
                      ),
                    )
                  ],
                ),
              );
        },
        steps: steps,
      )),
    );
  }

  void paymentDialogBox(BuildContext context, List<Widget> paymentRadio()) {
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        maintainState: true,
        pageBuilder: (context, _, __) {
          return Material(
            color: Colors.black38,
            child: Container(
                padding: EdgeInsets.all(30.0),
                alignment: Alignment.center,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 400,
                  color: Colors.white,
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              "Choose your payment method",
                              style: TextStyle(
                                  fontFamily: "Hind-Regular", fontSize: 18),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: paymentRadio())
                        ],
                      ),
                    ],
                  ),
                )),
          );
        }));
  }

}
