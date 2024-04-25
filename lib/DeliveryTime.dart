import 'dart:convert';
import 'package:flutter_projects/AnimationScreens/OrderConfirmed.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DeliveryMode.dart';

class DeliveryTime extends StatefulWidget {

  final foodlist,Totalamt,uid,loc;

   const DeliveryTime(this.foodlist,this.Totalamt,this.uid,this.loc, {super.key});

  @override
  State<DeliveryTime> createState() => _DeliveryTimeState();
}

class _DeliveryTimeState extends State<DeliveryTime> {

  TimeOfDay time=TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute);
  bool btnVsb=false;

  var token="";
  late DatabaseReference dbRef;
  late DatabaseReference dbRef1;
  late DatabaseReference dbRef2;
  late DatabaseReference dbRef3;
  late DatabaseReference dbRef4;
  late DatabaseReference historyRef;
  String id="";
  String status="5";
  int mobileNo=0;
  String userstatus="";
  String admintoken="";


  @override
  void initState() {
    dbRef=FirebaseDatabase.instance.ref().child("orders");
    dbRef2=FirebaseDatabase.instance.ref().child("status");
    dbRef1=FirebaseDatabase.instance.ref().child("User").child(widget.uid).child("cart");
    dbRef3=FirebaseDatabase.instance.ref().child("User").child(widget.uid).child("Totalamount");
    dbRef4=FirebaseDatabase.instance.ref().child("Admintoken");
    historyRef=FirebaseDatabase.instance.ref().child("User").child(widget.uid).child("OrderHistory");
    // _httpsCall();
    requestPermission();
    dbRef4.onValue.listen((DatabaseEvent event) {
      admintoken=event.snapshot.value.toString();
    });

    super.initState();
  }

  // _httpsCall() async {
  //
  //   //unique id
  //   id=DateTime.now().millisecondsSinceEpoch.toString();
  //   final prefs = await SharedPreferences.getInstance();
  //   prefs.setString('id', id);
  //   prefs.setString('foodlist', widget.foodlist.toString());
  //   prefs.setString('Totalamt', widget.Totalamt.toString());
  //   prefs.setString('Loc', widget.loc.toString());
  //
  //   // final fcmtoken = await FirebaseAuth.instance.currentUser?.getIdToken();
  //   final fcmtoken = await FirebaseMessaging.instance.getToken();
  //   token=fcmtoken.toString();
  //
  //   // Obtain shared preferences.
  //   final int? phno = prefs.getInt('phoneNo');
  //   final String? status = prefs.getString('userstatus');
  //
  //   userstatus=status!;
  //   mobileNo=phno!;
  //
  // }


  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Authorization':
          'key=AAAAuUXiJEQ:APA91bHhIMMpIefv42kJteKdqWXg4Sfku64ZzrnhEdw826n8oLIhx62Db7F8OU8PqIC8lqyz4akIrgooaGjX8lr4tXbREsLmmhcs7DNKun1mTCY7EpfJKvv3Ksdi3qjIyi2ci1zvQQVc'
        },
        body: jsonEncode(
          <String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click-action': 'FLUTTER_NOTIFICATION_CLICK',
              'Status': 'done',
              'body': body,
              'title': title,
            },
            "notification": <String, dynamic>{
              "title": title,
              "body": body,
              "android_channel_id": "Cafeteria"
            },
            "to": token,
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print("error push notification");
      }
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Card(
            color: const Color(0xFFF6F6F6),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  Lottie.asset(
                    "assets/lottie/time3.json",
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  const Text(
                    "Select Delivery Time",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Color(0xFF0E2043),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    time.format(context),
                    style: const TextStyle(
                      fontSize: 24,
                      color: Color(0xFFA4A4A4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      TimeOfDay? newTime = await showTimePicker(
                        context: context,
                        initialTime: time,
                      );
                      if (newTime == null) return;
                      setState(
                            () {
                          time = newTime;
                          btnVsb = true;
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: const Color(0xFF2EC4B6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text("Select Time"),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  Visibility(
                    visible: btnVsb,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeliveryModePage(
                              widget.foodlist,
                              widget.Totalamt,
                              widget.uid,
                              widget.loc,
                              time.format(context),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.bold,
                        ),
                        backgroundColor: const Color(0xFFEF476F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                      ),
                      child: const Text("Checkout"),
                    ),
                  ),
                ],
              ),
            ),
          )


        ),
      ),
    );
  }
}
