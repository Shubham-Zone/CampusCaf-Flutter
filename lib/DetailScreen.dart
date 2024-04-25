import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/AnimationScreens/LocationScreen.dart';
import 'package:uuid/uuid.dart';

class DetailScreen extends StatefulWidget {
  final foodimg, foodname, price, desc, stockStatus, cat;
  const DetailScreen(this.foodimg, this.foodname, this.price, this.desc,
      this.stockStatus, this.cat,
      {super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  var y = 1;
  final FirebaseAuth auth = FirebaseAuth.instance;
  late DatabaseReference dbRef;
  late DatabaseReference dbRef2;
  late DatabaseReference dbRef3;
  late DatabaseReference dbRef4;
  late DatabaseReference StockItems;
  var uuid = const Uuid();
  String fee = "0";
  List<dynamic> list = [];
  bool itemAddedtofavt = false;
  String itemStockOut = "";
  String itemPrice = "";
  String userid = "";

  favtItems() async {
    dbRef3.onValue.listen((DatabaseEvent event1) {
      Map<dynamic, dynamic> map = event1.snapshot.value as dynamic;
      list.clear();
      list = map.values.toList();
      for (int i = 0; i < list.length; i++) {
        if (list[i]["foodname"] == widget.foodname) {
          itemAddedtofavt = true;
          break;
        } else {
          itemAddedtofavt = false;
        }
      }

      setState(() {});
    });
  }

  stockItems() async {
    StockItems.onValue.listen((DatabaseEvent event1) {
      itemStockOut = event1.snapshot.child("stockStatus").value.toString();

      setState(() {});
    });
  }

  foodPrice() {
    if (y == 1) {
      return widget.price;
    } else {
      return (int.parse(widget.price) * int.parse(y.toString())).toString();
    }
  }

  gettingFee() {
    DatabaseReference starCountRef = dbRef4;
    starCountRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      setState(() {
        fee = data.toString();
      });
    });
  }

  @override
  void initState() {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    userid = uid;
    dbRef =
        FirebaseDatabase.instance.ref().child("User").child(uid).child("cart");
    dbRef3 =
        FirebaseDatabase.instance.ref().child("User").child(uid).child("favt");
    dbRef2 = FirebaseDatabase.instance
        .ref()
        .child("User")
        .child(uid)
        .child("Totalamount");
    dbRef4 = FirebaseDatabase.instance.ref().child("Deliveryfee").child("fee");
    StockItems = FirebaseDatabase.instance
        .ref("Food")
        .child(widget.cat)
        .child(widget.foodname);
    favtItems();
    gettingFee();
    stockItems();
    super.initState();
  }

  @override
  void dispose() {
    dbRef3.onValue.drain();
    StockItems.onValue.drain();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);

    return Scaffold(
        body: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(
                height: 40,
              ),
              Text(
                "${widget.foodname}",
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Hero(
                tag: "FoodCard",
                child: SizedBox(
                    height: 200,
                    width: mediaQuery.size.width * 0.6,
                    child: Image.network("${widget.foodimg}")),
              ),
              Container(
                width: double.infinity,
                color: const Color.fromRGBO(230, 230, 231, 1.0),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: mediaQuery.size.width * 0.13,
                        height: 32,
                        child: Center(
                          child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  if (y != 1) {
                                    y = y - 1;
                                    foodPrice();
                                  } else {}
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  textStyle: TextStyle(
                                      fontSize: mediaQuery.size.height * 0.017),
                                  backgroundColor: const Color(0xFFDE6262),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              child: const Center(
                                  child: Text("-",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30)))
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Text(
                        "$y",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      SizedBox(
                        width: mediaQuery.size.width * 0.13,
                        height: 32,
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                y = y + 1;
                                foodPrice();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                textStyle: TextStyle(
                                    fontSize: mediaQuery.size.height * 0.017),
                                backgroundColor: const Color(0xFFDE6262),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            child: const Center(
                                child: Text("+",textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25)))),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Text("${widget.desc}", textAlign: TextAlign.center),
              const SizedBox(
                height: 25,
              ),
              const Text(
                "Price",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "RS",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 20),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  Text(
                    foodPrice(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 20),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              TextButton.icon(
                label: Text(
                  itemAddedtofavt ? "Favourite item" : "Add to favourite",
                  style: const TextStyle(color: Colors.pinkAccent),
                ),
                icon: Icon(
                  itemAddedtofavt ? Icons.favorite : Icons.favorite_outline,
                  size: 18,
                  color: Colors.pinkAccent,
                ),
                onPressed: () async {
                  Map<String, String> favt = {
                    "category": widget.cat,
                    "foodname": widget.foodname,
                  };

                  if (itemAddedtofavt) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Already added to favourite"),
                      duration: Duration(seconds: 2),
                      backgroundColor: Color(0xFFDE6262),
                    ));
                  } else {
                    dbRef3.child(widget.foodname).set(favt);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Added to favourite"),
                      duration: Duration(seconds: 2),
                      backgroundColor: Color(0xFFDE6262),
                    ));
                  }
                },
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () {
                        stockItems();
                        if (itemStockOut == "stock out") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Item out of stock"),
                              duration: Duration(seconds: 2),
                              backgroundColor: Color(0xFFDE6262),
                            ),
                          );
                        } else {
                          int delFee = int.parse(fee);
                          int totalAmount = int.parse(foodPrice()) + delFee;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LocationScreen(
                                  "$y ${widget.foodname}",
                                  totalAmount.toString(),
                                  userid),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        textStyle: TextStyle(
                          fontSize: mediaQuery.size.height * 0.017,
                        ),
                        backgroundColor: const Color(0xFFDE6262),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Order now",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () {
                        if (itemStockOut == "stock out") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Item out of stock"),
                              duration: Duration(seconds: 2),
                              backgroundColor: Color(0xFFDE6262),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Added to cart"),
                              duration: Duration(seconds: 2),
                              backgroundColor: Color(0xFFDE6262),
                            ),
                          );
                          Map<String, String> cart = {
                            "orderImage": widget.foodimg,
                            "price": widget.price,
                            "quantity": y.toString(),
                            "roll": widget.foodname,
                            "soldItemName": widget.foodname,
                          };
                          dbRef.child(widget.foodname).set(cart);
                          dbRef2.set("1");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        textStyle: TextStyle(
                          fontSize: mediaQuery.size.height * 0.017,
                        ),
                        backgroundColor: const Color(0xFFDE6262),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Add to cart",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
