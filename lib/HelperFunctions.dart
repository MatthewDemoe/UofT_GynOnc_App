library helpers;

import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Color _appColor = Colors.cyan[700];
double _defaultFontSize = 18.0;

Color getAppColor() {
  return _appColor;
}

double getDefaultFontSize() {
  return _defaultFontSize;
}

TextStyle getButtonTextStyle() {
  return TextStyle(
    fontSize: _defaultFontSize,
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
      .then((value) => img = Image.network(
            value.toString(),
            fit: BoxFit.scaleDown,
          ));

  return img;
}

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

Future<void> updateMark({String section, String mark}) async {
  FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser.email)
      .collection('Evaluations')
      .doc('Marks')
      .update(
    {section + ' Evaluation': mark},
  );

  int attempts = -1;

  Stream<DocumentSnapshot> snap = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser.email)
      .collection('Evaluations')
      .doc('Marks')
      .collection('Modules')
      .doc(section)
      .snapshots();

  print('AFTER SNAPSHOT ');

  StreamIterator<DocumentSnapshot> iterator =
      StreamIterator<DocumentSnapshot>(snap);

  if (await iterator.moveNext()) {
    print(iterator.current.data()['Attempts']);

    attempts = (iterator.current.data()['Attempts'] as int) + 1;

    print('ATTEMPTS: ' + attempts.toString());

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
              ? {'Attempt ' + attempts.toString(): mark}
              : {'Attempt 0' + attempts.toString(): mark},
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

  //return name;
}

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

void showErrorSnackbar(BuildContext context, String message) {
  Scaffold.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.warning)),
      Text(message),
    ]),
    action: SnackBarAction(
        label: 'Okay',
        onPressed: () {
          //Dismiss
        }),
  ));
}

void showSnackbar(BuildContext context, String message) {
  Scaffold.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      Text(message),
    ]),
    action: SnackBarAction(
        label: 'Okay',
        onPressed: () {
          //Dismiss
        }),
  ));
}
