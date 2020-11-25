import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uoft_gynonc_app/HelperFunctions.dart';
import 'package:uoft_gynonc_app/LoadingScreen.dart';

class AccountPage extends StatefulWidget {
  AccountPage({Key key, this.title = 'My Account'}) : super(key: key);

  final String title;

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String newFirstName = '';
  String newLastName = '';

  bool editingName = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 2,
          title: Text(widget.title),
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
                              children: editingName
                                  ? [
                                      Container(
                                          padding: EdgeInsets.all(10),
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                              labelText: 'New First Name',
                                            ),
                                            onFieldSubmitted: (inName) {
                                              setState(() {
                                                newFirstName = inName;
                                              });
                                            },
                                          )),
                                      Container(
                                          padding: EdgeInsets.all(10),
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                              labelText: 'New Last Name',
                                            ),
                                            onFieldSubmitted: (inName) {
                                              setState(() {
                                                newLastName = inName;
                                              });
                                            },
                                          )),
                                      Container(
                                          padding: EdgeInsets.all(10),
                                          child: RaisedButton(
                                            color: getAppColor(),
                                            child: Text(
                                              'Save',
                                              style: getButtonTextStyle(),
                                            ),
                                            onPressed: () {
                                              if ((newFirstName == '') ||
                                                  (newLastName == '')) {
                                                showErrorSnackbar(context,
                                                    'Please enter a first and last name');
                                              } else {
                                                setNewName(
                                                    firstName: newFirstName,
                                                    lastName: newLastName);

                                                setState(() {
                                                  editingName = false;
                                                });
                                              }
                                            },
                                          )),
                                      Container(
                                          padding: EdgeInsets.all(10),
                                          child: RaisedButton(
                                            color: getAppColor(),
                                            child: Text(
                                              'Cancel',
                                              style: getButtonTextStyle(),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                editingName = false;
                                              });
                                            },
                                          )),
                                    ]
                                  : <Widget>[
                                      Container(
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            'Name: ',
                                            style: TextStyle(
                                                fontSize: getDefaultFontSize()),
                                          )),
                                      Flexible(
                                          child: getFirstName(
                                              inStyle: TextStyle(
                                                  fontSize:
                                                      getDefaultFontSize()))),
                                      Flexible(
                                          child: getLastName(
                                              inStyle: TextStyle(
                                                  fontSize:
                                                      getDefaultFontSize()))),
                                      Container(
                                          child: IconButton(
                                              icon: Icon(Icons.edit),
                                              onPressed: () {
                                                setState(() {
                                                  editingName = true;
                                                });
                                              }))
                                    ])),
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
                                style:
                                    TextStyle(fontSize: getDefaultFontSize()),
                                textAlign: TextAlign.center,
                              ),
                              Flexible(
                                  child: Text(
                                FirebaseAuth.instance.currentUser.email,
                                style:
                                    TextStyle(fontSize: getDefaultFontSize()),
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
                              style: getButtonTextStyle(),
                            ),
                            color: getAppColor(),
                            onPressed: () {
                              FirebaseAuth mAuth = FirebaseAuth.instance;
                              mAuth.sendPasswordResetEmail(
                                  email: mAuth.currentUser.email);

                              showSnackbar(
                                  context, 'Reset link sent to your email.');
                            },
                          )),
                      Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(5),
                          child: RaisedButton(
                            child: Text(
                              'Sign Out',
                              style: getButtonTextStyle(),
                            ),
                            color: getAppColor(),
                            onPressed: () {
                              FirebaseAuth mAuth = FirebaseAuth.instance;
                              mAuth.signOut();

                              Navigator.pop(context);

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoadingScreen(
                                            key: widget.key,
                                          )));
                            },
                          )),
                    ],
                  ),
                )));
  }
}
