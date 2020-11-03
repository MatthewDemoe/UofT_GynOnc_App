import 'package:cloud_firestore/cloud_firestore.dart';
import 'HelperFunctions.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ReadingPage extends StatelessWidget {
  ReadingPage({this.title = 'Reading', this.doc});

  final String title;
  final QueryDocumentSnapshot doc;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(doc.reference.collection('Content').path)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData)
          return new Container(
            alignment: Alignment.center,
            height: 110.0,
            //While we wait for data...
            child: CircularProgressIndicator(),
          );
        return ListView(
          physics: BouncingScrollPhysics(),
          children: buildBody(context, snapshot),
        );
      },
    );
  }

  List<Widget> buildBody(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.docs.map((doc) {
      if (doc.id.contains('Image')) {
        return FutureBuilder(
            builder: (context, snapshot) {
              //Display progress indicators while we are waiting for the icon
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
            },

            //The image we are waiting to receive
            future: getImage(
              doc.data()['Image'],
            ));
      }

      if (doc.id.contains('Text')) {
        return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
            child: Text(
              doc.data()['Text'],
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ));
      }
    }).toList();
  }
}
