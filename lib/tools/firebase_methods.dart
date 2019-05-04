import 'dart:async';

// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHandler {
  static String filename;
  static String path = "cakes";
  static String reviewPath = "reviews";
  static String userPath = "users";
  static String wishlistPath = "wishlist";
  static String itemID;
  static String orderPath = "orders";
  static String cardPath = "paymentCards";

  static bool isLoggedIn() {
    if (FirebaseAuth.instance.currentUser() != null) {
      return true;
    } else {
      return false;
    }
  }

  static Future signedIn(_email, _password) async {
    FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password);
  }

  static Future registerUsers(users /*, _email, _password*/) async {
    // FirebaseAuth.instance.createUserWithEmailAndPassword(
    //   email: _email,
    //   password: _password
    // ).then((create){
    CollectionReference userRef = Firestore.instance.collection("/$userPath");
    userRef.add(users);
    // });
  }

  static Future<void> addProducts(values) async {
    CollectionReference reference = Firestore.instance.collection(path);
    reference.add(values);
    Firestore.instance
        .collection(path)
        .add(values)
        .catchError((error) => print(error));
  }

  static popularProducts() async {
    try {
      return await Firestore.instance.collection(path).limit(4).getDocuments();
    } catch (e) {}
  }

  static fetchWeddingCakes() async {
    try {
      return Firestore.instance
          .collection(path)
          .where("category", isEqualTo: "wedding")
          .getDocuments()
          .catchError((onError) {
        print("wedding catched errors $onError");
      });
    } catch (e) {}
  }

  static fetchRomanticCakes() async {
    try {
      return Firestore.instance
          .collection(path)
          .where("category", isEqualTo: "romantic")
          .getDocuments()
          .catchError((onError) {
        print("romantic catched errors $onError");
      });
    } catch (e) {}
  }

  static fetchBirhdayCakes() async {
    try {
      return Firestore.instance
          .collection(path)
          .where("category", isEqualTo: "birthday")
          .getDocuments()
          .catchError((onError) {});
    } catch (e) {}
  }

  static recentCakes() async {
    try {
      return Firestore.instance
          .collection(path)
          .orderBy("timestamp", descending: false)
          .limit(5)
          .snapshots()
          .handleError((onError) {
        print("handled error is : $onError");
      });
    } catch (e) {}
  }

  //details item using ID
  static singleItemDetails(itemId) async {
    try {
      return Firestore.instance
          .collection(path)
          .document(itemId)
          .get()
          .catchError((onError) {
        print("An error has occured : $onError");
      });
    } catch (e) {}
  }

  //single item details using name
  static singleItemDetailsByName(itemName) async {
    return Firestore.instance
        .collection(path)
        .where("name", isEqualTo: itemName)
        .getDocuments()
        .catchError((onError) {});
  }

  // single category
  static singleCategory(categoryId) async {
    return Firestore.instance
        .collection(path)
        .where("category", isEqualTo: categoryId)
        // .orderBy("name", descending: true)
        .getDocuments()
        .catchError((onError) {});
  }

  //get current user details
  static currentUserDetails(currentUserID) async {
    return Firestore.instance
        .collection(userPath)
        .where("userID", isEqualTo: currentUserID)
        .orderBy("userID", descending: true)
        .getDocuments()
        .catchError((onError) {
      print(onError);
    });
  }


/* --- Start review part ---*/
  //Review a product
  static writeReview(reviews) async {
    return Firestore.instance.runTransaction((Transaction transactionHandler) {
      CollectionReference collectionReference =
          Firestore.instance.collection("/$reviewPath");
      collectionReference.add(reviews);
    });
  }

  //Avoid duplicate reviews
  static Future<bool> doesUserAlreadyRewiew(
      String userId, String productId) async {
      final QuerySnapshot result = await Firestore.instance
          .collection(reviewPath)
          .where('userID', isEqualTo: userId)
          .where('productID', isEqualTo: productId)
          .limit(1)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      return documents.length == 1;
  }

  //Check if the product has already been reviewed
  static Future<bool> doesItemAlreadyReviewed(String itemId) async {
    final QuerySnapshot result = await Firestore.instance
        .collection(reviewPath)
        .where("productID", isEqualTo: itemId)
        .limit(1)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    return documents.length == 1; //if it exists
  }

  //get 4 latest reviews
  static latestReviews(productID) async {
    try {
      return Firestore.instance
          .collection(reviewPath)
          .where("productID", isEqualTo: productID)
          .orderBy("timeStamp", descending: true)
          .limit(3)
          .snapshots()
          .handleError((onError) {});
    } catch (e) {}
  }

  static sizeOfReviews(productID) async {
    return Firestore.instance
        .collection(reviewPath)
        .where("productID", isEqualTo: productID)
        .orderBy("timeStamp", descending: true)
        .snapshots().handleError((onError){});
  }

  static getAllReviews(productID) async {
    return Firestore.instance.collection(reviewPath)
          .where("productID", isEqualTo: productID)
          .orderBy("timeStamp", descending: true)
          .snapshots()
          .handleError((onError) {});
  }
/*--- End review part ---*/

/*--- Start search product part ---*/

  //data search
  static searchByProductName() async {
    return Firestore.instance.collection(path).getDocuments();
  }

  //recently searched cakes
  static recentlySearchedCakes() async {
    try {
      return Firestore.instance
          .collection(path)
          .orderBy("timestamp", descending: false)
          .limit(5)
          .getDocuments();
    } catch (e) {}
  }
/*--- End search product part ---*/

/*--- Start wishlist part ---*/
  //Add product to wishlist or favorites
  static addWishlist(data) async {
    return Firestore.instance.runTransaction((Transaction transaction){
      CollectionReference reference =  Firestore.instance.collection("/$wishlistPath");
      reference.add(data);
    });
  }


  //Check if item already exists in wishlist. If so, update it or delete it.
  static Future<bool> itemAlreadyFavored(userId, itemId) async {
    final QuerySnapshot result = await Firestore.instance
        .collection(wishlistPath)
        .where("favoredID", isEqualTo: itemId)
        .where("favoredUser", isEqualTo: userId)
        .limit(1)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    return documents.length == 1; //if it exists
  }

/*--- End wishlist part ---*/

/*--- Start user profile part ---*/

  static getUserInfo(connectedUserID) async{
    return Firestore.instance.collection(userPath)
          .where("userID", isEqualTo :connectedUserID)
          // .orderBy("phone", descending: false)
          .limit(1)
          .getDocuments();
  }
/*--- End user profile part ---*/

/*--- Start order part ---*/
  static Future orderProduct(data) async{
    return Firestore.instance.runTransaction((Transaction transaction){
      CollectionReference collectionReference =Firestore.instance.collection("/$orderPath");
      collectionReference.add(data);
    });
  }

  static Future updateOrderShippingStatus(orderID, status) async{
    return Firestore.instance.collection(orderPath).document(orderID).updateData(status);
  }

  static Future savePaymentCard(card) async{
    return Firestore.instance.runTransaction((Transaction transaction){
      CollectionReference reference =Firestore.instance.collection("/$cardPath");
      reference.add(card);
    });
  }

  //check if payment card exists
  static Future<bool> paymentCardExists(cardNumber) async{
    final QuerySnapshot result = await Firestore.instance
        .collection(cardPath)
        .where("cardNumber", isEqualTo: cardNumber)
        .limit(1)
        .getDocuments();

    List<DocumentSnapshot> docs =result.documents;
    return docs.length == 1;
  }
/*--- End order part ---*/ 
}
