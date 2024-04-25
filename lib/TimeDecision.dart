import 'dart:convert';
import 'package:flutter_projects/DeliveryMode.dart';
import 'package:flutter_projects/DeliveryTime.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class TimeDecision extends StatefulWidget {


  final foodlist,Totalamt,uid,loc;
  const TimeDecision(this.foodlist,this.Totalamt,this.uid,this.loc, {super.key});

  @override
  State<TimeDecision> createState() => _TimeDecisionState();
}

class _TimeDecisionState extends State<TimeDecision> {

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
    historyRef=FirebaseDatabase.instance.ref().child("User").child(widget.uid).child("OrderHistory");
    dbRef4=FirebaseDatabase.instance.ref().child("Admintoken");
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


    card(String status){
      var mediaquery=MediaQuery.of(context);
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          margin: const EdgeInsets.only(top:2,left: 20,right: 20,bottom: 5),
          width: double.infinity,
          height: mediaquery.size.height*0.1,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                spreadRadius: 5,
                blurRadius: 12,
                offset: const Offset(0,10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(status,textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: mediaquery.size.height*0.02),)

            ],
          ),

        ),
      );
    }


    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/timemanage.png",height: 200,),
            const SizedBox(
              height: 30,
            ),
            InkWell(
              onTap: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DeliveryTime(widget.foodlist, widget.Totalamt, widget.uid, widget.loc)));
              },
                child: card("Deliver later")
            ),
            InkWell(
              onTap: (){

                // Map<String,String> order={
                //   "foodlist":widget.foodlist.toString(),
                //   "location":widget.loc.toString(),
                //   "phoneNo":mobileNo.toString(),
                //   "roll": id,
                //   "subtotal":widget.Totalamt.toString(),
                //   "token":token.toString(),
                //   "userstatus":userstatus,
                //   "OrderTime":"Normal"
                // };
                // sendPushMessage(admintoken, "please check", "New order arrived");
                // dbRef.child(id).set(order);
                // historyRef.child(id).set(order);
                // dbRef2.child(id).child("status").set(status);
                // dbRef1.remove();
                // dbRef3.set("0");

                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DeliveryModePage(widget.foodlist, widget.Totalamt, widget.uid, widget.loc,"Normal")));

              },
                child: card("Deliver now")
            ),
          ],
        ),
      ),
    );
  }
}
