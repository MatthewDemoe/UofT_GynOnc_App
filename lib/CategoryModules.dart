import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'VideoPage.dart';

class CategoryModules extends StatelessWidget {
  CategoryModules(
      {String collectionLocation =
          'module_categories/disease_modules/modules'}) {
    modulesToLoad = collectionLocation;
  }

  String modulesToLoad = 'module_categories/disease_modules/modules';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(modulesToLoad).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('Modules Not Found');
        return new Column(
          children: getModuleButtons(snapshot, context),
        );
      },
    );
  }

  List<Widget> getModuleButtons(
      AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context) {   
    return snapshot.data.docs.map((doc) {
      String _imageUrl;
      
      var ref = FirebaseStorage.instance.ref().child(doc.data()['icon']);

      ref.getDownloadURL().then((loc) => (() {
        _imageUrl = loc;
        print(' image' + _imageUrl);
        } ));

      return new Container(
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
                    builder: (context) => VideoPage(
                          title: 'Video', id: '5yx6BWlEVcY',
                        )));
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }).toList();
  }  
}
