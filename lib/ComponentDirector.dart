import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'VideoPage.dart';
import 'EvaluationPage.dart';

//Widget for navigating through components of a module
class ComponentDirector extends StatefulWidget {
  ComponentDirector({Key key, this.title, this.doc, this.pageNum})
      : super(key: key);

  final String title;
  //The module we are moving through
  final QueryDocumentSnapshot doc;
  //the page we are currently on
  final int pageNum;

  @override
  _ComponentDirectorState createState() => _ComponentDirectorState();
}

class _ComponentDirectorState extends State<ComponentDirector> {
  _ComponentDirectorState();

  //Total number of pages in the module
  int numPages;
  //The widget representing each page
  List<Widget> pages;
  //The titles for each page
  List<String> pageTitles = new List<String>();

  @override
  Widget build(BuildContext context) {
    //Look at the collection of components for this module
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(widget.doc.reference.collection('Components').path)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData)
          return new Container(
            height: 110.0,
            //While we wait for data...
            child: CircularProgressIndicator(),
          );

        //Populate our list of pages
        if (pages == null) {
          pages = parseComponents(snapshot);

          numPages = pages.length;
        }

        return Scaffold(
          body: pages[widget.pageNum],
          appBar: AppBar(
            backgroundColor: Colors.cyan[700],
            //Home button that will return you to the main page
            leading: IconButton(
              icon: Icon(Icons.home),
              onPressed: () => Navigator.of(context).pop(),
            ),
            //Get the title of the current page from the list
            title: Text(
              pageTitles[widget.pageNum] +
                  ' ' +
                  //Current page
                  (widget.pageNum + 1).toString() +
                  '/' +
                  //Total pages
                  numPages.toString(),
            ),
            actions: [
              if (widget.pageNum > 0)
                IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ComponentDirector(
                                  title: widget.title,
                                  doc: widget.doc,
                                  pageNum: (widget.pageNum - 1),
                                )),
                      );
                    }),
              if (widget.pageNum < (numPages - 1))
                IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ComponentDirector(
                                  title: widget.title,
                                  doc: widget.doc,
                                  pageNum: (widget.pageNum + 1),
                                )),
                      );
                    }),
            ],
          ),
        );
      },
    );
  }

  List<Widget> parseComponents(AsyncSnapshot<QuerySnapshot> snapshot) {
    //Iterate through each document(component) in this collection(module)
    return snapshot.data.docs.map((doc) {
      //Get the page title from the database
      pageTitles.add(doc.data()['Page Title']);
      //If this document has 'video' in the name, create a video page from its video id field
      if (doc.id.contains('Video')) {
        return new VideoPage(
            id: doc.data()['Video ID'], title: doc.data()['Video ID']);
      }
      //If this document has 'evaluation' in the name, create an ecaluation page from its contents
      if (doc.id.contains('Evaluation')) {
        return new EvaluationPage(
            key: widget.key, title: 'Evaluation', doc: doc);
      }
    }).toList();
  }
}
