import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'QuestionWidget.dart';

class EvaluationPage extends StatefulWidget {
  EvaluationPage({Key key, this.title, this.doc}) : super(key: key);

  final String title;
  final QueryDocumentSnapshot doc;

  final _EvaluationPageState myState = new _EvaluationPageState();

  @override
  _EvaluationPageState createState() => myState;

  List<QuestionWidget> getQuestions() {
    return myState.theQuestions;
  }
}

class _EvaluationPageState extends State<EvaluationPage> {
  List<QuestionWidget> theQuestions = new List<QuestionWidget>();
  List<Widget> theWidgets = new List<Widget>();
  bool hideAnswers = true;

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

        if (hideAnswers) {
          theQuestions = formQuestions(snapshot);

          theWidgets.addAll(theQuestions);
          /*theQuestions.forEach((element) {
            theWidgets.add(element);
          });*/

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
                    int tmp = element.evaluateAnswer();
                    correctAnswers += tmp;
                  });

                  double percent = (correctAnswers.toDouble() /
                      theQuestions.length.toDouble());

                  setState(() {
                    theWidgets.clear();
                    theWidgets = new List<Widget>();
                    hideAnswers = false;

                    theWidgets.addAll(theQuestions);

                    theWidgets.add(new Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 50),
                        child: Text(
                          (percent * 100.0).round().toString() + '%',
                          style: TextStyle(
                              fontSize: 48,
                              color: Color.lerp(
                                  Colors.red, Colors.green, percent)),
                        )));
                  });
                },
              )));
        }

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
        doc: question,
        questionNum: counter,
      );
    }).toList();
  }
}
