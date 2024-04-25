import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_projects/NavigationScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'UserName.dart';

class SpecialKey extends StatefulWidget {
  SpecialKey({Key? key}) : super(key: key);

  @override
  _SpecialKeyState createState() => _SpecialKeyState();
}

class _SpecialKeyState extends State<SpecialKey>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _keyController = TextEditingController();
  final DatabaseReference _keysRef =
  FirebaseDatabase.instance.ref().child('keys').child('ProfessorKey');

  bool _isLoading = false;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Key'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 64),
              ScaleTransition(
                scale: _controller,
                child: Icon(
                  Icons.fastfood,
                  size: 96,
                  color: Colors.red[600],
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _keyController,
                decoration: const InputDecoration(
                  labelText: 'Enter Key',
                  prefixIcon: Icon(Icons.vpn_key),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a key';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SlideTransition(
                position: _offsetAnimation,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final dataSnapshot = await _keysRef.once();
      final String correctKey = dataSnapshot.snapshot.value.toString() ?? '';
      if (_keyController.text == correctKey) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('AllDone', "done");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const NavigationScreen()));
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Invalid Key'),
            content:  const Text('The key you entered is incorrect. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
