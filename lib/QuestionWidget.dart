import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AnswerWidget.dart';

//This is not the most elegant solution, but I don't see another solution at the moment
//Enums to represent each answer in a multiple-choice question
enum SelectedAnswer { q1, q2, q3, q4, q5, q6, q7, q8 }

class QuestionWidget extends StatefulWidget {
  QuestionWidget({
    Key key,
    this.doc,
    this.questionNum,
  }) : super(key: key);

  //The question document we are building from
  final QueryDocumentSnapshot doc;
  //The question number we are on
  final int questionNum;

  final _QuestionWidgetState myState = new _QuestionWidgetState();

  @override
  _QuestionWidgetState createState() => myState;

  //Evaluate answer based on state of this widget
  //Returns 1 for correct answers or 0 for incorrect
  int evaluateAnswer() {
    int tmp = myState.evaluateAnswer();
    return tmp;
  }

  void showAnswer() {
    myState.showAnswer();
  }
}

class _QuestionWidgetState extends State<QuestionWidget> {
  //Should we show the user the correct answer?
  bool hideAnswers = true;
  //Initialize the currently selected answer
  SelectedAnswer selectedAnswer = SelectedAnswer.q1;
  //A list of all the possible answers for this question
  List<AnswerWidget> answerTiles = new List<AnswerWidget>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      //Arrange questions in a column
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            padding: EdgeInsets.all(10),
            child: Text(
              //The question number we are on
              widget.questionNum.toString() +
                  '. ' +
                  //The text of the question, from firebase
                  widget.doc.data()['Question'],
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 18),
            )),
        //Build our answers from the 'answers' collection
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection(widget.doc.reference.collection('Answers').path)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Container(
                height: 110.0,
                //while we wait...
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

  //Create a list of answer widgets for this question
  List<Widget> formAnswers(AsyncSnapshot<QuerySnapshot> snapshot) {
    //Initialize an answer counter, used to set the enum value of each question
    int counter = -1;
    if (snapshot.data != null) {
      return snapshot.data.docs.map((answer) {
        counter++;
        return AnswerWidget(
          answerTile: RadioListTile<SelectedAnswer>(
            //If we are hiding the answers, display the radio button as blue
            activeColor: hideAnswers
                ? Colors.blue
                //If we are not hiding the answers, display radio buttons as either red or green
                : answer.data()['isCorrect'] ? Colors.green : Colors.red,
            //The text the answer widget will display
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
    int toReturn = 0;
    answerTiles.forEach((element) {
      if (element.isCorrect) {
        if (element.answerTile.checked) {
          toReturn = 1;
        } else {}
      }
    });
    showAnswer();
    return toReturn;
  }

  void showAnswer() {
    setState(() {
      hideAnswers = false;
    });
  }
}
