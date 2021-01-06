import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uoft_gynonc_app/AccountPage.dart';
import 'package:uoft_gynonc_app/EvaluationBuilder.dart';
import 'package:uoft_gynonc_app/GeneralEvaluationPage.dart';
import 'package:uoft_gynonc_app/HelperFunctions.dart';
import 'CategoryModules.dart';
import 'SignInPage.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

//This is the page that displays all the modules to the user
class _HomePageState extends State<HomePage> {
  CategoryModules categoryModules = CategoryModules();

  Widget header;
  List<String> moduleNames = new List<String>();

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        print('User is currently signed out!');
        Navigator.pop(context);
        Navigator.push(
            context,
            //The button will return us to the previous page in the list
            MaterialPageRoute(
                builder: (context) => SignInPage(
                      key: widget.key,
                      title: 'Authentication Page',
                    )));
      }
    });

    FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser.email)
        .get()
        .then((onExist) {
      onExist.exists
          ? FirebaseFirestore.instance
              .collection('Users')
              .doc(FirebaseAuth.instance.currentUser.email)
              .update({})
          : initializeUser();
    });

    moduleNames.forEach((element) {
      print(element);
    });

    header = Container(
        padding: EdgeInsets.all(8),
        height: 200,
        child: buildImage('GynOnc_Logo.png'));
  }

  @override
  Widget build(BuildContext context) {
    //Size of the phone screen - appbar
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: Text(widget.title),
      ),
      //Body of the page contains a ListView of all the module buttons
      body: Container(
        height: size.height,
        width: size.width,
        child: ListView(
          //Gives a nice bounce to the list when it is scrolled
          physics: BouncingScrollPhysics(),
          children: [
            header,
            categoryModules,
          ],
        ),
      ),
      //A drawer that can be pulled out from the side of the screen
      drawer: Drawer(
        child: StreamBuilder<QuerySnapshot>(
            //Look in the database for each category of module we have
            stream: FirebaseFirestore.instance
                .collection('/Module Categories ')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              //Return a progress indicator if we need to wait for data
              if (!snapshot.hasData)
                return Container(
                    height: 100.0,
                    width: 100.0,
                    child: CircularProgressIndicator());
              List<Widget> drawer = [
                Container(
                  height: 100.0,
                  //Block that appears at the top of the drawer
                  child: DrawerHeader(
                    child: header,
                    decoration: BoxDecoration(
                      color: getAppColor(),
                    ),
                    margin: EdgeInsets.all(0),
                  ),
                ),
              ];
              //Add a button for each module category we found in the database
              drawer.addAll(getModuleCategories(snapshot).map((e) => e));

              //Also add some additional buttons

              drawer.add(new ListTile(
                leading: Icon(Icons.assignment),
                title: Text('Overall Test'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EvaluationBuilder(
                                key: widget.key,
                                title: 'General Evaluation',
                              )));
                },
              ));

              drawer.add(new ListTile(
                leading: Icon(
                  Icons.chat,
                ),
                title: Text('About'),
                onTap: () {
                  Navigator.pop(context);
                },
              ));

              drawer.add(new Container(
                  child: ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('Account'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AccountPage(
                                key: widget.key,
                              )));
                },
              )));

              drawer.add(new ListTile(
                leading: Icon(Icons.email),
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

  //Given a database snapshot, this will return a list tile for each collection in the database
  List<Widget> getModuleCategories(AsyncSnapshot<QuerySnapshot> snapshot) {
    //Iterating through each document in the snapshot(each category)
    return snapshot.data.docs
        .map((doc) => new ListTile(
              title: new Text(doc.id),
              leading: Icon(Icons.receipt),
              onTap: () {
                setState(() {
                  Navigator.pop(context);
                  //When you tap on a list tile, create a new list of buttons to be displayed
                  //based on the category selected
                  categoryModules = CategoryModules(
                      modulesToLoad: doc.reference.path +
                          '/' +
                          doc.reference.collection('Modules').id);
                });
              },
            ))
        .toList();
  }

  void initializeUser() {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser.email)
        .set({});

    FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser.email)
        .update({'General Evaluation': 'Not Attempted'});

    FirebaseFirestore.instance
        .collection('Module Categories ')
        .snapshots()
        .forEach((element) {
      element.docs.forEach((category) {
        category.reference.collection('Modules').snapshots().forEach((module) {
          module.docs.forEach((doc) {
            print(doc.id);
            FirebaseFirestore.instance
                .collection('Users')
                .doc(FirebaseAuth.instance.currentUser.email)
                .update({doc.id + ' Evaluation': 'Not Attempted'});
          });
        });
      });
    });
  }
}
