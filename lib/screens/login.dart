import 'dart:async';

import 'package:birthcake_bakers/models/users_model.dart';
import 'package:birthcake_bakers/screens/register_users.dart';
// import 'package:birthcake_bakers/tools/firebase_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:carousel_pro/carousel_pro.dart';

import 'package:birthcake_bakers/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin{
  final TextEditingController _username = new TextEditingController();
  final TextEditingController _password = new TextEditingController();
  //final GlobalKey<ScaffoldState> _globalKey = new GlobalKey<ScaffoldState>();
  String _user, _pass;
  final formKey = GlobalKey<FormState>();
  bool isObscuredText = true, isFound = false;

  AnimationController _animationController;
  Animation<double> _animation;

  @override
    void initState() {
      super.initState();
      _animationController = new AnimationController(
        vsync: this,
        duration: new Duration(
          milliseconds: 700,
        ));

        _animation = new CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut
        );

        //method to start animation
        _animation.addListener((){
          return this.setState((){});
        });

        //Start running the animation
        _animationController.forward();
    }

  @override
    void dispose(){
      super.dispose();

      _animationController.dispose();
    }
    
     validateForm(){
       Navigator.push(context, new MaterialPageRoute(
                   builder: (context)=> new Home()
           ));
        _username.clear();
        _password.clear();
    }

     validateEmail(String value){
       setState(() {
            for (var i = 0; i < users.length; i++) {
                  if (users[i].email != value) {
                    print("Email value not found at $i");
                    return false;
                 }else{
                   print("Email value is found at $i");
                   return true;
                 }
         }    
          });
         
    }

    validatePassword(String value){
      setState(() {
           for (var i = 0; i < users.length; i++) {
                  if (users[i].password != value) {
                    print("Password value not found at $i");
                      return "Incorrect password";
                 }else{
                   print("Password value is found at $i");
                 }
         }   
        });
       
    }

    Future<bool> persistLogin(String loginStatus) async{
      SharedPreferences loggedPrefs = await SharedPreferences.getInstance();
      loggedPrefs.setString("visited", loginStatus);

      //save user profile image and name
      return true;
    }
  @override
  Widget build(BuildContext context){

    final separator = SizedBox(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
        ),
    );

    final background = 
    Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        backgroundBlendMode: BlendMode.darken,
        color: Colors.black38
      ),
      // child: Carousel(
      //   showIndicator: false,
      //   images: [
       child:  Image.asset("images/runner.png",
           fit: BoxFit.cover,
           color: Colors.black87,
           colorBlendMode: BlendMode.lighten,),
          //  AssetImage("images/runner.png",),
          //  AssetImage("images/images(8).jpg"),
          //  AssetImage("images/images(5).jpg"),
          //  AssetImage("images/images(3).jpg"),
      //   ],
      // ),
    );
    

    final logo = Hero(
        tag: "logo",
        child: Container(
          margin: EdgeInsets.only(bottom: 20.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: _animation.value * 70,
          backgroundImage: AssetImage("images/images(8).jpg"),
         
      ),
        ),       
    );

    final email = TextFormField(
          autocorrect: false,
          autofocus: false,
          keyboardType: TextInputType.emailAddress,
          controller: _username,
          validator: (value)=>value.isEmpty ? 'Email can\'t be empty' : null,
          onSaved: (value)=> _user = value,
          style: TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            //prefixIcon: Icon(Icons.email),
            hintText: "Enter email address",
            hintStyle: TextStyle(
              color: Colors.black87,
            ),
            prefixIcon: Icon(Icons.email),
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(34.0),
            )
          ),
    );

    final passfield = TextFormField(
          autocorrect: false,
          autofocus: false,
          obscureText: isObscuredText,
          controller: _password,
          validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
          onSaved: (val) => _pass = val,
          style: TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            prefixIcon:  Icon(Icons.lock),
            suffixIcon: GestureDetector(
              onTap: (){
                setState(() {
                    isObscuredText = !isObscuredText;          
                });
              },
              child: Icon(isObscuredText ? Icons.visibility : Icons.visibility_off),
            ),
            hintText: "Enter password",
            hintStyle: TextStyle(
              color: Colors.black87,
            ),
            fillColor: Colors.redAccent,
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(34.0)
            )
          ),
    );

    final loginBtn =  MaterialButton(
              minWidth: 500.0,
              height: 43.0,
              onPressed: (){
                setState(() {
                     _user = _username.text;
                     _pass = _password.text;
                     final form = formKey.currentState;
                        if (form.validate()) {
                        form.save();
                          // FirebaseHandler.signedIn(_user, _pass).then((value)
                          // => persistLogin("loggedIn").then((val){
                          //   try {
                          //     validateForm();
                          //   } catch (e) {
                          //   }
                          // }));
                          FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: _user,
                            password: _pass
                          ).then((successful){
                              persistLogin("loggedIn").then((onValue){
                                //logs user
                                validateForm();
                              });
                          }).catchError((onError){
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context)=> Register()));
                          });
                        }
                     
                     //print('Logged in Username: $_user and Password $_pass'); 
        
                });
              },
              color: Colors.lightBlueAccent,
              child: Text("Log In", style: TextStyle(color: Colors.white)),
          
    );

    final forgetPassword = FlatButton(
              child: Text("Forget password ?",style: TextStyle(color: Colors.white),),
              onPressed: (){
                print("Change your password");
              },
    );

    final register = FlatButton(
              child: Text("Register",style: TextStyle(color: Colors.white),),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Register()));
              },
    );


    return Container(
      key: Key("login"),
      //backgroundColor: Theme.of(context).primaryColor,
      child: Card(
        child: Theme(
          data: ThemeData(
            brightness: Brightness.dark,
            indicatorColor: Colors.white,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
               background,
               Container(
                 decoration: BoxDecoration(
                   shape: BoxShape.rectangle,
                   color: Colors.black45
                 ),
                 child: ListView(
                   children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                        child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                                logo,
                                Form(
                                  key: formKey,
                                 child: Column(   
                                   children: <Widget>[
                                     email,
                                    separator,
                                    passfield,
                                    separator,
                                    loginBtn,
                                   ],
                                 ),
                                ),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                        forgetPassword,
                                        Text("|",style: TextStyle(color: Colors.white),),
                                        register
                                  ],
                                )
                          ],
                        ),
                      ),
                    ),
                    
                 ],),
               ),
               
            ],
          ),
        ),
      ),
    );     
  }
}