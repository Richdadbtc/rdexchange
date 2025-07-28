import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FirebaseTestScreen extends StatefulWidget {
  @override
  _FirebaseTestScreenState createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  String? _token;
  
  @override
  void initState() {
    super.initState();
    _getToken();
  }
  
  Future<void> _getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    setState(() {
      _token = token;
    });
    print('FCM Token: $token');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Firebase Test')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Firebase Status: ${Firebase.apps.isNotEmpty ? "Connected" : "Not Connected"}'),
            SizedBox(height: 20),
            Text('FCM Token:'),
            SizedBox(height: 10),
            SelectableText(_token ?? 'Loading...'),
          ],
        ),
      ),
    );
  }
}