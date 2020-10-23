import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'CategoryModules.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CategoryModules categoryModules = CategoryModules();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: Text(widget.title),
      ),
      body: Container(
        height: size.height,
        width: size.width,
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            categoryModules,
          ],
        ),
      ),
      drawer: Drawer(
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('module_categories')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return new Text('Modules Not Found');
              List<Widget> drawer = [
                Container(
                  height: 100.0,
                  child: DrawerHeader(
                    child: Text(
                      'Categories',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    margin: EdgeInsets.all(0),
                  ),
                ),
              ];
              drawer.addAll(getModuleCategories(snapshot).map((e) => e));
              drawer.add(new ListTile(
                title: Text('About'),
                onTap: () {
                  Navigator.pop(context);
                },
              ));
              drawer.add(new ListTile(
                title: Text('Contact Us'),
                onTap: () {
                  Navigator.pop(context);
                },
              ));

              return new ListView(children: drawer);
            }),
      ),
    );
  }

  List<Widget> getModuleCategories(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.docs
        .map((doc) => new ListTile(
              title: new Text(doc.data()['name']),
              onTap: () {
                setState(() {
                  Navigator.pop(context);
                  categoryModules = CategoryModules(
                      collectionLocation: doc.reference.path +
                          '/' +
                          doc.reference.collection('modules').id);
                  print(doc.reference.path +
                      '/' +
                      doc.reference.collection('modules').id);
                });
              },
            ))
        .toList();
  }
}
