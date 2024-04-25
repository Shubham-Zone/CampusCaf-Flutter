import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FollowUsPage extends StatefulWidget {
  const FollowUsPage({super.key});

  @override
  State<FollowUsPage> createState() => _FollowUsPageState();
}

class _FollowUsPageState extends State<FollowUsPage> {
  late DatabaseReference socialMedia;

  late StreamSubscription<DatabaseEvent> _socialMediaSubscription;

  late Map<String, String> socialMediaLinks = {};

  // final Map<String, Icon> socialMediaIcons = {
  //   'Instagram': const Icon(Icons.people),
  //   'WhatsApp': const Icon(Icons.chat),
  //   'LinkedIn': const Icon(Icons.computer),
  //   'GitHub': const Icon(Icons.code),
  //   // Add more social media links as needed
  // };

  @override
  void initState() {
    socialMedia =
        FirebaseDatabase.instance.ref("DeveloperDetails").child("SocialMedia");
    _socialMediaSubscription = socialMedia.onValue.listen((event) {
      final data = Map<String, String>.from(
          event.snapshot.value as Map<dynamic, dynamic>);
      setState(() {
        socialMediaLinks = data;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _socialMediaSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Follow Us'),
      ),
      body: socialMediaLinks == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: socialMediaLinks.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final socialMediaName = socialMediaLinks.keys.toList()[index];
                final socialMediaLink = socialMediaLinks.values.toList()[index];
                // final socialMediaIcon = socialMediaIcons[socialMediaName]!;

                return ListTile(
                  // leading: socialMediaIcon,
                  title: Text(socialMediaName),
                  onTap: () => launchUrl(Uri.parse(socialMediaLink)),
                );
              },
            ),
    );
  }
}
