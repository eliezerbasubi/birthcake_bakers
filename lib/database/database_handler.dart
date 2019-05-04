
import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:birthcake_bakers/models/products_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:sqflite/sqflite.dart';

class ProductDatabase{
    static final String tableName = "Favorites";
    static final String cartTable = "Carts";
    static bool isDuplicated = false; 

    static Database _database; // Helps to interface with SQLITE database
    static final ProductDatabase _instance = ProductDatabase._internal();

    //This factory allows to create multiple instance of database class, and 
    //allow to manage, insert and update of data
    factory ProductDatabase() => _instance; 

    //Getter method which allows to get the new instance of the database
    Future<Database> get db async{
      //Check if database already exists, or if it's equal to null
      //If it does not exist, populate the database variable

      if (_database != null) {
        return _database;
      }
        _database = await initDB();
        return _database; 
    }

    //Internal method to create an instance of the class name (ProductDatabase) inside itself
    ProductDatabase._internal();

    //initDB method creates and populates database
    Future<Database> initDB() async{
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path,"main.db");

      //Open physically database to the provided location
      var theDB = await openDatabase(path,version: 1,onCreate: _onCreate, onUpgrade: _onUpgrade);
      return theDB;
    }

    void _onCreate(Database db,int version) async{
      //create table for favorite products
      await db.execute("CREATE TABLE Favorites(id STRING PRIMARY KEY, name TEXT, price DOUBLE, prodURL TEXT, favored BIT)");
      
      //create table for products in cart
      await db.execute("CREATE TABLE $cartTable(id STRING PRIMARY KEY, name TEXT, price DOUBLE, prodURL TEXT, quantity INTEGER, discount DOUBLE)");
      
      print("Database successfully created");
    }

    void _onUpgrade(Database db, int version, int newVersion) async{
      await db.execute("DROP TABLE IF EXISTS $tableName");
      await db.execute("DROP TABLE IF EXISTS $cartTable");
      _onCreate(db, version);
    }

    //Adds products to database
    Future<int> addProductToFavorites (Model data) async {
      //Wrap with try-catch block, so that in case of failure, when the product
      //is present in the database, it will update that product,
      //instead of inserting it again.
      
      var client = await db;
      try {
        int result = await client.insert("$tableName", data.toMap());
        //check if the product is not duplicated
        isDuplicated =false;
        print("Product added $result");

        return result;
      } on Exception catch (e) {
         int result = await updateProduct(data);
         isDuplicated = true;
         print(e);
         return result;
      }
      
    }

    //Delete product when it's unfavoured
    Future<int> deleteProduct (String id) async{
      var clientDB = await db;
      var response = await clientDB.delete("$tableName",where: "id= ?",whereArgs: [id]);
      print("Product deleted $response");

      return response;
    }

    //Update product if it's already exist
    Future<int> updateProduct (Model data) async{
      var clientDB = await db;
      var response = await clientDB
          .update("$tableName", data.toMap(), where: "id= ?", whereArgs: [data.id]);

      print("Product updated $response");

      return response;
    }

    Future closeDB() async{
      var clientDB = await db;
      clientDB.close();
    }

    //Fetch products from database
    Future<List<Model>> retrieveFavorites()async{
      var clientDB = await db;
      List<Map> response = await clientDB.query(tableName);

      return response.map((r)=> Model.fromDB(r)).toList();
    }

    //Fetch single product
    Future<Model> retrieveItem(String id) async{
      var clientDB = await db;
      var result = await clientDB.query(tableName, where: "id= ?", whereArgs: [id]);

      if(result.length == 0) return null;
        return Model.fromDB(result[0]);
      }



  /*--- Start dealing with cart history ---*/
  Future<int> addToCart(Model data) async{
    var client = await db;
      try {
        int result = await client.insert("$cartTable", data.toCart());
        print("Product added $result");

        return result;
      } on Exception catch (e) {
         int result = await cartUpdate(data);
         print(e);
         return result;
      }
  }

  Future<int> cartUpdate (Model data) async{
      var clientDB = await db;
      var response = await clientDB
          .update("$cartTable", data.toCart(), where: "id= ?", whereArgs: [data.id]);

      print("Product updated $response");

      return response;
  }

  Future<int> deleteProductToCart (String id) async{
      var clientDB = await db;
      var response = await clientDB.delete("$cartTable",where: "id= ?",whereArgs: [id]);
      print("Product deleted $response");

      return response;
    }

  Future<List<Model>> getProductsInCart()async{
      var clientDB = await db;
      List<Map> response = await clientDB.query(cartTable);

      return response.map((r)=> Model.fromDB(r)).toList();
    }
  /*--- Finish dealing with cart history ---*/
}