import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'ModuleButton.dart';

class CategoryModules extends StatelessWidget {
  CategoryModules(
      {this.modulesToLoad = 'module_categories/disease_modules/modules'});

  final String modulesToLoad;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(modulesToLoad).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        return new Column(
          children: getModuleButtons(snapshot, context),
        );
      },
    );
  }

  List<Widget> getModuleButtons(
      AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context) {
    return snapshot.data.docs.map((doc) {
      return new ModuleButton(
        doc: doc,
      );
    }).toList();
  }
}
