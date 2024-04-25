import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_projects/AboutUs/UserName.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/Authentication/Phone.dart';
import 'package:flutter_projects/NavigationScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String? userStatus = "";
  String nameStatus="";
  String? allDone="";
  final FirebaseAuth auth = FirebaseAuth.instance;

  _httpsCall() async {
    final prefs = await SharedPreferences.getInstance();
    userStatus = prefs.getString('userstatus');
    allDone=prefs.getString("AllDone");
    print(allDone);
  }

  checkUserName() async {
    final prefs = await SharedPreferences.getInstance();
    nameStatus = prefs.getString('name')!;
  }

  @override
  void initState() {
    _httpsCall();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
    Timer(const Duration(seconds: 4), () async {
      final prefs = await SharedPreferences.getInstance();
      final bool? repeat = prefs.getBool('repeat');
      print(allDone);
      if (repeat == true) {
        // if (userStatus != null) {
        //   if(nameStatus!=null && nameStatus!=""){
        //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NavigationScreen()));
        //   }else{
        //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NameInputPage()));
        //   }
        //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NavigationScreen()));
        // } else {
        //   // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserStatus()));
        // }
        if(allDone!=null){
          print(allDone);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>NavigationScreen()));
        }else{
          print(allDone);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const NameInputPage()));
        }

      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Phone()));
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent));

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _animation,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFDE6262),
                      Color(0xFFFFB88C),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.1, 0.9],
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.asset('assets/images/cup.png', color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                   Text(
                    "CAFETERIA",
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
