import 'package:cloud_firestore/cloud_firestore.dart';
import 'HelperFunctions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class ReadingPage extends StatelessWidget {
  ReadingPage({Key key, this.title = 'Reading', this.doc}) : super(key: key);

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
            width: 110.0,
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
                  width: 110.0,
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
                width: 110.0,
                child: CircularProgressIndicator(),
              );
            },

            //The image we are waiting to receive
            future: getImage(
              doc.data()['Image'],
            ));
      }

      if (doc.id.contains('Text') && !doc.id.contains('Rich')) {
        return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
            child: Text(
              doc.data()['Text'],
              style: TextStyle(fontSize: getDefaultFontSize()),
              textAlign: TextAlign.center,
            ));
      }

      if (doc.id.contains('Rich')) {
        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection(doc.reference.collection('TextSpans').path)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData)
              return new Container(
                alignment: Alignment.center,
                height: 110.0,
                width: 110.0,
                //While we wait for data...
                child: CircularProgressIndicator(),
              );
            return buildRichText(context, snapshot);
          },
        );
      }
    }).toList();
  }

  Widget buildRichText(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      alignment: Alignment.center,
      child: RichText(
          textAlign: TextAlign.center,
          text: new TextSpan(
              children: snapshot.data.docs.map((doc) {
            if (doc.data().containsKey('Link'))
              return TextSpan(
                  text: doc.data()['Text'],
                  style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontSize: getDefaultFontSize()),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launch(doc.data()['Link']);
                    });

            return TextSpan(
                text: doc.data()['Text'],
                style: TextStyle(
                    color: Colors.black, fontSize: getDefaultFontSize()));
          }).toList())),
    );
  }
}
