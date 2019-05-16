import 'dart:io';

import 'package:birthcake_bakers/models/products_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class AdminPart extends StatefulWidget {
  @override
  _AdminPartState createState() => _AdminPartState();
}

class _AdminPartState extends State<AdminPart> {
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController prodName, prodPrice, oldPrice, prodQty, discount, desc;
  String id, name, price, previousPrice, quantity, discountPrice, description;
  String category;
  var now;
  List<String> categories = ["birthday", "romantic", "wedding"];
  File galleryFile, croppedFile;
  Map<String, dynamic> products = new Map<String, dynamic>();

  String platformMessage = 'No Error';
  List images;
  int maxImageNo = 10;
  bool selectSingleImage = false;

  @override
  void initState() {
    super.initState();

    initializeFields();

    //print now and timestamp
    
    category = categories[0];
  }

  imageSelectorGallery() async {
    try {
      galleryFile = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 400,
        maxWidth: 400
      );
      // print("Image size ${galleryFile.lengthSync()}");
    } catch (e) {}
    setState(() {});
  }

  void initializeFields() {
    prodName = TextEditingController();
    prodPrice = TextEditingController();
    oldPrice = TextEditingController();
    prodQty = TextEditingController();
    discount = TextEditingController();
    desc = TextEditingController();
  }

  getTimeStamp() {
    setState(() {
      now = new DateTime.now().microsecondsSinceEpoch;
    });
  }

  // initMultiPickUp() async {
  //   try {
  //     setState(() {
  //       images = null;
  //       platformMessage = 'No Error';
  //     });
  //     List resultList;
  //     String error;
  //     try {
  //       resultList = await FlutterMultipleImagePicker.pickMultiImages(
  //           maxImageNo, selectSingleImage);
  //     } on PlatformException catch (e) {
  //       error = e.message;
  //     }

  //     if (!mounted) return;

  //     setState(() {
  //       images = resultList;
  //       if (error == null) platformMessage = 'No Error Dectected';
  //     });
  //   } catch (e) {}
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Add products"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Stack(
              fit: StackFit.loose,
              overflow: Overflow.visible,
              children: <Widget>[
                //Display custom image if user has not yet selected a profile image
                galleryFile == null
                    ? Image.asset("images/images(8).jpg")
                    : Image.file(galleryFile,
                        width: MediaQuery.of(context).size.width,
                        height: 250,
                        fit: BoxFit.cover),

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

            SizedBox(
              height: 30,
            ),

            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Add sub images of the product (optional)",
                  style: TextStyle(color: Colors.grey),
                ),

                //Multi image picker
                CircleAvatar(
                  radius: 25,
                  child: IconButton(
                    onPressed: (){
                      // initMultiPickUp();
                    },
                    icon: Icon(Icons.linked_camera),
                  ),
                ),
              ],
            ),

            //Container to hold mutli image pictures
            Container(
              width: MediaQuery.of(context).size.width,
              height: 120,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: ClampingScrollPhysics(),
                    itemCount: 4,
                    itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Image.asset(
                            data[index].prodURL,
                            key: Key(index.toString()),
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                        )),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: prodName,
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: "Enter product name",
              ),
            ),
            TextField(
              controller: prodPrice,
              onChanged: (value) {
                setState(() {
                  price = value;
                });
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter product price",
              ),
            ),
            TextField(
              controller: oldPrice,
              onChanged: (value) {
                setState(() {
                  previousPrice = value;
                });
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter product old price",
              ),
            ),
            TextField(
              controller: discount,
              onChanged: (value) {
                setState(() {
                  discountPrice = value;
                });
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter product discount",
              ),
            ),
            TextField(
              controller: prodQty,
              onChanged: (value) {
                setState(() {
                  quantity = value;
                });
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter product quantity",
              ),
            ),
            TextField(
              controller: desc,
              onChanged: (value) {
                setState(() {
                  description = value;
                });
              },
              keyboardType: TextInputType.text,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Write description of the product",
              ),
            ),
            DropdownButton(
                hint: Text("Category"),
                value: category,
                onChanged: (String value) {
                  setState(() {
                    category = value;
                  });
                },
                items: categories
                    .map((cat) => DropdownMenuItem(
                          child: Text(cat),
                          value: cat,
                        ))
                    .toList()),
            RaisedButton(
              child: Text("Add product"),
              onPressed: () async {
                getTimeStamp();
                try {
                  StorageReference storageReference = FirebaseStorage.instance
                      .ref()
                      .child("/product_images")
                      .child("_img$now");
                  StorageUploadTask uploadTask =
                      storageReference.putFile(galleryFile);
                  StorageTaskSnapshot storageTaskSnapshot =
                      await uploadTask.onComplete;
                  String downloadUrl =
                      await storageTaskSnapshot.ref.getDownloadURL();
                  // if (uploadTask.isComplete) {
                  // print("file url is ${storageReference.getDownloadURL().toString()}");

                  //run transaction to allow instant updation of values in database
                  Firestore.instance.runTransaction((transactionHandler) async {
                    CollectionReference reference =
                        Firestore.instance.collection("/cakes");

                    products = {
                      "name": name.toLowerCase(),
                      "price": price,
                      "quantity": quantity,
                      "discount": discountPrice,
                      "oldPrice": previousPrice,
                      "description": description,
                      "category": category,
                      "productURL": downloadUrl,
                      "isfavored": false,
                      "timestamp": now,
                    };

                    reference.add(products);
                  });

                  if (uploadTask.isComplete) {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("$name successfully uploaded"),
                    ));
                  }
                } catch (e) {}
              },
            )
          ],
        ),
      ),
    );
  }
}
