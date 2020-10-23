import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AnswerWidget.dart';

enum SelectedAnswer { q1, q2, q3, q4, q5, q6, q7, q8 }

class QuestionWidget extends StatefulWidget {
  QuestionWidget({
    Key key,
    this.doc,
    this.questionNum,
  }) : super(key: key);

  final QueryDocumentSnapshot doc;
  final int questionNum;

  final _QuestionWidgetState myState = new _QuestionWidgetState();

  @override
  _QuestionWidgetState createState() => myState;

  int evaluateAnswer() {
    int tmp = myState.evaluateAnswer();
    print('In Widget: ' + tmp.toString());
    return tmp;
  }

  void showAnswer() {
    myState.showAnswer();
  }
}

class _QuestionWidgetState extends State<QuestionWidget> {
  bool hideAnswers = true;
  SelectedAnswer selectedAnswer = SelectedAnswer.q1;
  List<AnswerWidget> answerTiles = new List<AnswerWidget>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            padding: EdgeInsets.all(10),
            child: Text(
              widget.questionNum.toString() +
                  '. ' +
                  widget.doc.data()['Question'],
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 18),
            )),
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection(widget.doc.reference.collection('Answers').path)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Container(
                height: 110.0,
                child: CircularProgressIndicator(),
              );
            }

            answerTiles = formAnswers(snapshot);
            return Column(
              children: answerTiles,
            );
          },
        )
      ]),
    );
  }

  List<Widget> formAnswers(AsyncSnapshot<QuerySnapshot> snapshot) {
    int counter = -1;
    if (snapshot.data != null) {
      return snapshot.data.docs.map((answer) {
        counter++;
        print(answer.data()['isCorrect']);
        return AnswerWidget(
          answerTile: RadioListTile<SelectedAnswer>(
            activeColor: hideAnswers
                ? Colors.blue
                : answer.data()['isCorrect'] ? Colors.green : Colors.red,
            title: Text(answer.data()['Answer']),
            value: SelectedAnswer.values[counter],
            groupValue: selectedAnswer,
            onChanged: (SelectedAnswer value) {
              setState(() {
                selectedAnswer = value;
              });
            },
          ),
          isCorrect: answer.data()['isCorrect'],
        );
      }).toList();
    }
  }

  int evaluateAnswer() {
    print(answerTiles.length);
    int toReturn = 0;
    answerTiles.forEach((element) {
      if (element.isCorrect) {
        if (element.answerTile.checked) {
          print('Correct answer checked');
          toReturn = 1;
        } else {
          print('Incorrect answer checked');
        }
      }
    });
    print('Returning 0');
    showAnswer();
    return toReturn;
  }

  void showAnswer() {
    setState(() {
      hideAnswers = false;
    });
  }
}
