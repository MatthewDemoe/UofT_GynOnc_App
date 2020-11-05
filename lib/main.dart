import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'SignInPage.dart';
import 'HomePage.dart';
import 'VideoPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseAuth mAuth = FirebaseAuth.instance;
  if (mAuth.currentUser == null) await mAuth.signInAnonymously();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gyn Onc',
      theme: ThemeData(
        primaryColor: Colors.cyan[700],
        primarySwatch: Colors.cyan,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SignInPage(title: 'Authentication Page'),//HomePage(title: "Home Page"),
        '/video': (context) => VideoPage(title: "Video", id: '5yx6BWlEVcY'),
      },
    );
  }
}
