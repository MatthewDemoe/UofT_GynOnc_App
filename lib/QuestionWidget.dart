import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'HelperFunctions.dart';
import 'package:event/event.dart';

import 'AnswerWidget.dart';

class QuestionWidget extends StatefulWidget {
  QuestionWidget({
    Key key,
    this.doc,
    this.questionNum,
  }) : super(key: key);

  final evaluationEvent = Event<ValueEventArgs>();
  final showAnswerEvent = Event();

  //The question document we are building from
  final QueryDocumentSnapshot doc;
  //The question number we are on
  final int questionNum;

  void showAnswers() {
    showAnswerEvent.broadcast();
  }

  _QuestionWidgetState createState() => _QuestionWidgetState();

  //Evaluate answer based on state of this widget
  //Returns 1 for correct answers or 0 for incorrect
  int evaluateAnswer() {
    return 0;
    //int tmp = evaluateAnswer();
    //return tmp;
  }
}

class _QuestionWidgetState extends State<QuestionWidget>
    with AutomaticKeepAliveClientMixin {
  //Should we show the user the correct answer?
  bool hideAnswers = true;
  //Initialize the currently selected answer
  SelectedAnswer selectedAnswer = SelectedAnswer.q1;
  //A list of all the possible answers for this question
  List<AnswerWidget> answerTiles = new List<AnswerWidget>();

  Widget img;

  bool wantKeepAlive = true;

  //Returns a list of answer widgets for this question

  @override
  initState() {
    super.initState();
    //Load the image in once, so that we don't keep reading from the database
    //Each time the widget is built
    if (widget.doc.data().keys.contains('Image'))
      img = buildImage(widget.doc.data()['Image']);

    widget.showAnswerEvent.subscribe((args) {
      setState(() {
        hideAnswers = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: EdgeInsets.all(10),
      //Arrange questions in a column
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (widget.doc.data().keys.contains('Image')) img,

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
                width: 110.0,
                //while we wait...
                child: CircularProgressIndicator(),
              );
            }

            answerTiles = formAnswers(snapshot);

            //Initial evaluation
            widget.evaluationEvent.broadcast(ValueEventArgs(evaluateAnswer()));

            return Column(
              children: answerTiles,
            );
          },
        )
      ]),
    );
  }

  //Returns 1 if the correct answer is selected, otherwise returns 0
  //Also shows answers
  int evaluateAnswer() {
    int toReturn = 0;
    answerTiles.forEach((element) {
      if (element.isCorrect) {
        if (element.answerTile.checked) {
          toReturn = 1;
        } else {}
      }
    });

    //hideAnswers = false;
    return toReturn;
  }

  List<Widget> formAnswers(AsyncSnapshot<QuerySnapshot> snapshot) {
    //Initialize an answer counter, used to set the enum value of each question
    int counter = -1;
    if (snapshot.data != null) {
      List<Widget> answers = snapshot.data.docs.map((doc) {
        counter++;
        return AnswerWidget(
          answer: doc,
          //is this the correct answer?
          isCorrect: doc.data()['isCorrect'],
          answerTile: RadioListTile<SelectedAnswer>(
            //If we are hiding the answers, display the radio button as blue
            activeColor: hideAnswers
                ? Colors.blue
                //If we are not hiding the answers, display radio buttons as either red or green
                : doc.data()['isCorrect'] ? Colors.green : Colors.red,
            //The text the answer widget will display
            title: Text(doc.data()['Answer']),
            //The enum value this answer represents
            value: SelectedAnswer.values[counter],
            //the enum variable
            groupValue: selectedAnswer,
            //Change the selected answer to whatever was clicked on
            onChanged: (SelectedAnswer value) {
              setState(() {
                selectedAnswer = value;
              });
              widget.evaluationEvent
                  .broadcast(ValueEventArgs(evaluateAnswer()));
            },
          ),
        );
      }).toList();

      return answers;
    }

    return null;
  }
}

class ValueEventArgs extends EventArgs {
  int value;

  ValueEventArgs(this.value);
}
