import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_projects/NavigationScreen.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui' as ui;
import '../DetailScreen.dart';

class Favourites extends StatefulWidget {
  const Favourites({super.key});

  @override
  State<Favourites> createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {

  late DatabaseReference dbRef3;
  final FirebaseAuth auth = FirebaseAuth.instance;
  var uuid = const Uuid();
  String foodPrice="";

  // Future<String> gettingFoodPrice(String name) async {
  //   final completer = Completer<String>();
  //   dbRef3.onValue.listen((DatabaseEvent event) {
  //     final food = event.snapshot.child(name).child("price").value.toString();
  //     completer.complete(food);
  //   });
  //   return completer.future;
  // }


  @override
  void initState() {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    dbRef3 = FirebaseDatabase.instance.ref().child("User").child(uid);
    RenderErrorBox.backgroundColor = Colors.transparent;
    RenderErrorBox.textStyle = ui.TextStyle(color: Colors.transparent);
    ErrorWidget.builder = (FlutterErrorDetails details) => const Center(
          child: Text("NO ITEM IS ADDED ):"),
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);

    Widget foodUi(String img, String foodname, String price) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 5,
          ),
          Container(
            width: mediaQuery.size.width * 0.31,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 10,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(foodname,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                      height: 70,
                      child: FadeInImage.assetNetwork(
                          placeholder: 'assets/gifs/loading3.gif',
                          image: img,
                          height: 65)),
                  const SizedBox(
                    height: 9,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Rs",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                      Text(
                        price,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
        ],
      );
    }

    return WillPopScope(

      onWillPop: () async {
        onBackPressed(); // Action to perform on back pressed
        return false;
      },

      child: Scaffold(

        appBar: AppBar(
          title: const Text("Favourites"),
          centerTitle: true,
          backgroundColor: Colors.pinkAccent,
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.favorite_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                // do something
              },
            )
          ],
        ),

        body: FutureBuilder(
            future: dbRef3.child("favt").get(),
            builder: (BuildContext context, AsyncSnapshot<DataSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                Map<String, dynamic> data = {};
                if (snapshot.data!.value != null) {
                  data = Map<String, dynamic>.from(
                      snapshot.data!.value as Map<Object?, Object?>);
                }

                if (data.keys.isEmpty) {
                  return const Center(
                    child: Text("No item is added ):"),
                  );
                } else {

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: data.keys
                          .map<Widget>((String uid) => InkWell(
                                onLongPress: () async {
                                  return showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            title: const Text(
                                                'Do you wish to Delete?'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('No'),
                                                onPressed: () => {
                                                  Navigator.pop(context, false)
                                                },
                                              ),
                                              TextButton(
                                                  onPressed: () async {
                                                    await dbRef3
                                                        .child("favt")
                                                        .child(uid)
                                                        .remove();
                                                    setState(() {});
                                                    ScaffoldMessenger.of(
                                                            context).showSnackBar(const SnackBar(content: Text("Deleted Successfully"),backgroundColor:  Color(0xFFDE6262),),
                                                    );
                                                    Navigator.pop(
                                                        context, true);
                                                  },
                                                  child: const Text('Yes'))
                                            ],
                                          ));
                                },
                                child: InkWell(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailScreen(
                                            data[uid]["orderImage"],
                                            data[uid]["soldItemName"],
                                            data[uid]["price"],
                                            data[uid]["desc"],data[uid]["stockStatus"],data[uid]["Category"]),
                                      )),
                                  child: foodUi(
                                      data[uid]["orderImage"],
                                      data[uid]["soldItemName"],
                                      data[uid]["price"]),
                                ),
                              ))
                          .toList(),
                    ),
                  );
                }
              }
              return const Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }

  void onBackPressed() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const NavigationScreen())
    );
  }
}
