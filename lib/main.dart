import 'package:flutter/material.dart';
import 'package:reva/home/homescreen.dart';
import 'package:reva/subscription/subscriptionscreen.dart';

import 'authentication/welcomescreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'REVA',
      debugShowCheckedModeBanner: false,
      home: SubscriptionPlansScreen(userId: "kk"),
    );
  }
}
