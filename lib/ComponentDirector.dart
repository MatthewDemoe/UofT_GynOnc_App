import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'VideoPage.dart';
import 'EvaluationPage.dart';

class ComponentDirector extends StatefulWidget {
  ComponentDirector({Key key, this.title, this.doc, this.pageNum})
      : super(key: key);

  final String title;
  final QueryDocumentSnapshot doc;
  final int pageNum;

  @override
  _ComponentDirectorState createState() => _ComponentDirectorState(pageNum);
}

class _ComponentDirectorState extends State<ComponentDirector> {
  _ComponentDirectorState(int pageNum);

  int numPages;
  List<Widget> pages;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(widget.doc.reference.collection('Components').path)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData)
          return new Container(
            height: 110.0,
            child: CircularProgressIndicator(),
          );

        pages = parseComponents(snapshot);

        numPages = pages.length;

        return Scaffold(
          body: pages[widget.pageNum],
          appBar: AppBar(
            title: Text(
              widget.title +
                  ' ' +
                  (widget.pageNum + 1).toString() +
                  '/' +
                  snapshot.data.size.toString(),
            ),
            actions: [
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (widget.pageNum < (numPages - 1)) {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ComponentDirector(
                                        title: widget.title,
                                        doc: widget.doc,
                                        pageNum: (widget.pageNum + 1),
                                      )));
                        }
                      });
                    },
                    child: Icon(
                      Icons.arrow_forward,
                      size: 26.0,
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  List<Widget> parseComponents(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.docs.map((doc) {
      if (doc.id.contains('Video')) {
        return new VideoPage(
            id: doc.data()['Video ID'], title: doc.data()['Video ID']);
      }
      if (doc.id.contains('Evaluation')) {
        return new EvaluationPage(
            key: widget.key, title: 'Evaluation', doc: doc);
      }
    }).toList();
  }
}
