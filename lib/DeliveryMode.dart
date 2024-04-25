import 'dart:convert';
import 'package:flutter_projects/Razorpay.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/AnimationScreens/OrderConfirmed.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeliveryModePage extends StatefulWidget {

  final foodlist,Totalamt,uid,loc,delTime;
  const DeliveryModePage(this.foodlist,this.Totalamt,this.uid,this.loc,this.delTime, {super.key});

  @override
  _DeliveryModePageState createState() => _DeliveryModePageState();

}

class _DeliveryModePageState extends State<DeliveryModePage> {

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
  String userName="";

  String _codEnabled = "true";
  String _upiEnabled = "true";


  @override
  void initState() {

    super.initState();
    dbRef=FirebaseDatabase.instance.ref().child("orders");
    dbRef2=FirebaseDatabase.instance.ref().child("status");
    dbRef1=FirebaseDatabase.instance.ref().child("User").child(widget.uid).child("cart");
    dbRef3=FirebaseDatabase.instance.ref().child("User").child(widget.uid).child("Totalamount");
    historyRef=FirebaseDatabase.instance.ref().child("User").child(widget.uid).child("OrderHistory");
    dbRef4=FirebaseDatabase.instance.ref().child("Admintoken");
    _httpsCall();
    requestPermission();
    dbRef4.onValue.listen((DatabaseEvent event) {
      admintoken=event.snapshot.value.toString();
    });

    DatabaseReference paymentsRef = FirebaseDatabase.instance.ref().child("payments");
    paymentsRef.child("cod").onValue.listen((DatabaseEvent event) {
      setState(() {
        _codEnabled = event.snapshot.value.toString();
      });
    });
    paymentsRef.child("upi").onValue.listen((event) {
      setState(() {
        _upiEnabled = event.snapshot.value.toString();
      });
    });

    print(_codEnabled);
    print(_upiEnabled);

  }

  _httpsCall() async {

    //unique id
    id=DateTime.now().millisecondsSinceEpoch.toString();


    // final fcmtoken = await FirebaseAuth.instance.currentUser?.getIdToken();
    final fcmtoken = await FirebaseMessaging.instance.getToken();
    token=fcmtoken.toString();

    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    final int? phno = prefs.getInt('phoneNo');
    final String? status = prefs.getString('userstatus');
    userName=prefs.getString("name")!;

    userstatus=status!;
    mobileNo=phno!;


  }

  savingOrderDetails() async {

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('id', id);
    prefs.setString('foodlist', widget.foodlist.toString());
    prefs.setString('Totalamt', widget.Totalamt.toString());
    prefs.setString('Loc', widget.loc.toString());


  }

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

  // void sendPushMessage(String token, String body, String title) async {
  //   try {
  //     await http.post(
  //       Uri.parse('https://fcm.googleapis.com/fcm/send'),
  //       headers: <String, String>{
  //         'Content-type': 'application/json',
  //         'Authorization':
  //         'key=AAAAuUXiJEQ:APA91bHhIMMpIefv42kJteKdqWXg4Sfku64ZzrnhEdw826n8oLIhx62Db7F8OU8PqIC8lqyz4akIrgooaGjX8lr4tXbREsLmmhcs7DNKun1mTCY7EpfJKvv3Ksdi3qjIyi2ci1zvQQVc'
  //       },
  //       body: jsonEncode(
  //         <String, dynamic>{
  //           'priority': 'high',
  //           'data': <String, dynamic>{
  //             'click-action': 'FLUTTER_NOTIFICATION_CLICK',
  //             'Status': 'done',
  //             'body': body,
  //             'title': title,
  //           },
  //           "notification": <String, dynamic>{
  //             "title": title,
  //             "body": body,
  //             "android_channel_id": "Cafeteria"
  //           },
  //           "to": token,
  //         },
  //       ),
  //     );
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("error push notification");
  //     }
  //   }
  // }

  void sendPushMessage(String body,String title) async{
    try{
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers:<String,String>{
          'Content-type': 'application/json',
          'Authorization': 'key=AAAAuUXiJEQ:APA91bHhIMMpIefv42kJteKdqWXg4Sfku64ZzrnhEdw826n8oLIhx62Db7F8OU8PqIC8lqyz4akIrgooaGjX8lr4tXbREsLmmhcs7DNKun1mTCY7EpfJKvv3Ksdi3qjIyi2ci1zvQQVc'

        },
        body:jsonEncode(
          <String,dynamic>{
            'priority':'high',
            'to': '/topics/CafeteriaAdmin',
            'data':<String,dynamic>{
              'click-action':'FLUTTER_NOTIFICATION_CLICK',
              'Status':'done',
              'body':body,
              'title':title,
            },

            "notification":<String,dynamic>{
              "title":title,
              "body":body,
              "android_channel_id":"Cafeteria"
            },
          },
        ),
      );
    }catch(e){
      if(kDebugMode){
        print("error push notification");
      }
    }
  }

  int _selectedOption = 0;

  void _selectOption(int option) {
    setState(() {
      _selectedOption = option;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Delivery Mode'),
      ),

      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose a payment option:',
              style: TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: () => _selectOption(0),
              child: _buildOption(
                title: 'Cash on Delivery',
                description: 'Pay with cash upon delivery',
                isSelected: _selectedOption == 0,
              ),
            ),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: () => _selectOption(1),
              child: _buildOption(
                title: 'UPI',
                description: 'Pay with UPI',
                isSelected: _selectedOption == 1,
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
               if(_selectedOption==1){
                 if(_upiEnabled=="true"){
                   Navigator.push(context, MaterialPageRoute(builder: (context)=> Razorpaypayment(widget.foodlist, widget.Totalamt, widget.uid, widget.loc,widget.delTime)));
                 }else{
                   showDialog(
                     context: context,
                     builder: (context) => AlertDialog(
                       title: const Text('UPI is disabled.'),
                       content: const Text('Please select another payment option.'),
                       actions: [
                         TextButton(
                           onPressed: () {
                             Navigator.pop(context);
                           },
                           child: const Text('OK'),
                         ),
                       ],
                     ),
                   );
                 }

               }else{
                 if(_codEnabled=="true"){
                   savingOrderDetails();
                   Map<String,String> order={
                     "CustomerName":userName,
                     "foodlist":widget.foodlist.toString(),
                     "location":widget.loc.toString(),
                     "phoneNo":mobileNo.toString(),
                     "roll": id,
                     "subtotal":widget.Totalamt.toString(),
                     "token":token.toString(),
                     "userstatus":userstatus,
                     "OrderTime":widget.delTime,
                     "Payment":"COD"
                   };
                   sendPushMessage("please check", "New order arrived");
                   dbRef.child(id).set(order);
                   historyRef.child(id).set(order);
                   dbRef2.child(id).child("status").set(status);
                   dbRef1.remove();
                   dbRef3.set("0");
                   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>OrderAccepted(id)));
                 }else{
                   showDialog(
                     context: context,
                     builder: (context) => AlertDialog(
                       title: const Text('Cash on delivery is disabled.'),
                       content: const Text('Please select another payment option.'),
                       actions: [
                         TextButton(
                           onPressed: () {
                             Navigator.pop(context);
                           },
                           child: const Text('OK'),
                         ),
                       ],
                     ),
                   );
                 }

               }
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required String title,
    required String description,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey[300] : Colors.transparent,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: isSelected ? Colors.black : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : Colors.grey[600]!,
            ),
          ),
          const SizedBox(height: 5.0),
          Text(
            description,
            style: TextStyle(
              fontSize: 16.0,
              color: isSelected ? Colors.black : Colors.grey[600]!,
            ),
          ),
        ],
      ),
    );
  }
}
