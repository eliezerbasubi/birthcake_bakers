// import 'dart:async';
import 'dart:io';

import 'package:birthcake_bakers/screens/login.dart';
import 'package:birthcake_bakers/tools/firebase_methods.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dropdown.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  ScrollController _scrollController;
  //Country _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode('tr');
  static TextEditingController fname,
      passController,
      confirmController,
      email,
      pnumber,
      location;
  String fstname,
      pass,
      confirmPass,
      emailAdd,
      phoneNum,
      locPosition,
      countryCode;

  final formKey = GlobalKey<FormState>();

  bool setObscureText = true, isObscureText = true;

  File galleryFile,croppedFile;
  Map<String, dynamic> users = Map<String, dynamic>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
        debugLabel: "Scrolling environment",
        initialScrollOffset: 250,
        keepScrollOffset: true);

    initControllers();
  }

  initControllers() {
    fname = TextEditingController();
    passController = TextEditingController();
    confirmController = TextEditingController();
    email = TextEditingController();
    pnumber = TextEditingController();
    location = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {


    //Display images selected from gallery
    imageSelectorGallery() async {
      try {
        galleryFile = await ImagePicker.pickImage(
          source: ImageSource.gallery,
          maxHeight: 400,
          maxWidth: 400
        );
        // croppedFile = await ImageCrop.cropImage().then((onValue){
        //   print(onValue);
        // });
      } catch (e) {}
      setState(() {});
    }

    void clearFields() {
      fname.clear();
      email.clear();
      location.clear();
      pnumber.clear();
      passController.clear();
      confirmController.clear();
    }

    void validateForm() {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));

      clearFields();
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

    var firstName = TextFormField(
      autocorrect: false,
      autofocus: false,
      autovalidate: true,
      controller: fname,
      keyboardType: TextInputType.text,
      maxLines: 1,
      onSaved: (fstValue) => fstname = fstValue,
      validator: (nameValue) {
        // if (nameValue.isEmpty) return "Name should not be empty";
        // final RegExp nameExpression = new RegExp(r'^[A-Za-z]+$');
        // if (!nameExpression.hasMatch(nameValue))
        //   return "Name should contain letters only";
        // return null;
      },
      decoration: InputDecoration(
          border: UnderlineInputBorder(),
          hintText: "What do people call you",
          labelText: "Full Name *",
          icon: Icon(Icons.account_circle),
          filled: true),
    );

    var phoneNumber = Row(
      children: <Widget>[
        CountryPickerDropdown(
          initialValue: 'cd',
          itemBuilder: _buildDropdownItem,
          onValuePicked: (Country country) {
            countryCode = country.phoneCode;
          },
        ),
        SizedBox(
          width: 8.0,
        ),
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.phone,
            controller: pnumber,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
                labelText: "Phone *",
                hintText: "How should we reach you",
                filled: true),
            onSaved: (phoneValue) => this.phoneNum = phoneValue,
          ),
        )
      ],
    );

    var emailAddress = TextFormField(
      autocorrect: false,
      autofocus: false,
      autovalidate: true,
      controller: email,
      keyboardType: TextInputType.emailAddress,
      maxLines: 1,
      onSaved: (emValue) => emailAdd = emValue,
      validator: (val) => !val.contains("@") ? "Invalid email" : null,
      decoration: InputDecoration(
          border: UnderlineInputBorder(),
          hintText: "What's your email address",
          labelText: "Email *",
          icon: Icon(Icons.mail),
          filled: true),
    );

    var locationAddress = TextFormField(
      autocorrect: false,
      autofocus: false,
      autovalidate: true,
      controller: location,
      keyboardType: TextInputType.text,
      maxLines: 1,
      onSaved: (locValue) => locPosition = locValue,
      decoration: InputDecoration(
          border: UnderlineInputBorder(),
          hintText: "Where would we deliver cakes ",
          labelText: "Official location *",
          icon: Icon(Icons.location_on),
          filled: true),
    );

    var password = TextFormField(
      autocorrect: false,
      autofocus: false,
      autovalidate: false,
      obscureText: setObscureText,
      controller: passController,
      keyboardType: TextInputType.text,
      maxLines: 1,
      maxLength: 8,
      onSaved: (passwordInput) => passwordInput = pass,
      validator: (value) {
        if (value.isNotEmpty) {
          if (value.length < 8) {
            return "Short password";
          } else {
            return null;
          }
        }
      },
      decoration: InputDecoration(
          border: UnderlineInputBorder(),
          hintText: "Protect your account ",
          labelText: "Password *",
          helperText: "8 characters containing lowercase and uppercase",
          icon: Icon(Icons.lock_open),
          filled: true,
          suffixIcon: InkWell(
            onTap: () {
              setState(() {
                setObscureText = !setObscureText;
              });
            },
            child:
                Icon(setObscureText ? Icons.visibility : Icons.visibility_off),
          )),
    );

    var confirmPassword = TextFormField(
      autocorrect: false,
      autofocus: false,
      autovalidate: false,
      //enabled: this.pass != null && this.pass.isNotEmpty,
      obscureText: isObscureText,
      controller: confirmController,
      keyboardType: TextInputType.text,
      maxLines: 1,
      maxLength: 8,
      // validator: (confirmInput){
      //   if(confirmInput.isNotEmpty){
      //     if (confirmInput != this.pass) {
      //       return "Password does not match";
      //     } else {
      //       return "Correct password";
      //     }
      //   }
      // },
      onSaved: (value) => confirmPass = value,
      decoration: InputDecoration(
          border: UnderlineInputBorder(),
          hintText: "Validate your password",
          labelText: "Confirm password *",
          icon: Icon(Icons.enhanced_encryption),
          filled: true,
          suffixIcon: InkWell(
            onTap: () {
              setState(() {
                isObscureText = !isObscureText;
              });
            },
            child:
                Icon(isObscureText ? Icons.visibility : Icons.visibility_off),
          )),
    );

    var register = Material(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        child: MaterialButton(
          child: Text(
            "Register",
            style: TextStyle(
                color: Colors.white, fontFamily: "Hind-Regular", fontSize: 18),
          ),
          color: Theme.of(context).primaryColor,
          elevation: 6,
          padding: EdgeInsets.all(5.0),
          minWidth: 400,
          height: 40,
          animationDuration: Duration(minutes: 1),
          clipBehavior: Clip.antiAlias,
          onPressed: () async {
            StorageReference storageReference = FirebaseStorage.instance
                .ref()
                .child("/user_profiles")
                .child("_img${passController.text}");
            StorageUploadTask uploadTask =
                storageReference.putFile(galleryFile);
            StorageTaskSnapshot storageTaskSnapshot =
                await uploadTask.onComplete;
            String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();


            setState(() {
              final form = formKey.currentState;
              //Store variables in a map
              fstname = fname.text;
              phoneNum = "$countryCode${pnumber.text}";
              emailAdd = email.text;
              pass = passController.text;
              locPosition = location.text;

              if (fstname.isEmpty ||
                  phoneNum.isEmpty ||
                  emailAdd.isEmpty ||
                  locPosition.isEmpty) {
                print("fields are all empty");
              } else {
                if (form.validate()) {
                  form.save(); //save all variables
                  //Store user profile

                  //Create user with email and password
                  FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: emailAdd, password: pass)
                      .then((user) {
                    setState(() {
                      //Save user's details in firestore database
                      users = {
                        "userID" : user.uid,
                        "firstname": fstname,
                        "password": pass,
                        "email": emailAdd,
                        "phone": phoneNum,
                        "location": locPosition,
                        "timeStamp": DateTime.now().millisecondsSinceEpoch,
                        "profilePic": downloadUrl
                      };

                      FirebaseHandler.registerUsers(users).then((complete) {
                        
                        if (uploadTask.isComplete) {
                          validateForm();
                        }
                      });
                    });
                  });
                }
              }
            });
          },
        ));

    var facebook = Material(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        child: MaterialButton(
          child: Text(
            "Facebook",
            style: TextStyle(
                color: Colors.white, fontFamily: "Hind-Regular", fontSize: 18),
          ),
          color: Colors.blue,
          elevation: 6,
          padding: EdgeInsets.all(5.0),
          minWidth: 400,
          height: 40,
          animationDuration: Duration(minutes: 1),
          clipBehavior: Clip.antiAlias,
          onPressed: () {},
        ));

    return Scaffold(
      appBar: AppBar(
        title: Text("Register Account"),
        automaticallyImplyLeading: true,
        toolbarOpacity: 0.8,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          child: Column(
            children: <Widget>[
              Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    Stack(
                      fit: StackFit.loose,
                      overflow: Overflow.visible,
                      children: <Widget>[
                        //Display custom image if user has not yet selected a profile image
                        InkWell(
                          onTap: () {
                            setState(() {
                              Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                      opaque: false,
                                      pageBuilder: (context, _, __) {
                                        Material(
                                          color: Colors.black38,
                                          child: Container(
                                            height: 400,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                80,
                                            child: galleryFile == null
                                                ? Image.asset(
                                                    "images/images(8).jpg")
                                                : Image.file(galleryFile,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    height: 250,
                                                    fit: BoxFit.cover),
                                          ),
                                        );
                                      }));
                            });
                          },
                          child: galleryFile == null
                              ? Image.asset("images/images(8).jpg")
                              : Image.file(galleryFile,
                                  width: MediaQuery.of(context).size.width,
                                  height: 250,
                                  fit: BoxFit.cover),
                        ),

                        Positioned(
                          right: 10.0,
                          bottom: -25.0,
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.black,

                            //open and display images in flutter
                            child: IconButton(
                              icon: Icon(
                                Icons.photo_camera,
                                size: 35,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                imageSelectorGallery();
                              },
                            ),
                          ),
                        )
                      ],
                    ),

                    //other components into padding
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: <Widget>[
                            firstName,
                            SizedBox(
                              height: 10,
                            ),
                            phoneNumber,
                            SizedBox(
                              height: 10,
                            ),
                            emailAddress,
                            SizedBox(
                              height: 10,
                            ),
                            locationAddress,
                            SizedBox(
                              height: 10,
                            ),
                            password,
                            SizedBox(
                              height: 10,
                            ),
                            confirmPassword,
                            SizedBox(
                              height: 30,
                            ),
                            register,
                            SizedBox(
                              height: 20,
                            ),
                            facebook
                          ],
                        )),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
