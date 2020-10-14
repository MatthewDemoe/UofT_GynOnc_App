import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'VideoPage.dart';

/*LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minHeight: viewportConstraints.maxHeight),
            //alignment: Alignment.topCenter,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(modulesToLoad)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return new Text('Modules Not Found');
                return new Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: getModuleButtons(snapshot, context),
                );
              },
            ),
          ));
    });*/
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
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  doc.data()['name'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                child: Image.network(
                  "https://img.youtube.com/vi/5yx6BWlEVcY/0.jpg",
                  height: 120,
                  width: 220,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VideoPage(
                          title: 'Video',
                          url: 'https://www.youtube.com/watch?v=5yx6BWlEVcY',
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
