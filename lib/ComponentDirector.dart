import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uoft_gynonc_app/EvaluationBuilder.dart';
import 'package:uoft_gynonc_app/HelperFunctions.dart';
import 'package:uoft_gynonc_app/ReferencesPage.dart';
import 'VideoPage.dart';
import 'AnimatedComponent.dart';
import 'ReadingPage.dart';
import 'TableOfContentsPage.dart';
import 'LifecycleEventHandler.dart';

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
  List<String> pageTitles = [];

  List<AnimatedComponent> pages = [];
  DateTime timeOnInit;

  bool isInitialized = false;
  LifecycleEventHandler lifecycleEventHandler;
  @override
  void initState() {
    super.initState();

    initComponents();

    timeOnInit = DateTime.now();
  }

  @override
  void dispose() {    
    updateTime(section: widget.doc.id, hours: DateTime.now().hour - timeOnInit.hour, minutes: DateTime.now().minute - timeOnInit.minute);    
    super.dispose();
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
          onPressed: () {
            updateTime(section: widget.doc.id, hours: DateTime.now().hour - timeOnInit.hour, minutes: DateTime.now().minute - timeOnInit.minute);
            Navigator.of(context).pop();
            },
        ),
        title: isInitialized ? Text(
          //Get the title of the current page from the list
          pageTitles[pageNum] +
              ' ' +
              //Current page
              (pageNum + 1).toString() +
              '/' +
              //Total pages
              numPages.toString(),
        ) : Text("First Page"),
        actions: [
          //Display a back button if we arent' on the first page
          if (pageNum > 0)
            IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  pages[pageNum].transition(whenComplete: () {
                    setState(() {
                      flipPage(-1);
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
                      flipPage(1);
                    });
                  });
                }),
        ],
      ),
    );
  }

  void flipPage(int dir)
  {    
    setState(() {
      pageNum = (pageNum + dir).clamp(0, numPages - 1);
    });           
  }

  void initComponents() {
    Stream<QuerySnapshot> col = FirebaseFirestore.instance
        .collection(widget.doc.reference.collection('Components').path)
        .snapshots();

    int counter = 0;

    pageTitles.add("Table of Contents");
    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
    detachedCallBack: () async {
      updateTime(section: widget.doc.id, hours: DateTime.now().hour - timeOnInit.hour, minutes: DateTime.now().minute - timeOnInit.minute)
      .then((value) => timeOnInit = DateTime.now());
      }, 
    resumeCallBack: () async => timeOnInit = DateTime.now()
    ));

    
   col.listen((event) {
      event.docs.forEach((element) {
        counter++;

        pageTitles.add(element.data()['Page Title']);
      });
    });
    
    
    pages.add(new AnimatedComponent(
      key : ObjectKey(0), 
      child: new TableOfContentsPage(
        pageTitles : pageTitles, 
        function: (i) => flipPage(i),))
        );
        

    int newCounter = 0;

    col.listen((event) {
      event.docs.forEach((element) {
        
        setState(() {
          newCounter++;
          
        });
        if (element.id.contains('Contributors')) {

          pages.add(new AnimatedComponent(
              key: ObjectKey(newCounter),
              child: ReferencesPage(title: '',doc: element)));
        }
        

        else if (element.id.contains('Video')) {

          String videoURL = element.data()['Video ID'];
          String videoID = videoURL.split('=')[1];
          pages.add(new AnimatedComponent(
              key: ObjectKey(newCounter),
              child: VideoPage(id: videoID, title: videoID)));
        }

        else if (element.id.contains('Reading')) {

          pages.add(new AnimatedComponent(
              key: ObjectKey(newCounter),
              child: ReadingPage(
                title: element.data()['Title'],
                doc: element,
              )));
        }

        else if (element.id.contains('Evaluation')) {

          pages.add(new AnimatedComponent(
              key: ObjectKey(newCounter),
              child: EvaluationBuilder(
                  key: widget.key, title: 'Evaluation', doc: element, pageNum: newCounter, flipToPage: (x) => flipPage(x),)));
        }
      });
      setState(() {
        isInitialized = true;
        numPages = pages.length;
      });
      
    });
  }
}
