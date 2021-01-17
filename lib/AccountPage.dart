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
  //Holds the first and last name strings of the user. Used for editing
  String firstName = '';
  String lastName = '';

  //Used for building the page with different widgets if the user is editing their name
  bool editingName = false;

  @override
  void initState() {
    super.initState();

    //Load the users name in from the database
    loadNames();
  }

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
                      /////////////////////LOGO////////////////////////////
                      Container(
                        alignment: Alignment.topCenter,
                        padding: EdgeInsets.symmetric(vertical: 25),
                        height: 150,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.fitHeight,
                                image: AssetImage('assets/GynOnc_Logo.png'))),
                      ),
                      //Container containing the list of widgets
                      Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: 25),
                          child: Wrap(
                              alignment: WrapAlignment.center,
                              direction: Axis.horizontal,
                              //Use a different list of children if the user would like to edit their name
                              children: editingName
                                  ? [
                                      //If the user is editing their name, create form fields
                                      Container(
                                          padding: EdgeInsets.all(10),
                                          child: TextFormField(
                                            style: TextStyle(
                                                fontSize: getDefaultFontSize()),
                                            initialValue: firstName,
                                            decoration: InputDecoration(
                                              labelText: 'New First Name',
                                            ),
                                            onChanged: (inName) {
                                              setState(() {
                                                firstName = inName;
                                              });
                                            },
                                            onFieldSubmitted: (inName) {
                                              setState(() {
                                                firstName = inName;
                                              });
                                            },
                                          )),
                                      Container(
                                          padding: EdgeInsets.all(10),
                                          child: TextFormField(
                                            style: TextStyle(
                                                fontSize: getDefaultFontSize()),
                                            initialValue: lastName,
                                            decoration: InputDecoration(
                                              labelText: 'New Last Name',
                                            ),
                                            onChanged: (inName) {
                                              setState(() {
                                                lastName = inName;
                                              });
                                            },
                                            onFieldSubmitted: (inName) {
                                              setState(() {
                                                lastName = inName;
                                              });
                                            },
                                          )),
                                      //Buttons for saving/cancelling. Display messages if necessary
                                      Container(
                                          padding: EdgeInsets.all(10),
                                          child: RaisedButton(
                                            color: getAppColor(),
                                            child: Text(
                                              'Save',
                                              style: getButtonTextStyle(),
                                            ),
                                            onPressed: () {
                                              if ((firstName == '') ||
                                                  (lastName == '')) {
                                                showErrorSnackbar(context,
                                                    'Please enter a first and last name');
                                              } else {
                                                setNewName(
                                                    firstName: firstName,
                                                    lastName: lastName);

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
                                  //List for if the user is not editing their name
                                  //Just pieces of text for display
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
                                      //Button that will start editing
                                      Container(
                                          child: IconButton(
                                              icon: Icon(Icons.edit),
                                              onPressed: () {
                                                setState(() {
                                                  editingName = true;
                                                });
                                              }))
                                    ])),
                      //Displayy the user's email
                      Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: 50),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            direction: Axis.horizontal,
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
                      //Button to send the user a password reset email
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
                      //Sign the current user out
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

  Future<void> loadNames() async {
    firstName = await getFirstNameString();
    lastName = await getLastNameString();
  }
}
