import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;
import '../NavigationScreen.dart';

class FoodStatus extends StatefulWidget {
  const FoodStatus({Key? key}) : super(key: key);

  @override
  State<FoodStatus> createState() => _FoodStatusState();
}

class _FoodStatusState extends State<FoodStatus> {

  late DatabaseReference dbRef;
  String orderstatus = "";
  bool status = false;
  String lottie="ordernotplaced";
  String statustext="No new order found ):";
  var uid="";
  String currOrder="";
  String orderLoc="";
  String orderAmount="";
  bool currordervsb=false;
  bool screenVsb=false;
  bool loader=true;
  Timer? timer;

  showScreen(){
    screenVsb=!screenVsb;
    loader=!loader;
  }

  foodId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(()  {
      final String? id =  prefs.getString('id');
      uid=id!;
      currOrder=prefs.getString("foodlist")!;
      orderAmount=prefs.getString("Totalamt")!;
      orderLoc=prefs.getString("Loc")!;
      dbRef = FirebaseDatabase.instance.ref().child("status").child(uid).child("status");
    });

  }

  @override
  void initState()  {

    foodId();
    if(orderstatus==""){
        Timer(const Duration(seconds: 2), () {
          setState(() {
            showScreen();
          });
        });
      }else{
        Timer(const Duration(seconds: 2), () {
          setState(() {
            showScreen();
          });
        });
      }

    checkVal(){

      setState(() {
        dbRef.onValue.listen((DatabaseEvent event) {
          orderstatus = event.snapshot.value.toString();

          if (orderstatus=="5") {
            statustext="Wait for confirmation ";
            lottie="wait";
            status=true;
            currordervsb=true;
          }

          if (orderstatus=="6") {
            statustext="Order successfully delivered ";
            lottie="deliverydone";
            status=true;
            currordervsb=true;
          }

          if (orderstatus=="3" || orderstatus=="7") {
            statustext="No new order found ):";
            lottie="ordernotplaced";
            status=true;
            currordervsb=false;
          }

          if (orderstatus == "1") {

            statustext="Order is Accepted";
            lottie="order_confirmed";
            status=true;
            currordervsb=true;

          }

          if (orderstatus == "4") {

            statustext="Food is preparing";
            lottie="foodprep";
            status=true;
            currordervsb=true;

          }

          if (orderstatus=="0") {
            statustext="Sorry we can't deliver this order ):";
            lottie="sorry";
            status=true;
            currordervsb=true;
          }

          if (orderstatus=="2") {
            statustext="Delivery out (:";
            lottie="deliveryboy";
            status=true;
            currordervsb=true;
          }

        });
      });


    }
    timer = Timer.periodic(
        const Duration(seconds: 1), (Timer t) => checkVal());
    if(status){
      timer!.cancel();
    }

    //customising error screen
    RenderErrorBox.backgroundColor = Colors.transparent;
    RenderErrorBox.textStyle = ui.TextStyle(color: Colors.transparent);
    ErrorWidget.builder = (FlutterErrorDetails details) => const Center(
      child: Text("SOMETHING WENT WRONG ):"),
    );
    super.initState();

  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var mediaQuery=MediaQuery.of(context);


    return WillPopScope(

      onWillPop: () async {
        onBackPressed(); // Action to perform on back pressed
        return false;
      },

      child: Scaffold(

          appBar: AppBar(
            title: const Text("Order Status",style: TextStyle(color: Color.fromRGBO(
                220, 69, 90, 1.0),),),
            centerTitle: true,
            backgroundColor: Colors.white,
          ),

          body: SingleChildScrollView(

            scrollDirection: Axis.vertical,

            child: Center(
              child: Column(
                children: [
                  Visibility(
                    visible: screenVsb,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Visibility(
                          visible: currordervsb,
                          child: Container(

                            // height: MediaQuery.of(context).size.height * 0.32,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(40),
                                bottomRight: Radius.circular(40),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.4),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFDE6262),
                                  Color(0xFFFFB88C),
                                ],
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 10),
                                const Text(
                                  'Current Order',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  currOrder,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 28,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          'Order Location',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          orderLoc,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const Icon(
                                          Icons.currency_rupee,
                                          size: 28,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          'Total Amount',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Rs$orderAmount',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(
                          height: mediaQuery.size.height*0.1,
                        ),
                        Text(
                          statustext,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: mediaQuery.size.height*0.022,
                              color: const Color.fromRGBO(220, 69, 90, 1.0)),
                        ),
                        Container(
                          height: mediaQuery.size.height*0.3,
                          alignment: Alignment.center,
                          child:Lottie.asset(
                              "assets/lottie/$lottie.json",
                              height: mediaQuery.size.height*0.25,
                              fit: BoxFit.cover
                          ),
                        ),
                        SizedBox(
                          height: mediaQuery.size.height*0.02,
                        ),

                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: mediaQuery.size.height*0.4),
                    child: Center(
                      child: Visibility(
                        visible: loader,
                          child:   const CircularProgressIndicator()
                      ),
                    ),
                  )
                ],
              ),
            ),

          )

      ),

    );

  }

  void onBackPressed() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) =>const NavigationScreen()));
  }
}
