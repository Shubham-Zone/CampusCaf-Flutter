import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'DetailScreen.dart';
import 'NavigationScreen.dart';

class FavouriteItems extends StatefulWidget {
  const FavouriteItems({Key? key}) : super(key: key);

  @override
  State<FavouriteItems> createState() => _FavouriteItemsState();
}

class _FavouriteItemsState extends State<FavouriteItems> {

  List<FavouriteItem> favouriteItems = []; // This list will contain the favourite food item details.
  List<Products> product = [];
  late DatabaseReference dbRef3;
  final FirebaseAuth auth = FirebaseAuth.instance;


  gettingFavtList(){

    final User? user = auth.currentUser;
    final uid = user!.uid;

    FirebaseDatabase.instance
        .ref()
        .child("User")
        .child(uid)
        .child("favt")
        .onValue
        .listen((DatabaseEvent event) {
      favouriteItems.clear();
      Map<dynamic, dynamic> values = event.snapshot.value as Map<dynamic,dynamic>;
      if (values != null) {
        values.forEach((key, value) {
          String name = value["foodname"];
          String category = value["category"];
          FavouriteItem item = FavouriteItem(
            name: name,
            category: category,
          );
          favouriteItems.add(item);
        });
      }
      setState(() {});
    });


  }

  @override
  void initState() {
    gettingFavtList();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    var mediaQuery=MediaQuery.of(context);

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
          body: Center(
            child: GridView.builder(
              itemCount: favouriteItems.length,
              itemBuilder: (context,index) {
                FavouriteItem item = favouriteItems[index];
                return FutureBuilder(
                    future: FirebaseDatabase.instance.ref().child("Food").child(item.category).child(item.name).get(),
                    builder: (BuildContext context, AsyncSnapshot<DataSnapshot> snapshot) {

                      if (snapshot.connectionState == ConnectionState.done) {

                        if(!snapshot.hasData){
                          return const Center(child: CircularProgressIndicator());
                        }

                        else if(snapshot.hasError){
                          return const Center(
                            child: Text('Error loading data'),
                          );
                        }

                        else if (snapshot.data == null || snapshot.data!.value == null) {
                          return  Center(
                            child: InkWell(
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
                                              final User? user = auth.currentUser;
                                              final uid = user!.uid;


                                              setState(() {
                                                FirebaseDatabase.instance
                                                    .ref()
                                                    .child("User")
                                                    .child(uid)
                                                    .child("favt").child(item.name).remove();
                                              });
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
                              child:foodUi("", "Not available", "-"),
                            ),
                          );
                        }

                        else{
                          Map<dynamic, dynamic> values = snapshot.data!.value as Map<dynamic,dynamic>;

                          return InkWell(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailScreen(values["imageurl"], values["foodname"], values["price"], values["desc"], values["stockStatus"], item.category)));
                              },
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
                                              final User? user = auth.currentUser;
                                              final uid = user!.uid;


                                              setState(() {
                                                FirebaseDatabase.instance
                                                    .ref()
                                                    .child("User")
                                                    .child(uid)
                                                    .child("favt").child(item.name).remove();
                                              });
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
                              child: foodUi(values["imageurl"], values["foodname"], values["price"])
                          );
                        }


                      }

                      return const Center(child: CircularProgressIndicator());

                    });
              }, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 9,
                mainAxisSpacing: 9
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



class FavouriteItem {
  String name;
  String category;

  FavouriteItem({
    required this.name,
    required this.category,
  });
}

class Products{

   String itemname,itemimg,itemdesc,itemprice,stockStatus;

   Products({
     required this.itemname,
     required this.itemimg,
     required this.itemdesc,
     required this.itemprice,
     required this.stockStatus,
  });
}

























// Map<dynamic,dynamic> map=snapshot.data!.value as dynamic;
// List<dynamic> list=[];
// list.clear();
// list=map.values.toList();










// FutureBuilder(
// future: FirebaseDatabase.instance.ref().child("Food").child(item.category).child(item.name).get(),
// builder: (BuildContext context, AsyncSnapshot<DataSnapshot> snapshot) {
// if (snapshot.connectionState == ConnectionState.done) {
// Map<String, dynamic> data = {};
// if (snapshot.data!.value != null) {
// data = Map<String, dynamic>.from(snapshot.data!.value as Map<Object?, Object?>);
// }
//
// if (data.keys.isEmpty) {
// return const Center(
// child: Text("No item is added ):"),
//
// );
// } else {
//
// try{
// return Padding(
// padding: const EdgeInsets.all(8.0),
// child: GridView.count(
// crossAxisCount: 2,
// mainAxisSpacing: 10,
// crossAxisSpacing: 10,
// children: data.keys.map<Widget>((String uid) {
// return InkWell(
// onTap: () {
// Navigator.push(
// context,
// MaterialPageRoute(
// builder: (context) => DetailScreen(
// data[uid]["imageurl"],
// data[uid]["foodname"],
// data[uid]["price"],
// data[uid]["desc"],
// data[uid]["stockStatus"],
// item.category
// ),
// ),
// );
// },
// child: foodUi(
// data[uid]["imageurl"],
// data[uid]["foodname"],
// data[uid]["price"]
// ),
// );
// }).toList(),
// ),
//
//
// );
// }catch(e){
// print(e);
// }
//
//
// }
// }
// return const Center(child: CircularProgressIndicator());
// });





// FutureBuilder(
// future: FirebaseDatabase.instance
//     .ref()
// .child("Food")
// .child(item.category)
// .child(item.name).get(),
// builder: (BuildContext context, AsyncSnapshot<DataSnapshot> snapshot) {
// if (snapshot.connectionState == ConnectionState.done){
// if (snapshot.hasData) {
// DataSnapshot? dataSnapshot = snapshot.data;
// if (dataSnapshot != null && dataSnapshot.value != null) {
// Map<dynamic, dynamic> values = dataSnapshot.value as Map<dynamic,dynamic>;
//
// values.forEach((dynamic, v) =>
//     product.add(Products(itemname: v["foodname"], itemimg: v["imageurl"], itemdesc: v["desc"], itemprice: v["price"],stockStatus: v["stockStatus"]))
// );
//
// Map<dynamic,dynamic> map=snapshot.data!.value as dynamic;
// List<dynamic> list=[];
// list.clear();
// list=map.values.toList();

// print(list);
// print(values);

// return GridView.builder(
// itemCount: favouriteItems.length,scrollDirection: Axis.vertical, shrinkWrap: true,
// gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// crossAxisCount: 2,
// crossAxisSpacing: 9,
// mainAxisSpacing: 9
// ),
// itemBuilder: (context,index){
//
// return InkWell(
// onTap: (){
// Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailScreen(
// values["imageurl"],
// values["foodname"],
// values["price"],
// values["desc"],
// values["stockStatus"],
// item.category
// ),));
// },
// onLongPress: (){
// FirebaseDatabase.instance
//     .ref()
//     .child("demo")
//     .child("uid")
//     .child("favt").child(favouriteItems[index].name).remove();
// },
// child: foodUi(values["imageurl"], values["foodname"], values["price"])
// );
//
// }
// );
//
// } else {
//
// }
// } else {
//
// return const CircularProgressIndicator();
// }
// }
//
// return const CircularProgressIndicator();
//
// },
// );