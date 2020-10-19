import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'VideoPage.dart';
import 'ModuleButton.dart';

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
      return new ModuleButton (doc: doc,);
    }).toList();
  }  
}
