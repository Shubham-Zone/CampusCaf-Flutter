import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/OrderCancel.dart';
import 'package:lottie/lottie.dart';


class OrderAccepted extends StatefulWidget{

  final id;
  const OrderAccepted(this.id, {super.key});


  @override
  State<OrderAccepted> createState() => _OrderAcceptedState();
}

class _OrderAcceptedState extends State<OrderAccepted> {

  @override
  void initState() {
    Timer(const Duration (seconds: 2), () async {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>  OrderCancel(widget.id)));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    var mediaquery=MediaQuery.of(context);

    return WillPopScope(
      onWillPop: () async {
        // onBackPress(); // Action to perform on back pressed
        return false;
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: mediaquery.size.height*0.02,
              ),
              Text("Order Placed",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: mediaquery.size.height*0.022,color:  Colors.green),),
              SizedBox(
                height: mediaquery.size.height*0.03,
              ),
              SizedBox(
                height: mediaquery.size.height*0.3,
                child:Lottie.asset(
                    "assets/lottie/orderplaced.json",
                    height: mediaquery.size.height*0.25,
                    fit: BoxFit.cover
                ),
              ),
            ],
          ),
        ),
      ),
    );


  }
}

