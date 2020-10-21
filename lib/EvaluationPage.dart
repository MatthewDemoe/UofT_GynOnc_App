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
  List<QuestionWidget> theQuestions = new List<QuestionWidget>();
  List<Widget> theWidgets = new List<Widget>();

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
              onPressed: () {
                int correctAnswers = 0;

                theQuestions.forEach((element) {
                  //print(element.evaluateAnswer());
                  int tmp = element.evaluateAnswer();
                  correctAnswers += tmp;
                  //setState(() {});
                  /*setState(() {
                    correctAnswers += tmp;
                  });*/
                  //correctAnswers += element.evaluateAnswer();
                });
                //print(correctAnswers.toDouble().toString());
                print('Percent Correct: ' +
                    (correctAnswers.toDouble() / theQuestions.length.toDouble())
                        .toString());
              },
            )));

        return ListView(
          physics: BouncingScrollPhysics(),
          children: theWidgets,
        );
      },
    ));
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
