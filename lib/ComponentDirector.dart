import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uoft_gynonc_app/EvaluationBuilder.dart';
import 'package:uoft_gynonc_app/HelperFunctions.dart';
import 'VideoPage.dart';
import 'AnimatedComponent.dart';
import 'ReadingPage.dart';

//Widget for navigating through components of a module
class ComponentDirector extends StatefulWidget {
  ComponentDirector({Key key, this.title, this.doc}) : super(key: key);

  final String title;
  //The module we are moving through
  final QueryDocumentSnapshot doc;
  //the page we are currently on

  @override
  _ComponentDirectorState createState() => _ComponentDirectorState();
}

class _ComponentDirectorState extends State<ComponentDirector> {
  _ComponentDirectorState();

  int pageNum = 0;

  //Total number of pages in the module
  int numPages = 0;

  //The titles for each page
  List<String> pageTitles = new List<String>();

  List<AnimatedComponent> pages = new List<AnimatedComponent>();

  bool isInitialized = false;

  @override
  void initState() {
    initComponents();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBackgroundColor(),
      body: isInitialized ? pages[pageNum] : CircularProgressIndicator(),
      appBar: AppBar(
        backgroundColor: getAppColor(),
        //Home button that will return you to the main page
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          //Get the title of the current page from the list
          pageTitles[pageNum] +
              ' ' +
              //Current page
              (pageNum + 1).toString() +
              '/' +
              //Total pages
              numPages.toString(),
        ),
        actions: [
          //Display a back button if we arent' on the first page
          if (pageNum > 0)
            IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  pages[pageNum].transition(whenComplete: () {
                    setState(() {
                      pageNum = (pageNum -= 1).clamp(0, numPages - 1);
                    });
                  });
                }),
          //Display a forward arrow if we aren't on the last page
          if (pageNum < (numPages - 1))
            IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () {
                  pages[pageNum].transition(whenComplete: () {
                    setState(() {
                      pageNum = (pageNum += 1).clamp(0, numPages - 1);
                    });
                  });
                }),
        ],
      ),
    );
  }

  void initComponents() {
    print('INITIALIZING COMPONENTS');
    Stream<QuerySnapshot> col = FirebaseFirestore.instance
        .collection(widget.doc.reference.collection('Components').path)
        .snapshots();

    int counter = 0;

    col.listen((event) {
      event.docs.forEach((element) {
        counter++;

        print(element.data()['Page Title']);
        pageTitles.add(element.data()['Page Title']);

        if (element.id.contains('Video')) {
          String videoURL = element.data()['Video ID'];
          String videoID = videoURL.split('=')[1];
          pages.add(new AnimatedComponent(
              key: ObjectKey(counter),
              child: VideoPage(id: videoID, title: videoID)));
        }

        if (element.id.contains('Reading')) {
          pages.add(new AnimatedComponent(
              key: ObjectKey(counter),
              child: ReadingPage(
                title: element.data()['Title'],
                doc: element,
              )));
        }

        if (element.id.contains('Evaluation')) {
          pages.add(new AnimatedComponent(
              key: ObjectKey(counter),
              child: EvaluationBuilder(
                  key: widget.key, title: 'Evaluation', doc: element)));
        }
      });
      print('COMPONENTS LENGTH: ' + pages.length.toString());
      setState(() {
        isInitialized = true;
        numPages = pages.length;
      });
    });
  }

  List<Widget> parseComponents(AsyncSnapshot<QuerySnapshot> snapshot) {
    //Iterate through each document(component) in this collection(module)
    return snapshot.data.docs.map((doc) {
      //Get the page title from the database
      pageTitles.add(doc.data()['Page Title']);
      //If this document has 'video' in the name, create a video page from its video id field
      if (doc.id.contains('Video')) {
        String videoURL = doc.data()['Video ID'];
        String videoID = videoURL.split('=')[1];
        return new VideoPage(id: videoID, title: videoID);
      }

      if (doc.id.contains('Reading')) {
        return new ReadingPage(
          title: doc.data()['Title'],
          doc: doc,
        );
      }

      //If this document has 'evaluation' in the name, create an ecaluation page from its contents
      if (doc.id.contains('Evaluation')) {
        return new EvaluationBuilder(
            key: widget.key, title: 'Evaluation', doc: doc);
      }
    }).toList();
  }
}
