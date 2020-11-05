import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
  bool obscurePassword = true;
  bool signIn = true;

  double messageSize = 14.0;

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
          )] + (signIn ? buildSignIn() : buildCreateAccount()))
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
                
                onPressed: (){
                  
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
                    password = inPassword;
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
                
                onPressed: (){
                  
              },)
            ),

    ];
  }
}