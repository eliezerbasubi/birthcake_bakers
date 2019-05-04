
class Model {
   final String id;
   final String name;
   final  double price;
   final String desc;
   final String prodURL;
   final String monthYear;
   final double discount;
   final String oldPrice;
   final int quantity;
   final bool favored;


   Model({this.id,this.name,this.price,this.desc,this.prodURL,this.monthYear,
          this.discount,this.oldPrice,this.quantity,this.favored});
  
  Map<String, dynamic> toMap(){
    var map = Map<String,dynamic>();
    map['id'] = id;
    map['name'] = name;
    map['price'] = price;
    map['prodURL'] = prodURL;
    map['favored'] = favored;

    return map;
  }

  //Map products into cart
  Map<String, dynamic> toCart(){
    var carts = Map<String, dynamic>();
    carts['id'] = id;
    carts['name'] = name;
    carts['price'] = price;
    carts['prodURL'] = prodURL;
    carts['quantity'] =quantity;
    carts['discount'] =discount;

    return carts;
  }

  Model.fromDB(Map map)
  : id = map['id'].toString(),
    name = map['name'],
    price = map['price'],
    prodURL = map['prodURL'],
    favored = map['favored'] == 1 ? true : false,
    desc = map['desc'],
    monthYear = map['monthYear'],
    discount = map['discount'],
    oldPrice = map['oldPrice'],
    quantity = map['quantity'];
}



List<Model> data = [
  Model(
    name: "Cake Margeritta",
    price: 25.0,
    desc: "Cake Margeritta small size, aromatic smell, full triangle...",
    prodURL: "images/images.jpg",
    monthYear: "Dec/2018",
    discount: 45,
    oldPrice: "35",
    quantity: 1,
  ),

  Model(
    name: "Cake Capuccino",
    price: 15.0,
    desc: "Cake Capuccino small size, aromatic smell, full triangle...",
    prodURL: "images/images(2).jpg",
    monthYear: "Feb/2018",
    discount: 65,
    oldPrice: "35",
    quantity: 1,
  ),

  Model(
    name: "Lovely cake",
    price: 10.0,
    desc: "Cake Milk small size, aromatic smell, full triangle...",
    prodURL: "images/images(3).jpg",
    monthYear: "Mar/2018",
    discount: 65,
    oldPrice: "35",
    quantity: 1,
  ),

  Model(
    name: "Cute Magenta",
    price: 25.0,
    desc: "Cake Margeritta small size, aromatic smell, full triangle...",
    prodURL: "images/images(4).jpg",
    monthYear: "Dec/2018",
    discount: 45,
    oldPrice: "35",
    quantity: 1,
  ),

  Model(
    name: "Romance Capuccino",
    price: 15.0,
    desc: "Cake Capuccino small size, aromatic smell, full triangle...",
    prodURL: "images/images(5).jpg",
    monthYear: "Jan/2018",
    discount: 85,
    oldPrice: "25",
    quantity: 1,
  ),

  Model(
    name: "Neige Milk",
    price: 3.0,
    desc: "Cake Milk small size, aromatic smell, full triangle...",
    prodURL: "images/images(6).jpg",
    monthYear: "Mar/2018",
    discount: 5,
    oldPrice: "6",
    quantity: 1,
  ),

    Model(
    name: "Fireworks Margeritta",
    price: 75.0,
    desc: "Cake Margeritta small size, aromatic smell, full triangle...",
    prodURL: "images/images(7).jpg",
    monthYear: "Nov/2018",
    discount: 15,
    oldPrice: "105",
    quantity: 1,
  ),

  Model(
    name: "Maigrainas Cabulas",
    price: 75.0,
    desc: "Cake Capuccino small size, aromatic smell, full triangle...",
    prodURL: "images/images(8).jpg",
    monthYear: "Oct/2018",
    discount: 82,
    oldPrice: "5",
    quantity: 1
  ),

  Model(
    name: "Tequila",
    price: 80.0,
    desc: "Cake Milk small size, aromatic smell, full triangle...",
    prodURL: "images/images(9).jpg",
    monthYear: "Mar/2018",
    discount: 12,
    oldPrice: "985",
    quantity: 1
  ),

  Model(
    name: "Expresso",
    price: 125.0,
    desc: "Cake Margeritta small size, aromatic smell, full triangle...",
    prodURL: "images/images(10).jpg",
    monthYear: "Dec/2018",
    discount: 15,
    oldPrice: "325",
    quantity: 1
  ),

  Model(
    name: "Mayonnaise",
    price: 69.0,
    desc: "Cake Capuccino small size, aromatic smell, full triangle...",
    prodURL: "images/images(11).jpg",
    monthYear: "Feb/2018",
    discount: 95,
    oldPrice: "45",
    quantity: 1
  ),

  Model(
    name: "Cheese Cake",
    price: 25.0,
    desc: "Cake Milk small size, aromatic smell, full triangle...",
    prodURL: "images/images(12).jpg",
    monthYear: "Sept/2018",
    discount: 10,
    oldPrice: "35",
    quantity: 1
  ),

  
];




//Easter nest cake recipe
//german chocolate cake
//black forest cake recipe
//chocolate and meringue cream layer cake
//Mint patty cake recipe | taste of home
//Strawberry tuxedo cake : image(4)
//Triple chocolate ice cream cake  6
//pick & mix chocolate and sweet cake recipe 5
//walnut caramel mirror cake 7
//Strawberry chocolate mirror cake 8
//Summer sangria cake 9
//Caramello cake 10
//Raspberry valentine's cake 12
//Boozy coffe & walnut cake recipe 11
//unicorn cake 13
//the birhday cake 14
//Easy chocolate cake recipe | black forest cake 15
//Heart shaped choco truffle cake | dark magic cake 16
//S'moores cake recipe 17
//Traditional strawberry fraisier cake | sainsbury's 18
//Gergia's cake 19
//Chocolate strawberry cake | give recipe 20
//Reese's cake recipe | southern livin  22
//Unicorn face cake 21
//Fresh handmade 6" white cigarette 23
//Wedding cake 
//Woodland christmas yule log cake 24
  