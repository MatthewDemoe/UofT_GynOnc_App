import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'HomePage.dart';
import 'VideoPage.dart';
import 'LoadingScreen.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseAuth mAuth = FirebaseAuth.instance; 
    if(mAuth.currentUser == null)
      await mAuth.signInAnonymously();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    /*return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return HomePage(
              title: "Gyn Onc Error",
            );

          if (snapshot.connectionState == ConnectionState.done)
            return HomePage(
              title: "Gyn Onc Done",
            );

          return LoadingScreen();
        });*/

    return MaterialApp(
      title: 'Gyn Onc',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(title: "Gyn Onc"),
        '/video': (context) => VideoPage(
            title: "Video", id: '5yx6BWlEVcY'),
      },
    );
  }
}
