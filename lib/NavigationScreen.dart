import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter_projects/AnimationScreens/EmptyCart.dart';
import 'package:flutter_projects/AnimationScreens/FoodStatus.dart';
import 'package:flutter_projects/FavouriteItems.dart';
import 'Cart.dart';
import 'Categories/Favourites.dart';
import 'Profile.dart';
import 'main.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  var _selectedTab = 0;
  String amt = "";
  String cartItemCount = "0";
  final FirebaseAuth auth = FirebaseAuth.instance;

  // gettingData() {
  //   final User? user = auth.currentUser;
  //   String uid = user!.uid;
  //   late DatabaseReference dbRef = FirebaseDatabase.instance
  //       .ref()
  //       .child("User")
  //       .child(uid)
  //       .child("Totalamount");
  //   dbRef.onValue.listen((DatabaseEvent event) {
  //     final data = event.snapshot.value.toString();
  //     amt = data;
  //   });
  // }

  getCartItemCount() {
    final User? user = auth.currentUser;
    String uid = user!.uid;
    late DatabaseReference dbRef =
        FirebaseDatabase.instance.ref().child("User").child(uid).child("cart");
    dbRef.onValue.listen((DatabaseEvent event) {
      final cartItems = event.snapshot.value as Map<dynamic, dynamic>;
      if (cartItems != null) {
        final itemList = cartItems.values.toList();
        setState(() {
          cartItemCount = itemList.length.toString();
        });
      } else {
        setState(() {
          cartItemCount = "0";
        });
      }
    });
  }

  @override
  void initState() {
    // gettingData();
    setState(() {
      getCartItemCount();
    });
    super.initState();
  }

  List pages = [
    const MyHomePage(title: "Cafeteria"),
    const FavouriteItems(),
    const FoodStatus(),
    const Profile()
  ];

  final iconList = <IconData>[
    Icons.home,
    Icons.favorite,
    Icons.timelapse,
    Icons.account_box,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      floatingActionButton: FloatingActionButton(
        child: Stack(
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
            ),
            Visibility(
              visible: cartItemCount != "0", // check if cartItemCount is not zero
              child: Positioned(
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 15,
                    minHeight: 15,
                  ),
                  child: Text(
                    cartItemCount,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        onPressed: () {
          if (cartItemCount == "0") {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => EmptyCart()));
          } else {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const Cart()));
          }
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
          icons: iconList,
          activeIndex: _selectedTab,
          activeColor: const Color(0xFFDE6262),
          gapLocation: GapLocation.center,
          notchSmoothness: NotchSmoothness.verySmoothEdge,
          leftCornerRadius: 32,
          rightCornerRadius: 32,
          onTap: (i) {
            setState(() {
              _selectedTab = i;
            });
            //other params
          }),
      body: pages[_selectedTab],
    );
  }
}
