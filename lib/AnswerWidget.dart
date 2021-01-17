import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//This is not the most elegant solution, but I don't see another solution at the moment
//Enums to represent each answer in a multiple-choice question
enum SelectedAnswer { q1, q2, q3, q4, q5, q6, q7, q8 }

//Extension of RadioListTile that also contains a bool for storing whether the answer is correct
class AnswerWidget extends StatefulWidget {
  AnswerWidget({Key key, this.answer, this.isCorrect, this.answerTile})
      : super(key: key);

  final RadioListTile answerTile;
  final QueryDocumentSnapshot answer;
  final bool isCorrect;

  @override
  _AnswerWidgetState createState() => _AnswerWidgetState();
}

class _AnswerWidgetState extends State<AnswerWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.answerTile;
  }
}
