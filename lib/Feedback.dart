import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _feedbackController = TextEditingController();
  final _feedbackRef = FirebaseDatabase.instance.reference().child('Feedback');
  bool _showStatus = false;
  bool _submitting = false;

  void _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _submitting = true;
      });
      // Generate a unique ID for the feedback
      String? feedbackId = _feedbackRef.push().key;
      // Save the feedback to the database
      await _feedbackRef.child(feedbackId!).set({
        'name': _nameController.text,
        'feedback': _feedbackController.text,
      });
      setState(() {
        _submitting = false;
        _showStatus = true;
      });
      // Hide the feedback status card after 3 seconds
      Timer(const Duration(seconds: 3), () {
        setState(() {
          _showStatus = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Submit Feedback',
                style: Theme.of(context).textTheme.headline5,
              ),
              const SizedBox(height: 16.0),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _feedbackController,
                      decoration: const InputDecoration(
                        labelText: 'Feedback',
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your feedback';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      child: _submitting ? const CircularProgressIndicator() : const Text('Submit'),
                      onPressed: _submitting ? null : _submitFeedback,
                    ),
                  ],
                ),
              ),
              if (_showStatus)
                Card(
                  color: Colors.green,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: const [
                        Text(
                          'Thank you for your feedback!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'We appreciate your input and will use it to improve our service.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
