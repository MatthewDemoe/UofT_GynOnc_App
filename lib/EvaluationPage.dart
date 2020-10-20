import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'QuestionWidget.dart';

class EvaluationPage extends StatefulWidget {
  EvaluationPage({Key key, this.title, this.doc}) : super(key: key);

  final String title;
  final QueryDocumentSnapshot doc;

  @override
  _EvaluationPageState createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(widget.doc.reference.collection('Questions').path)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 110.0,
            child: CircularProgressIndicator(),
          );
        }

        return ListView(
          physics: BouncingScrollPhysics(),
          children: formQuestions(snapshot),
        );
      },
    ));
  }

  List<Widget> formQuestions(AsyncSnapshot<QuerySnapshot> snapshot) {
    int counter = 0;
    return snapshot.data.docs.map((question) {
      counter++;
      return QuestionWidget(
        key: widget.key,
        doc: question,
        questionNum: counter,
      );

      /*Container(
          padding: EdgeInsets.all(10),
          child: Text(
            counter.toString() + '. ' + question.data()['Question'],
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 18),
          ));*/
    }).toList();
  }
}
