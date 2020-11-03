import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

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
