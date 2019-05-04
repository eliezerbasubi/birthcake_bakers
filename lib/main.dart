import 'dart:async';

import 'package:birthcake_bakers/database/database_handler.dart';
import 'package:birthcake_bakers/screens/home.dart';
import 'package:birthcake_bakers/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:birthcake_bakers/screens/steppers_control.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  String isVisited = "";
  ProductDatabase pdb;

  Future<String> loadVisit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String visit = prefs.getString("visited");

    return visit;
  }

  @override
  void initState() {
    loadVisit().then(updateStatus).catchError((onError) => null);

    pdb = ProductDatabase();
    pdb.initDB();

    //IF firebase auth user id is null, take the user to login page
    FirebaseAuth.instance.currentUser().then((currentUser){
      if(currentUser.uid ==null){
        return Login();
      }
    });

    super.initState();
  }

  updateStatus(value) {
    setState(() {
      try {
        this.isVisited = value;
      } catch (e) {}
    });
  }

  Widget init() {
    if (isVisited == "Visited") 
      return Login();
     else if (isVisited == "loggedIn") 
      return Home();
    else
    return Steppers();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        theme: ThemeData(
            // primaryColor: Color(0xff075E54),
            // accentColor: Color(0xff25D366)
            primarySwatch: Colors.brown),
        title: "BirthCake Bakers",
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: init(),
        )
        //new Login()
        );
  }
}
