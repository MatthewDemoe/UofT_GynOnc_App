import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uoft_gynonc_app/HomePage.dart';
import 'package:uoft_gynonc_app/SignInPage.dart';
import 'VerificationPage.dart';

class LoadingScreen extends StatefulWidget {
  LoadingScreen({Key key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool isSignedIn = false;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((User user) {
      user.reload();

      if (user.isAnonymous) {
        print('User is currently signed out!');
        //Navigator.pop(context);
        Navigator.push(
            context,
            //The button will return us to the previous page in the list
            MaterialPageRoute(
                builder: (context) => SignInPage(
                      key: widget.key,
                      title: 'Authentication Page',
                    )));
        isSignedIn = false;
      } else if ((!user.isAnonymous) && user.emailVerified) {
        print('User is signed in! : ' + user.email);
        //Navigator.pop(context);
        Navigator.push(
            context,
            //The button will return us to the previous page in the list
            MaterialPageRoute(
                builder: (context) => HomePage(
                      key: widget.key,
                      title: 'Home Page',
                    )));
        isSignedIn = true;
        print(user.isAnonymous);
      } else {
        print('User is signed in but unverified! : ' + user.email);
        //Navigator.pop(context);
        Navigator.push(
            context,
            //The button will return us to the previous page in the list
            MaterialPageRoute(
                builder: (context) => VerificationPage(
                      key: widget.key,
                      title: 'Verification Page',
                    )));
        isSignedIn = true;
        print(user.isAnonymous);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
              height: 110.0,
              width: 110.0,
              child: CircularProgressIndicator(),
            ),
          ]),
        ),
      ),
    );
  }
}
