// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/AboutUs/SpecialKey.dart';
import 'package:flutter_projects/AboutUs/UserName.dart';
import 'package:flutter_projects/NavigationScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStatus extends StatefulWidget{
  const UserStatus({super.key});


  // final userName;
  // const UserStatus(this.userName);
  @override
  State<UserStatus> createState() => _UserStatusState();
}

class _UserStatusState extends State<UserStatus> {


  bool _canShowButton = true;
  bool _canShowprogressor = false;
  String nameStatus="";

  void hideWidget() {
    setState(() {
      _canShowButton = !_canShowButton;
      _canShowprogressor=true;
    });
  }

  checkUserName() async {
    final prefs = await SharedPreferences.getInstance();
    nameStatus = prefs.getString('name')!;
  }

  @override
  void initState() {
    checkUserName();
    super.initState();
  }

  String userstatus="";

  @override
  Widget build(BuildContext context) {

    var mediaquery=MediaQuery.of(context);

    statusCard(String img,String status){
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
              Image.asset("assets/images/$img.png",height: mediaquery.size.height*0.07,width: mediaquery.size.height*0.07,),
              SizedBox(
                width: mediaquery.size.height*0.02,
              ),
              Text(status,textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: mediaquery.size.height*0.02),)

            ],
          ),

        ),
      );
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible:_canShowButton ,
                  child: Text("YOUR STATUS",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: mediaquery.size.height*0.022,color: Colors.teal),)),
              SizedBox(
                height: mediaquery.size.height*0.03,
              ),
              Visibility(
                visible: _canShowButton,
                child: InkWell(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    userstatus="STUDENT";
                    await prefs.setString('userstatus', userstatus);
                    // hideWidget();
                    if(nameStatus!=null && nameStatus!=""){
                      await prefs.setString('AllDone', "done");
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const NavigationScreen()));
                    }else{
                      Future.delayed(const Duration(seconds: 2), (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>const NameInputPage()));
                      });
                    }
                    },
                  child: statusCard("student","STUDENT"),
                ),
              ),
              Visibility(
                visible: _canShowButton,
                child: InkWell(
                  onTap: () async {
                    userstatus="TEACHER";
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('userstatus', userstatus);
                    // hideWidget();
                    // if(nameStatus!=null && nameStatus!=""){
                    //   Future.delayed(const Duration(seconds: 2), (){
                    //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> SpecialKey()));
                    //   });
                    // }else{
                    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> SpecialKey()));
                    // }
                    Navigator.push( context, MaterialPageRoute(builder: (context)=> SpecialKey()));
                  },
                  child: statusCard("teacher","TEACHER"),
                ),
              ),
              Visibility(
                visible:_canShowprogressor,
                  child: const CircularProgressIndicator()
              ),
              // Visibility(
              //   visible: _canShowButton,
              //   child: InkWell(
              //     onTap: () async {
              //       userstatus="STUDENT RLA";
              //       final prefs = await SharedPreferences.getInstance();
              //       await prefs.setString('userstatus', userstatus);
              //       hideWidget();
              //       if(nameStatus!=null && nameStatus!=""){
              //         await prefs.setString('AllDone', "done");
              //         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const NavigationScreen()));
              //       }else{
              //         Future.delayed(const Duration(seconds: 2), (){
              //           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const NameInputPage()));
              //         });
              //       }
              //     },
              //     child:  statusCard("student","STUDENT RLA"),
              //   ),
              // ),
              // Visibility(
              //   visible: _canShowButton,
              //   child: InkWell(
              //     onTap: () async {
              //       userstatus="TEACHER RLA";
              //       final prefs = await SharedPreferences.getInstance();
              //       await prefs.setString('userstatus', userstatus);
              //       hideWidget();
              //       // if(nameStatus!=null && nameStatus!=""){
              //       //   Future.delayed(const Duration(seconds: 2), (){
              //       //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const NameInputPage()));
              //       //   });
              //       // }else{
              //       //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> SpecialKey()));
              //       // }
              //       Navigator.push(context, MaterialPageRoute(builder: (context)=> SpecialKey()));
              //     },
              //     child:  statusCard("teacher","TEACHER RLA"),
              //   ),
              // ),
              Visibility(
                visible: _canShowButton,
                child: InkWell(
                  onTap: () async {
                    userstatus="NON TEACHING STAFF";
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('userstatus', userstatus);
                    // hideWidget();
                    // if(nameStatus!=null && nameStatus!=""){
                    //   Future.delayed(const Duration(seconds: 2), (){
                    //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const NameInputPage()));
                    //   });
                    // }else{
                    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> SpecialKey()));
                    // }
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> SpecialKey()));
                  },
                  child:  statusCard("nonteachingstaff","NON TEACHING STAFF"),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}
