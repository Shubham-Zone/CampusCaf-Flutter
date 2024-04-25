import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/AnimationScreens/FoodStatus.dart';
import 'package:flutter_projects/NavigationScreen.dart';

class OrderCancel extends StatefulWidget {

  final id;
  const OrderCancel(this.id, {super.key});

  @override
  State<OrderCancel> createState() => _OrderCancelState();
}

class _OrderCancelState extends State<OrderCancel> {

  late Timer _timer;
  int _start = 60;
  late DatabaseReference dbRef;
  late DatabaseReference statusRef;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
        oneSec,
            (Timer timer) => setState(() {
          if (_start == 0) {
            timer.cancel();
            Navigator.push(context, MaterialPageRoute(builder: (context)=>const FoodStatus()));
          } else {
            _start = _start - 1;
          }
        }));
  }

  @override
  void initState() {
    dbRef=FirebaseDatabase.instance.ref().child("orders");
    statusRef=FirebaseDatabase.instance.ref().child("status");
    if(_start == 0){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const FoodStatus()));
    }
    startTimer();
    super.initState();
  }


  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var mediaQuery=MediaQuery.of(context);

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
                  Text("${_start.toString()} sec",style: const TextStyle(fontSize: 30,fontWeight: FontWeight.bold,),),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                      width: mediaQuery.size.width*0.7,
                      child: const Text("Do you want to cancel the order ?",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,),textAlign: TextAlign.center,)
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: (){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const FoodStatus()));
                          },
                          child: const Text("No")
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            await dbRef.child(widget.id).remove();
                            await statusRef.child(widget.id).child("status").set("7");
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order cancelled"),backgroundColor:  Color(0xFFDE6262),));
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const NavigationScreen()));
                          },
                          child: const Text("Yes")
                      )
                    ],
                  )
                ],
              )
          ),
        ),

    );


  }
}
