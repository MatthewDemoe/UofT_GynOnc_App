import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uoft_gynonc_app/ComponentDirector.dart';

class ModuleButton extends StatelessWidget {
  ModuleButton({this.doc});

  //final Container child;
  final QueryDocumentSnapshot doc;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      height: 120,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(10),
      child: RaisedButton(
        elevation: 10.0,
        color: Colors.blue,
        padding: EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 5),
              width: MediaQuery.of(context).size.width * 0.66,
              child: Text(
                doc.data()['name'],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              //alignment: Alignment.centerRight,
              child: FutureBuilder(
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done)
                      return Container(
                        alignment: Alignment.center,
                        height: 110.0,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 110.0,
                          child: snapshot.hasData
                              ? snapshot.data
                              : Image.network(
                                  "https://img.youtube.com/vi/5yx6BWlEVcY/0.jpg",
                                  height: 50.0,
                                ),
                        ),
                      );

                    if (snapshot.connectionState == ConnectionState.waiting)
                      return Container(
                        height: 110.0,
                        child: CircularProgressIndicator(),
                      );

                    return Container(
                        height: 110.0,
                        child: Image.network(
                          "https://img.youtube.com/vi/5yx6BWlEVcY/0.jpg",
                          height: 110.0,
                        ));
                  },
                  future: getImage(
                    context,
                    doc.data()['icon'],
                  )),
            ),
          ],
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ComponentDirector(
                        title: 'First Component', doc: doc,
                        pageNum: 0, //id: '5yx6BWlEVcY',
                      )));
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<Widget> getImage(BuildContext context, String image) async {
    Image img;

    await FirebaseStorage.instance
        .ref()
        .child(image)
        .getDownloadURL()
        .then((value) {
      print('DOWNLOAD URL: ' + (value as String));
    });

    await FirebaseStorage.instance
        .ref()
        .child(image)
        .getDownloadURL()
        .then((value) => img = Image.network(
              value.toString(),
              fit: BoxFit.scaleDown,
            ));

    return img;
  }
}
