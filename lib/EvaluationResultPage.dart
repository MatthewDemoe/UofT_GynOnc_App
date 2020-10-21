import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'QuestionWidget.dart';
import 'EvaluationPage.dart';

class EvaluationResultsPage extends StatefulWidget {
  EvaluationResultsPage({Key key, this.evaluationPage}) : super(key: key);

  final EvaluationPage evaluationPage;

  @override
  _EvaluationResultsPageState createState() => _EvaluationResultsPageState();
}

class _EvaluationResultsPageState extends State<EvaluationResultsPage> {
  List<QuestionWidget> theQuestions = new List<QuestionWidget>();
  List<Widget> theWidgets = new List<Widget>();

  @override
  Widget build(BuildContext context) {
    return Container();
    /*Scaffold(
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

        theQuestions = formQuestions(snapshot);

        theQuestions.forEach((element) {
          theWidgets.add(element);
        });
        theWidgets.add(Container(
            padding: EdgeInsets.all(10),
            height: 100,
            width: 200,
            child: RaisedButton(
              child: Text(
                'Submit',
                style: TextStyle(fontSize: 28),
              ),
              onPressed: () => theQuestions.forEach((element) {
                element.evaluate();
              }),
            )));

        return ListView(
          physics: BouncingScrollPhysics(),
          children: theWidgets,
        );
      },
    ));*/
  }

  List<QuestionWidget> formQuestions(AsyncSnapshot<QuerySnapshot> snapshot) {
    int counter = 0;
    return snapshot.data.docs.map((question) {
      counter++;
      return QuestionWidget(
        key: widget.key,
        doc: question,
        questionNum: counter,
      );
    }).toList();
  }
}
