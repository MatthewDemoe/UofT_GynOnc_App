import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:uoft_gynonc_app/HelperFunctions.dart';
import 'package:uoft_gynonc_app/LoadingScreen.dart';
import 'package:uoft_gynonc_app/SignInPage.dart';
import 'HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerificationPage extends StatefulWidget {
  VerificationPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  String verificationCode = '';
  User theUser;
  double messageSize = 14.0 * getFontScale();

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        user.reload();

        print('User is currently signed out!');
        //Navigator.pop(context);
        Navigator.push(
            context,
            //The button will return us to the previous page in the list
            MaterialPageRoute(
                builder: (context) => SignInPage(
                      key: widget.key,
                      title: 'Verification Page',
                    )));
      } else if (!user.isAnonymous) {
        theUser = user;
        if (user.emailVerified) {
          print('Email is Verified' + user.email);
          //Navigator.pop(context);
          Navigator.push(
              context,
              //The button will return us to the previous page in the list
              MaterialPageRoute(
                  builder: (context) => HomePage(
                        key: widget.key,
                        title: 'Home Page',
                      )));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
        body: Container(
            alignment: Alignment.center,
            height: size.height,
            width: size.width,
            child: ListView(
              shrinkWrap: true,
              children: [
                Container(
                  child: Text(
                    'Check Email for Verification Link',
                    style: TextStyle(fontSize: 32 * getFontScale()),
                    textAlign: TextAlign.center,
                  ),
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.center,
                ),
                Container(
                  alignment: Alignment.center,
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                          text: 'Didn\'t receive a verification link? ',
                          style: TextStyle(
                              color: Colors.black, fontSize: messageSize)),
                      TextSpan(
                          text: 'Resend email.',
                          style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              fontSize: messageSize),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              theUser.sendEmailVerification();
                            }),
                    ]),
                  ),
                ),
                Container(
                    alignment: Alignment.center,
                    width: 100,
                    padding: EdgeInsets.symmetric(vertical: 25),
                    child: RaisedButton(
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Verify',
                          style: TextStyle(
                              fontSize: messageSize, color: Colors.white),
                        ),
                      ),
                      color: getAppColor(),
                      onPressed: () {
                        theUser.reload();

                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            //The button will return us to the previous page in the list
                            MaterialPageRoute(
                                builder: (context) => LoadingScreen(
                                      key: widget.key,
                                    )));
                      },
                    )),
              ],
            )));
  }
}
