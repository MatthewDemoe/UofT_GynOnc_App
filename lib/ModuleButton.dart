
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uoft_gynonc_app/ComponentDirector.dart';
import 'VideoPage.dart';

class ModuleButton extends StatelessWidget{
  ModuleButton({this.doc}){
    modulePath = doc.reference.collection('Components').path;
  }

  //final Container child;
  final QueryDocumentSnapshot doc;
  String modulePath;
  String _imageUrl;


  @override
  Widget build(BuildContext context)
  {
    var ref = FirebaseStorage.instance.ref().child(doc.data()['icon']);

    ref.getDownloadURL().then((loc) => (() {
      _imageUrl = loc;
      print(' image' + _imageUrl);
    } ));

    print('Path: ' + modulePath);
    
    return Container(
        alignment: Alignment.centerLeft,
        height: 120,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.all(10),
        child: RaisedButton(
          padding: EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 5),
                  width: MediaQuery.of(context).size.width * 0.5,
                  child:Text(
                  doc.data()['name'],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                child: _imageUrl == null ? Image.network("https://img.youtube.com/vi/5yx6BWlEVcY/0.jpg", height: 110.0,)
                :Image.network(_imageUrl,fit: BoxFit.cover,)
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ComponentDirector(
                          title: 'First Component', doc: doc,//id: '5yx6BWlEVcY',
                        )));
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
  }
} 