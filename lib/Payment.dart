import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upi_india/upi_india.dart';
import 'AnimationScreens/OrderConfirmed.dart';


class Payment extends StatefulWidget {

  final foodlist,Totalamt,uid,loc,delTime;
  const Payment( this.foodlist,this.Totalamt,this.uid,this.loc,this.delTime, {super.key});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {

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

  void placeOrder() {
    Map<String,String> order={
      "foodlist":widget.foodlist.toString(),
      "location":widget.loc.toString(),
      "phoneNo":mobileNo.toString(),
      "roll": id,
      "subtotal":widget.Totalamt.toString(),
      "token":token.toString(),
      "userstatus":userstatus,
      "OrderTime":widget.delTime,
      "Payment":"done"
    };

    sendPushMessage(admintoken, "please check", "New order arrived");
    dbRef.child(id).set(order);
    historyRef.child(id).set(order);
    dbRef2.child(id).child("status").set(status);
    dbRef1.remove();
    dbRef3.set("0");

  }


  @override
  void initState() {

    _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
      setState(() {
        apps = value;
      });
    }).catchError((e) {
      apps = [];
    });

    dbRef=FirebaseDatabase.instance.ref().child("orders");
    dbRef2=FirebaseDatabase.instance.ref().child("status");
    dbRef1=FirebaseDatabase.instance.ref().child("User").child(widget.uid).child("cart");
    dbRef3=FirebaseDatabase.instance.ref().child("User").child(widget.uid).child("Totalamount");
    historyRef=FirebaseDatabase.instance.ref().child("User").child(widget.uid).child("OrderHistory");
    dbRef4=FirebaseDatabase.instance.ref().child("Admintoken");
    _gettingFcmToken();
    requestPermission();
    dbRef4.onValue.listen((DatabaseEvent event) {
      admintoken=event.snapshot.value.toString();
    });



    // if(paymentdone){
    //   placeOrder();
    //   print("Navigating");
    //   Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderAccepted(id)));
    // }else{
    //   print("Payment failed");
    // }

    super.initState();
  }

  _gettingFcmToken() async {

    //unique id
    id=DateTime.now().millisecondsSinceEpoch.toString();

    // final fcmtoken = await FirebaseAuth.instance.currentUser?.getIdToken();
    final fcmtoken = await FirebaseMessaging.instance.getToken();
    token=fcmtoken.toString();


  }

  savingOrderDetails() async {

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('id', id);
    prefs.setString('foodlist', widget.foodlist.toString());
    prefs.setString('Totalamt', widget.Totalamt.toString());
    prefs.setString('Loc', widget.loc.toString());

    // Obtain shared preferences.
    final int? phno = prefs.getInt('phoneNo');
    final String? status = prefs.getString('userstatus');

    userstatus=status!;
    mobileNo=phno!;
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

  Future<UpiResponse>? _transaction;
  final UpiIndia _upiIndia = UpiIndia();
  List<UpiApp>? apps;

  TextStyle header = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  TextStyle value = const TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );



  Future<UpiResponse> initiateTransaction(UpiApp app) async {
    return _upiIndia.startTransaction(
      app: app,
      receiverUpiId: "7404910273@ibl",
      receiverName: 'Shubham kumar',
      transactionRefId: uniqueTransactionId,
      transactionNote: 'Food order payment',
      amount: 1.0,
    );
  }

  Widget displayUpiApps() {
    if (apps == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (apps!.length == 0) {
      return Center(
        child: Text(
          "No apps found to handle transaction.",
          style: header,
        ),
      );
    } else {
      return Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Wrap(
            children: apps!.map<Widget>((UpiApp app) {
              return GestureDetector(
                onTap: () {
                  _transaction = initiateTransaction(app);
                  setState(() {});
                },
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.memory(
                        app.icon,
                        height: 60,
                        width: 60,
                      ),
                      Text(app.name),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }
  }

  String _upiErrorHandler(error) {
    switch (error) {
      case UpiIndiaAppNotInstalledException:
        return 'Requested app not installed on device';
      case UpiIndiaUserCancelledException:
        return 'You cancelled the transaction';
      case UpiIndiaNullResponseException:
        return 'Requested app didn\'t return any response';
      case UpiIndiaInvalidParametersException:
        return 'Requested app cannot handle the transaction';
      default:
        return 'An Unknown error has occurred';
    }
  }

   _checkTxnStatus(String status) async {
     // print(status);
     switch (status) {
      case UpiPaymentStatus.SUCCESS:
        // print('Transaction Successful');
        savingOrderDetails();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction Successful')));
        Map<String,String> order={
          "foodlist":widget.foodlist.toString(),
          "location":widget.loc.toString(),
          "phoneNo":mobileNo.toString(),
          "roll": id,
          "subtotal":widget.Totalamt.toString(),
          "token":token.toString(),
          "userstatus":userstatus,
          "OrderTime":widget.delTime,
          "Payment":"done",
        };
        sendPushMessage(admintoken, "please check", "New order arrived");
        dbRef.child(id).set(order);
        historyRef.child(id).set(order);
        dbRef2.child(id).child("status").set(status);
        dbRef1.remove();
        dbRef3.set("0");
        Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderAccepted(id)));
        break;
      case UpiPaymentStatus.SUBMITTED:
        // print('Transaction Submitted');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction Submitted')));
        break;
      case UpiPaymentStatus.FAILURE:
        // print('Transaction Failed');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction Failed')));
        break;
      default:
        // print('Received an Unknown transaction status');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Received an Unknown transaction status')));
    }
  }

  Widget displayTransactionData(title, body) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title: ", style: header),
          Flexible(
              child: Text(
                body,
                style: value,
              ),),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UPI'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: displayUpiApps(),
          ),
          Expanded(
            child: FutureBuilder(
              future: _transaction,
              builder: (BuildContext context, AsyncSnapshot<UpiResponse> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        _upiErrorHandler(snapshot.error.runtimeType),
                        style: header,
                      ), // Print's text message on screen
                    );
                  }

                  // If we have data then definitely we will have UpiResponse.
                  // It cannot be null
                  UpiResponse upiResponse = snapshot.data!;

                  // Data in UpiResponse can be null. Check before printing
                  String txnId = upiResponse.transactionId ?? 'N/A';
                  String resCode = upiResponse.responseCode ?? 'N/A';
                  String txnRef = upiResponse.transactionRefId ?? 'N/A';
                  String status = upiResponse.status ?? 'N/A';
                  String approvalRef = upiResponse.approvalRefNo ?? 'N/A';
                  _checkTxnStatus(status);

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        displayTransactionData('Transaction Id', txnId),
                        displayTransactionData('Response Code', resCode),
                        displayTransactionData('Reference Id', txnRef),
                        displayTransactionData('Status', status.toUpperCase()),
                        displayTransactionData('Approval No', approvalRef),
                      ],
                    ),
                  );
                } else {
                  return const Center(
                    child: Text(''),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}