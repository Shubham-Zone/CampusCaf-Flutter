import 'package:flutter/material.dart';
import 'package:flutter_projects/AboutUs/SpecialKey.dart';
import 'package:flutter_projects/NavigationScreen.dart';
import 'package:flutter_projects/UserStatus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NameInputPage extends StatefulWidget {
  const NameInputPage({super.key});

  @override
  _NameInputPageState createState() => _NameInputPageState();
}

class _NameInputPageState extends State<NameInputPage>
    with TickerProviderStateMixin {
  late TextEditingController _nameController;
  late SharedPreferences _prefs;
  bool _nameEntered = false;
  bool _nameError = false;
  late AnimationController _shakeController;

  String userStatus="";

  gettingUserStatus() async {
    final prefs = await SharedPreferences.getInstance();
    userStatus = prefs.getString('userstatus')!;
  }

  @override
  void initState() {
    gettingUserStatus();
    _nameController = TextEditingController();
    _initPrefs();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    super.initState();
  }

  void _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _nameEntered = _prefs.getBool('nameEntered') ?? false;
    // if (_nameEntered) {
    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const NavigationScreen()));
    // }
  }

  void _saveName() {
    String name = _nameController.text.trim();
    if (name.isNotEmpty) {
      _prefs.setString('name', name);
      _prefs.setBool('nameEntered', true);
      // setState(() {
      //   _nameEntered = true;
      // });
      // if(userStatus=="TEACHER ABC" || userStatus=="TEACHER RLA" || userStatus=="NON TEACHING STAFF"){
      //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> SpecialKey()));
      // }else{
      //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const NavigationScreen()));
      // }

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> UserStatus()));

    } else {
      setState(() {
        _nameError = true;
      });
      _shakeController.forward(from: 0.0);
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _nameError = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        title: const Text(
          'Welcome',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'What is your name?',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                hintText: 'Enter your name',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 18.0,
                ),
                errorText: _nameError ? 'Please enter your name' : null,
                errorStyle: const TextStyle(
                  color: Colors.red,
                  fontSize: 16.0,
                ),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (value) {
                _saveName();
              },
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _nameEntered ? null : _saveName,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                // primary: Colors.blue,
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
