import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'ModuleButton.dart';

class CategoryModules extends StatelessWidget {
  CategoryModules(
      {this.modulesToLoad = '/Module Categories /Disease Modules/Modules'});

  final String modulesToLoad;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      //Query the database
      stream: FirebaseFirestore.instance.collection(modulesToLoad).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        //Show a progress indicator if we have to wait for data
        if (!snapshot.hasData) return CircularProgressIndicator();
        return new Column(
          children: getModuleButtons(snapshot, context),
        );
      },
    );
  }

  //Build a button for each module in a category
  List<Widget> getModuleButtons(
      AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context) {
    return snapshot.data.docs.map((doc) {
      return new ModuleButton(
        doc: doc,
      );
    }).toList();
  }
}
