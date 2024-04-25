import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../TimeDecision.dart';

class LocationScreen extends StatefulWidget{

  final foodlist,Totalamt,uid;
  const LocationScreen(this.foodlist,this.Totalamt,this.uid, {super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}


class _LocationScreenState extends State<LocationScreen> {

  var token="";
  late DatabaseReference dbRef;
  late DatabaseReference dbRef1;
  late DatabaseReference dbRef2;
  late DatabaseReference dbRef3;
  late DatabaseReference dbRef4;
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
   requestPermission();
   dbRef4.onValue.listen((DatabaseEvent event) {
     admintoken=event.snapshot.value.toString();
   });

    super.initState();
  }


  TextEditingController loc=TextEditingController();

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
      // print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      // print('User granted provisional permission');
    } else {
      // print('User declined or has not accepted permission');
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

    var mediaQuery=MediaQuery.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            SizedBox(
              height: 300,
              child: Lottie.asset(
                'assets/lottie/location_lottie.json',
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
             SizedBox(
              height: 100,
              width: MediaQuery.of(context).size.width*0.8,
              child: const Center(
                child: Text(
                  'Order from any corner of the college !!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Color(0xFFEE5D56),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: loc,
                        decoration: const InputDecoration(
                          hintText: 'Enter your location ex : Room no 1',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          suffixIcon: Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFFEE5D56),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (loc.text.isNotEmpty) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TimeDecision(widget.foodlist,widget.Totalamt,widget.uid,loc.text)));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your location'),backgroundColor: Color(0xFFEE5D56),));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEE5D56),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  padding: const EdgeInsets.all(10),
                ),
                child: const Text('Press Here'),
              ),
            ),
          ],
        ),
      ),
    );

  }
}