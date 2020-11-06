import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerificationPage extends StatefulWidget{
  VerificationPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _VerificationPageState createState() => _VerificationPageState();

}

class _VerificationPageState extends State<VerificationPage>{
  String verificationCode = '';
  User theUser;
  double messageSize = 14.0;


  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance
      .authStateChanges()
        .listen((User user) {
          if (user == null) {
            print('User is currently signed out!');
          } else if (!user.isAnonymous){
            theUser = user;
            if(user.emailVerified)
            {
              print('Email is Verified' + user.email);
              Navigator.pop(context);
              Navigator.push(
                        context,
                        //The button will return us to the previous page in the list
                        MaterialPageRoute(
                            builder: (context) => HomePage(key: widget.key, title: 'Home Page',))
                      );
            }
          }
        });
  }
  
  @override
  Widget build(BuildContext context){
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
              child: Text('Enter Email Verification Code', style: TextStyle(fontSize: 32), textAlign: TextAlign.center,), 
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
            ),

            Container(alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Verification Code'
                
                ),

                onFieldSubmitted: (inCode) async {
                  setState((){
                    verificationCode = inCode;
                  });
                  print(verificationCode);

                  
                },
                ),
            ),

            Container(
              alignment: Alignment.center,
              child: RichText(text: TextSpan(children: [
              TextSpan(text: 'Didn\'t receive a verification email? ', style: TextStyle(color: Colors.black, fontSize: messageSize)),
              TextSpan(text: 'Resend email.', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: messageSize),
                recognizer: TapGestureRecognizer()..onTap = (){
                  theUser.sendEmailVerification();
                }
              ),
                        
            ]),),
            ),

            Container(
              alignment: Alignment.center,
              width: 100,
              padding: EdgeInsets.symmetric(vertical: 25),
              child: RaisedButton(
                child: Text('Verify', style: TextStyle(fontSize: 14, color: Colors.white),),
                color: Colors.cyan[700],
                
                onPressed: () async {
                  FirebaseAuth auth = FirebaseAuth.instance;

                  try{
                    //await auth.checkActionCode();
                    //await auth.applyActionCode();

                    auth.currentUser.reload();
                  } on FirebaseAuthException catch (e){
                    if(e.code == 'invalid-activation-code'){
                      print('Invalid Activation Code');
                    }                    
                  }
                }
              ,)
            ),
    ],)));
  }
}