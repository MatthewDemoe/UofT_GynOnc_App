import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'package:uoft_gynonc_app/HelperFunctions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInPage extends StatefulWidget{
  SignInPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignInPageState createState() => _SignInPageState(); 

}

class _SignInPageState extends State<SignInPage>{
  String emailAddress = '';
  String password = '';
  String confirmPassword = '';
  String verificationCode = '';
  bool obscurePassword = true;
  bool signIn = true;
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
      appBar: AppBar(title: Text(widget.title),),
      body: Container(
        alignment: Alignment.center,
        height: size.height,
        width: size.width,
        child: ListView(
          shrinkWrap: true,
          //mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.symmetric(vertical: 25),
              height: 150,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fitHeight,
                image: AssetImage('assets/GynOnc_Logo.png'))),
          )] +  (signIn ? buildSignIn() : buildCreateAccount()))
      )
    
    );
  }

  List<Widget> buildSignIn(){
    return [
            Container(
              child: Text('Sign In', style: TextStyle(fontSize: 32), textAlign: TextAlign.center,), 
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
            ),

            Container(alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'University Email Address'
                
                ),

                onFieldSubmitted: (inEmail){
                  setState((){
                    emailAddress = inEmail;
                  });
                  print(emailAddress);
                },
                ),
            ),

            Container(alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: TextFormField(
              obscureText: obscurePassword,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.visibility),
                  onPressed: (){
                    setState((){
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
                labelText: 'Password'
                
                ),

                onFieldSubmitted: (inPassword){
                  setState((){
                    password = inPassword;
                  });
                  print(password);
                },
                ),
            ),

            Container(
              alignment: Alignment.center,
              child: RichText(text: TextSpan(children: [
              TextSpan(text: 'Don\'t have an account? ', style: TextStyle(color: Colors.black, fontSize: messageSize)),
              TextSpan(text: 'Create one.', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: messageSize),
                recognizer: TapGestureRecognizer()..onTap = (){
                  setState((){
                    signIn = false;
                    emailAddress = '';
                    password = '';
                  });
                  print(emailAddress);
                }
              ),
                        
            ]),),
            ),
            Container(
              alignment: Alignment.center,
              width: 100,
              padding: EdgeInsets.symmetric(vertical: 25),
              child: RaisedButton(
                
                child: Text('Next', style: TextStyle(fontSize: 14, color: Colors.white),),
                color: Colors.cyan[700],
                
                onPressed: () async {
                  print('Trying to sign in.');
                  try {
                    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: emailAddress, password: password);
                  } on FirebaseAuthException catch(e){
                    if(e.code == 'user-not-found'){
                      print('No account found with that email.');
                    }
                    else if(e.code == 'wrong-password'){
                      print('Wrong password provided for that user.');
                    }
                  }
                  catch(e){
                    print(e);
                  }
                  
              },)
            ),
            ];
  }

  List<Widget> buildCreateAccount(){
    return <Widget>[
      Container(
              child: Text('Create Account', style: TextStyle(fontSize: 32), textAlign: TextAlign.center,), 
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
            ),

            Container(alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'University Email Address'
                
                ),

                onFieldSubmitted: (inEmail){
                  setState((){
                    emailAddress = inEmail;
                  });
                  print(emailAddress);
                },
                ),
            ),

            Container(alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: TextFormField(
              obscureText: obscurePassword,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.visibility),
                  onPressed: (){
                    setState((){
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
                labelText: 'Password'
                
                ),

                onFieldSubmitted: (inPassword){
                  setState((){
                    password = inPassword;
                  });
                  print(password);
                },
                ),
            ),

            Container(alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: TextFormField(
              obscureText: obscurePassword,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.visibility),
                  onPressed: (){
                    setState((){
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
                labelText: 'Confirm Password'
                
                ),

                onFieldSubmitted: (inPassword){
                  setState((){
                    confirmPassword = inPassword;
                  });
                  print(password);
                },
                ),
            ),

            Container(
              alignment: Alignment.center,
              child: RichText(text: TextSpan(children: [
              TextSpan(text: 'Already have an account? ', style: TextStyle(color: Colors.black, fontSize: messageSize)),
              TextSpan(text: 'Sign in.', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: messageSize),
                recognizer: TapGestureRecognizer()..onTap = (){
                  setState((){
                    signIn = true;
                    emailAddress = '';
                    password = '';
                  });
                }
              ),
                        
            ]),),
            ),
            Container(
              alignment: Alignment.center,
              width: 100,
              padding: EdgeInsets.symmetric(vertical: 25),
              child: RaisedButton(
                child: Text('Next', style: TextStyle(fontSize: 14, color: Colors.white),),
                color: Colors.cyan[700],
                
                onPressed: () async {
                  if(password == confirmPassword){
                  try{
                    UserCredential userCredential = await  FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: emailAddress, password: password
                      );
                      userCredential.user.sendEmailVerification();
                  } on FirebaseAuthException catch(e){
                    if(e.code == 'weak-password'){
                      print('The password you entered is too weak.');
                    }
                    else if(e.code == 'email-already-in-use'){
                      print('An account already exists with that email.');
                    }
                  } 
                  catch(e){
                    print(e);
                  }
                  }
                  
                  
                  else{
                    print('Passwords do not match.');
                  } 


              },)
            ),

    ];
  }

  List<Widget> buildVerifyAccount(){
    return <Widget>[
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
                    await auth.checkActionCode(verificationCode);
                    await auth.applyActionCode(verificationCode);

                    auth.currentUser.reload();
                  } on FirebaseAuthException catch (e){
                    if(e.code == 'invalid-activation-code'){
                      print('Invalid Activation Code');
                    }                    
                  }
                }
              ,)
            ),


    ];
  }
}