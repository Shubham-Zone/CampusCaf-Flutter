import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_projects/NavigationScreen.dart';
import 'AnimationScreens/LocationScreen.dart';
import 'dart:ui' as ui;

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {

  late DatabaseReference dbRef;
  late DatabaseReference dbRef2;
  late DatabaseReference dbRef3;
  late DatabaseReference dbRef4;
  int val3 = 0;
  var foodlist = "";
  final FirebaseAuth auth = FirebaseAuth.instance;
  List<dynamic> list = [];
  String xx = "";
  String fee = "0";
  String uid = "";
  int quantity = 0;
  bool screenVsb = false;
  bool loader = true;


  totalAmt() async {

    dbRef4 = FirebaseDatabase.instance.ref().child("User").child(xx).child("cart");
    dbRef2 = FirebaseDatabase.instance
        .ref()
        .child("User")
        .child(xx)
        .child("Totalamount");

    dbRef4.onValue.listen((DatabaseEvent event1) {
      Map<dynamic, dynamic> map = event1.snapshot.value ?? {} as dynamic;
      list.clear();
      val3 = 0;
      foodlist = "";
      list = map.values.toList();
      if (list.isNotEmpty) {
        for (int i = 0; i < list.length; i++) {
          var val = list[i]["quantity"];
          var val2 = list[i]["price"];
          var val4 = list[i]["soldItemName"];
          val3 += int.parse(val) * int.parse(val2);
          print("1");
          foodlist += " $val $val4,";
        }
        setState(() {});
      } else {
        dbRef2.set("0");
      }
      dbRef2.set(val3);
    });
  }

  gettingFee() {
    DatabaseReference starCountRef = dbRef3;
   starCountRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      setState(() {
        fee = data.toString();
      });
    });
  }

  dbReferences() {
    final User? user = auth.currentUser;
    uid = user!.uid;
    xx = uid;

    dbRef =
        FirebaseDatabase.instance.ref().child("User").child(uid).child("cart");
    dbRef2 = FirebaseDatabase.instance
        .ref()
        .child("User")
        .child(xx)
        .child("Totalamount");
    dbRef3 = FirebaseDatabase.instance.ref().child("Deliveryfee").child("fee");
  }

  @override
  void initState() {

    //declaring database references
    dbReferences();

    //Calculating total amount
    totalAmt();

    //getting delivery fee
    gettingFee();

    RenderErrorBox.backgroundColor = Colors.transparent;
    RenderErrorBox.textStyle = ui.TextStyle(color: Colors.transparent);
    ErrorWidget.builder = (FlutterErrorDetails details) => const Center(
          child: Center(
            child: Text("SOMETHING WENT WRONG ):"),
          ),
        );
    super.initState();

  }



  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);

    return WillPopScope(
      onWillPop: () async {
        onBackPressed(); // Action to perform on back pressed
        return false;
      },

      child: Scaffold(

        appBar: AppBar(
          title: const Text(
            "Cart",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 28, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.shopping_cart,
                color: Color.fromRGBO(238, 93, 86, 1.0),
              ),
              onPressed: () {
                // do something
              },
            )
          ],
        ),

        body: MediaQuery.of(context).orientation == Orientation.portrait
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: mediaQuery.size.height * 0.57,
                      margin:
                          const EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: FutureBuilder(
                          future: dbRef.get(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DataSnapshot> snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              Map<String, dynamic> data = {};
                              if (!snapshot.hasData || snapshot.data == null) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if(snapshot.data!.value != null) {
                                data = Map<String, dynamic>.from(snapshot.data!.value as Map<Object?, Object?>);
                              }
                              if (data.keys.isEmpty) {
                                return const Center(
                                  child: Text("No item is added ):"),
                                );
                              } else {
                                return ListView(
                                  shrinkWrap: true,
                                  children: data.keys
                                      .map<Widget>((String uid) => Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                top: 2,
                                                left: 1,
                                                right: 1,
                                                bottom: 5,
                                              ),
                                              width: double.infinity,
                                              height: 115,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.withOpacity(0.4),
                                                    spreadRadius: 3,
                                                    blurRadius: 15,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  const SizedBox(width: 20),
                                                  FadeInImage.assetNetwork(
                                                    placeholder: 'assets/gifs/loading3.gif',
                                                    image: '${data[uid]["orderImage"]}',
                                                    height: 80,
                                                    width: 80,
                                                  ),
                                                  const SizedBox(width: 15),
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "${data[uid]["soldItemName"]}",
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        "Quantity:${data[uid]["quantity"]}",
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 15,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Row(
                                                        children: [
                                                          const Text(
                                                            "Price:",
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                          Text(
                                                            "Rs${data[uid]["price"]}",
                                                            style: const TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 15,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const Spacer(),
                                                  Transform.scale(
                                                    scale: 1.2,
                                                    child: IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          dbRef.child(uid).remove().whenComplete(() {
                                                            setState(() {
                                                              totalAmt();
                                                              // list.removeLast();
                                                            });
                                                            // if (list.isEmpty) {
                                                            //   dbRef2.set("0");
                                                            // }
                                                          });
                                                        });
                                                      },
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                      alignment: Alignment.bottomRight,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 20),
                                                ],
                                              ),
                                            ),

                                  ))
                                      .toList(),
                                );
                              }
                            }
                            return const Center(
                                child: CircularProgressIndicator());
                          }),
                    ),

                    Expanded(
                      child: Container(
                        height: mediaQuery.size.height * 0.4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.only(bottom: 2),
                        // padding: EdgeInsets.only(left: 5,right: 5),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Subtotal",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        "Delivery Fee",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        "Total",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          const Icon(Icons.currency_rupee_sharp, color: Colors.grey),
                                          Text(
                                            val3.toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          const Icon(Icons.currency_rupee_sharp, color: Colors.grey),
                                          Text(
                                            fee,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          const Icon(Icons.currency_rupee, color: Colors.red),
                                          Text(
                                            (val3 + int.parse(fee)).toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 50,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (list.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Cart is empty"),backgroundColor:  Color(0xFFDE6262),
                                        ),
                                      );
                                      // dbRef2.set("0");
                                    } else {
                                      print((val3 + int.parse(fee)).runtimeType);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LocationScreen(
                                            foodlist,
                                            (val3 + int.parse(fee)).toString(),
                                            xx,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    textStyle: const TextStyle(fontSize: 16),
                                    backgroundColor: const Color(0xFFDE6262),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 5,
                                    shadowColor: Colors.grey.withOpacity(0.5),
                                  ),
                                  child: const Text(
                                    "ENTER LOCATION",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),


                  ],
                ),
              )

            : SingleChildScrollView(

                scrollDirection: Axis.vertical,

                child: Center(

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Container(
                        height: mediaQuery.size.height * 0.57,
                        margin: const EdgeInsets.only(
                            top: 10, left: 10, right: 10),
                        child: FutureBuilder(
                            future: dbRef.get(),
                            builder: (BuildContext context,
                                AsyncSnapshot<DataSnapshot> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                Map<String, dynamic> data = {};
                                if(snapshot.data!.value != null) {
                                  data = Map<String, dynamic>.from(snapshot.data!.value as Map<Object?, Object?>);
                                }
                                if (data.keys.isEmpty) {
                                  return const Center(
                                    child: Text("No item is added ):"),
                                  );
                                } else {
                                  return ListView(
                                    shrinkWrap: true,
                                    children: data.keys
                                        .map<Widget>((String uid) => Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                  top: 2,
                                                  left: 1,
                                                  right: 1,
                                                  bottom: 5,
                                                ),
                                                width: double.infinity,
                                                height: 115,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(20),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey.withOpacity(0.4),
                                                      spreadRadius: 3,
                                                      blurRadius: 15,
                                                      offset: const Offset(0, 8),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(width: 20),
                                                    FadeInImage.assetNetwork(
                                                      placeholder: 'assets/gifs/loading3.gif',
                                                      image: '${data[uid]["orderImage"]}',
                                                      height: 80,
                                                      width: 80,
                                                    ),
                                                    const SizedBox(width: 15),
                                                    Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          "${data[uid]["soldItemName"]}",
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          "Quantity:${data[uid]["quantity"]}",
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 15,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Row(
                                                          children: [
                                                            const Text(
                                                              "Price:",
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                            Text(
                                                              "Rs${data[uid]["price"]}",
                                                              style: const TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 15,
                                                                color: Colors.red,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const Spacer(),
                                                    Transform.scale(
                                                      scale: 1.2,
                                                      child: IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            dbRef.child(uid).remove().whenComplete(() {
                                                              setState(() {
                                                                totalAmt();
                                                                // list.removeLast();
                                                              });
                                                              // if (list.isEmpty) {
                                                              //   dbRef2.set("0");
                                                              // }
                                                            });
                                                          });
                                                        },
                                                        icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                        ),
                                                        alignment: Alignment.bottomRight,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 20),
                                                  ],
                                                ),
                                              ),
                                    ))
                                        .toList(),
                                  );
                                }
                              }
                              return const Center(
                                  child: CircularProgressIndicator());
                            }),
                      ),

                      Container(
                        // height: mediaQuery.size.height * 0.4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.only(bottom: 2),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Subtotal",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        "Delivery Fee",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        "Total",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          const Icon(Icons.currency_rupee_sharp, color: Colors.grey),
                                          Text(
                                            val3.toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          const Icon(Icons.currency_rupee_sharp, color: Colors.grey),
                                          Text(
                                            fee,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          const Icon(Icons.currency_rupee, color: Colors.red),
                                          Text(
                                            (val3 + int.parse(fee)).toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 50,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (list.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Cart is empty"),backgroundColor:  Color(0xFFDE6262)
                                        ),
                                      );
                                      // dbRef2.set("0");
                                    } else {

                                      int delFee = int.parse(fee);
                                              // int totalAmount = int.parse(foodPrice()) + delFee;

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LocationScreen(
                                            foodlist,
                                            val3 + int.parse(fee),
                                            xx,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    textStyle: const TextStyle(fontSize: 16),
                                    backgroundColor: const Color(0xFFDE6262),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 5,
                                    shadowColor: Colors.grey.withOpacity(0.5),
                                  ),
                                  child: const Text(
                                    "ENTER LOCATION",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),


                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void onBackPressed() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const NavigationScreen()));
  }
}
