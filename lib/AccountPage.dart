import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uoft_gynonc_app/HelperFunctions.dart';
import 'package:uoft_gynonc_app/LoadingScreen.dart';

class AccountPage extends StatelessWidget {
  AccountPage({Key key, this.title = 'My Account'}) : super(key: key);

  final String title;
  final double fontSize = 18;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 2,
          title: Text(title),
        ),
        body: Builder(
            builder: (context) => Container(
                  alignment: Alignment.center,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        padding: EdgeInsets.symmetric(vertical: 25),
                        height: 150,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.fitHeight,
                                image: AssetImage('assets/GynOnc_Logo.png'))),
                      ),
                      Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: 25),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            direction: Axis.horizontal,
                            //mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  padding: EdgeInsets.all(5),
                                  child: Text(
                                    'Name: ',
                                    style: TextStyle(fontSize: fontSize),
                                  )),
                              Flexible(
                                  child: getFirstName(
                                      inStyle: TextStyle(fontSize: fontSize))),
                              //style: TextStyle(fontSize: fontSize)),
                              Flexible(
                                  child: getLastName(
                                      inStyle: TextStyle(fontSize: fontSize))),

                              Container(
                                  //padding: EdgeInsets.all(5),
                                  child: IconButton(
                                      icon: Icon(Icons.edit), onPressed: () {}))
                              //style: TextStyle(fontSize: fontSize)),
                            ],
                          )),
                      Container(
                          //width: MediaQuery.of(context).size.width * 0.8,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: 50),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            direction: Axis.horizontal,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Email : ',
                                style: TextStyle(fontSize: fontSize),
                                textAlign: TextAlign.center,
                              ),
                              Flexible(
                                  child: Text(
                                FirebaseAuth.instance.currentUser.email,
                                style: TextStyle(fontSize: fontSize),
                                textAlign: TextAlign.center,
                              )),
                            ],
                          )),
                      Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(5),
                          child: RaisedButton(
                            child: Text(
                              'Reset Password',
                              style: TextStyle(
                                  color: Colors.white, fontSize: fontSize),
                            ),
                            color: Colors.cyan[700],
                            onPressed: () {
                              FirebaseAuth mAuth = FirebaseAuth.instance;
                              mAuth.sendPasswordResetEmail(
                                  email: mAuth.currentUser.email);

                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Row(children: [
                                  Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Icon(Icons.warning)),
                                  Text('Reset link sent to your email.'),
                                ]),
                                action: SnackBarAction(
                                    label: 'Okay',
                                    onPressed: () {
                                      //Dismiss
                                    }),
                              ));
                            },
                          )),
                      Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(5),
                          child: RaisedButton(
                            child: Text(
                              'Sign Out',
                              style: TextStyle(
                                  color: Colors.white, fontSize: fontSize),
                            ),
                            color: Colors.cyan[700],
                            onPressed: () {
                              FirebaseAuth mAuth = FirebaseAuth.instance;
                              mAuth.signOut();

                              Navigator.pop(context);

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoadingScreen(
                                            key: key,
                                          )));
                            },
                          )),
                    ],
                  ),
                )));
  }
}
