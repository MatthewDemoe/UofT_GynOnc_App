import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uoft_gynonc_app/LoadingScreen.dart';
import 'HomePage.dart';
import 'VideoPage.dart';
import 'HelperFunctions.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initPrefs();

  FirebaseAuth mAuth = FirebaseAuth.instance;
  if (!(mAuth.currentUser == null)) {
    //mAuth.currentUser.delete();
    print('USER IS NOT NULL');
  } else {
    await mAuth.signInAnonymously();

    print('USER IS NULL');
  }

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
        '/': (context) => LoadingScreen(), //HomePage(title: "Home Page"),
        '/HomePage': (context) => HomePage(title: 'Home Page'),
        '/video': (context) => VideoPage(title: "Video", id: '5yx6BWlEVcY'),
      },
    );
  }
}
