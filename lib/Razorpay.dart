import 'dart:convert';
import 'package:flutter_projects/AnimationScreens/OrderConfirmed.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Razorpaypayment extends StatefulWidget {

  final foodlist,Totalamt,uid,loc,delTime;
  const Razorpaypayment( this.foodlist,this.Totalamt,this.uid,this.loc,this.delTime, {super.key});

  @override
  State<Razorpaypayment> createState() => _RazorpaypaymentState();
}

class _RazorpaypaymentState extends State<Razorpaypayment> {

  final _razorpay=Razorpay();
  bool processing = false;
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
  String uniqueTransactionId=DateTime.now().millisecondsSinceEpoch.toString();
  bool paymentdone=false;
  String userName="";


  _gettingFcmToken() async {

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

  @override
  void initState() {

    _gettingFcmToken();
    processing = true;
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    openCheckout();
    super.initState();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _paymentStatus(bool success) async {
    setState(() {
      processing = false;
    });

    if (success) {
      savingOrderDetails();
      placeOrder();
      await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => OrderAccepted(id)
          )
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment failed"),backgroundColor: Color(0xFFDE6262),));
    }
  }


  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // setState(() {
    //   paymentdone = true;
    // });
    // savingOrderDetails();
    // placeOrder();
    // Navigator.push(context, MaterialPageRoute(builder: (context) => OrderAccepted(id)));
    _paymentStatus(true);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      paymentdone = false;
    });
    _paymentStatus(false);
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment failed: ${response.message}")));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Payment Failed'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Payment failed: ${response.message}"),
                const Text('Please try again later.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: Colors.white,
          elevation: 24.0,
          semanticLabel: 'Payment Failed',
        );
      },
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
  }


  void openCheckout() async {
    var options = {
      'key': 'rzp_test_axAoSpI0rcbPAG',
      'amount': int.parse(widget.Totalamt) * 100, // amount in paise 100,
      'name': 'ABC CAFETERIA',
      'description': 'Payment for ${widget.foodlist}',
      'timeout':120, //seconds
      'prefill': {
        'contact': mobileNo.toString(),
        'email': 'shubhamanuj652@gmail.com'
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: ${e.toString()}');
    }
  }

  void placeOrder() {

    Map<String, String> order = {
      "CustomerName":userName,
      "foodlist": widget.foodlist.toString(),
      "location": widget.loc.toString(),
      "phoneNo": mobileNo.toString(),
      "roll": id,
      "subtotal": widget.Totalamt.toString(),
      "token": token.toString(),
      "userstatus": userstatus,
      "OrderTime": widget.delTime,
      "Payment": paymentdone ? "done" : "failed",
      "TransactionId": uniqueTransactionId
    };
    sendPushMessage( "please check", "New order arrived");
    dbRef.child(id).set(order);
    historyRef.child(id).set(order);
    dbRef2.child(id).child("status").set(status);
    dbRef1.remove();
    dbRef3.set("0");
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: processing
          ? Container(
        color: Colors.black.withOpacity(0.5),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:  [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                "Processing Payment",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      )
          : const SizedBox(),
    );
  }

}
