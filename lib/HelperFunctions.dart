library helpers;

import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Preferences.dart';
import 'package:photo_view/photo_view.dart';

Preferences prefs = Preferences();

Future<bool> initPrefs() {
  prefs = Preferences();
  return prefs.init();
}

Color getBackgroundColor() {
  return prefs.getBackgroundColor();
}

Color getFontColor() {
  return prefs.getFontColor();
}

Color getAppColor() {
  return prefs.getAppColor();
}

double getFontScale() {
  return prefs.getFontScale();
}

double getPrefFontSize() {
  return prefs.getPrefFontSize();
}

bool getNightMode() {
  return prefs.getNightMode();
}

void setFontScale(double newScale) {
  prefs.setFontScale(newScale);
}

TextStyle getButtonTextStyle() {
  return TextStyle(
    fontSize: 20.0 * getFontScale(),
    color: Colors.white,
  );
}

Future<Widget> getImage(String image) async {
  Image img;

  await FirebaseStorage.instance
      //The firebase storage instance
      .ref()
      //get the reference to the image
      .child(image)
      //Get the URL from the reference
      .getDownloadURL()
      //Get the actual image from the URL
      .then((value) => img =  Image.network(
            value.toString(),
            fit: BoxFit.scaleDown,
          ));

  return img;
}

//Build an image widget from database takes a string which should be the name of a file in firebase
Widget buildImage(String image) {
  return FutureBuilder(
      future: getImage(image),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Container(
            height: 110.0,
            child: CircularProgressIndicator(),
          );

        if (snapshot.connectionState == ConnectionState.done)
          return Container(
              padding: EdgeInsets.all(10),
              child: snapshot.hasData
                  ? snapshot.data
                  : CircularProgressIndicator());

        return Container(
          height: 110.0,
          child: CircularProgressIndicator(),
        );
      });
}

//Updates the mark that is stored in firestore
Future<void> updateMark({String section, String mark}) async {
  //Location of the current user's information
  FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser.email)
      .collection('Evaluations')
      .doc('Marks')
      .update(
    {section + ' Evaluation': mark},
  );

  int attempts = -1;

  //The location of the section we care about
  Stream<DocumentSnapshot> snap = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser.email)
      .collection('Evaluations')
      .doc('Marks')
      .collection('Modules')
      .doc(section)
      .snapshots();

  StreamIterator<DocumentSnapshot> iterator =
      StreamIterator<DocumentSnapshot>(snap);

  if (await iterator.moveNext()) {
    attempts = (iterator.current.data()['Attempts'] as int) + 1;

    FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser.email)
        .collection('Evaluations')
        .doc('Marks')
        .collection('Modules')
        .doc(section)
        .update(
      {'Attempts': attempts},
    );

    FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser.email)
        .collection('Evaluations')
        .doc('Marks')
        .collection('Modules')
        .doc(section)
        .update(
          (attempts < 10)
              ? {'Attempt 0' + attempts.toString(): mark}
              : {'Attempt ' + attempts.toString(): mark},
        );
  } else {
    print('NO DATA IN SNAPSHOT?');
  }
}

void setNewName({String firstName, String lastName}) {
  FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser.email)
      .update({'First Name': firstName});

  FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser.email)
      .update({'Last Name': lastName});
}

//Get the first name string of the current user
Future<String> getFirstNameString() async {
  Stream<DocumentSnapshot> doc = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser.email)
      .snapshots();

  StreamIterator<DocumentSnapshot> iterator =
      StreamIterator<DocumentSnapshot>(doc);

  if (await iterator.moveNext()) {
    return iterator.current.data()['First Name'];
  }

  return '';
}

//Get the last name string of the current user
Future<String> getLastNameString() async {
  Stream<DocumentSnapshot> doc = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser.email)
      .snapshots();

  StreamIterator<DocumentSnapshot> iterator =
      StreamIterator<DocumentSnapshot>(doc);

  if (await iterator.moveNext()) {
    return iterator.current.data()['Last Name'];
  }

  return '';
}

//Create a widget from the first name of the current user
Widget getFirstName({TextStyle inStyle}) {
  Stream<DocumentSnapshot> doc = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser.email)
      .snapshots();

  return StreamBuilder<DocumentSnapshot>(
    stream: doc,
    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
      if (snapshot.hasData) {
        return Container(
            padding: EdgeInsets.all(5),
            child: Text(
              snapshot.data['First Name'],
              style: inStyle,
            ));
      }

      return CircularProgressIndicator();
    },
  );
}

//Create a widget from the last name of the current user
Widget getLastName({TextStyle inStyle}) {
  Stream<DocumentSnapshot> doc = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser.email)
      .snapshots();

  return StreamBuilder<DocumentSnapshot>(
    stream: doc,
    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
      if (snapshot.hasData) {
        return Container(
            padding: EdgeInsets.all(5),
            child: Text(
              snapshot.data['Last Name'],
              style: inStyle,
            ));
      }

      return CircularProgressIndicator();
    },
  );
}

//Show a snackbar with a message with an error icon
void showErrorSnackbar(BuildContext context, String message) {
  Scaffold.of(context).showSnackBar(SnackBar(
    content: Wrap(
        alignment: WrapAlignment.center,
        direction: Axis.horizontal,
        children: [
          Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.warning)),
          Text(
            message,
            style: TextStyle(fontSize: getPrefFontSize()),
          ),
        ]),
  ));
}

//Show a snackbar with a message
void showSnackbar(BuildContext context, String message) {
  Scaffold.of(context).showSnackBar(SnackBar(
      content: Wrap(
          alignment: WrapAlignment.center,
          direction: Axis.horizontal,
          children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: getPrefFontSize()),
        )
      ])));
}

String buildTimerText(int timeLeft) {
  int minutesLeft = timeLeft ~/ 60;
  int secondsLeft = timeLeft % 60;

  String timeString;
  if (minutesLeft < 1)
    timeString = secondsLeft.toString();
  else
    timeString = minutesLeft.toString() + ' : ' + secondsLeft.toString();

  return timeString;
}
