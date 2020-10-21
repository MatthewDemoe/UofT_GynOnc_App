import 'package:flutter/material.dart';

class AnswerWidget extends StatefulWidget {
  AnswerWidget({Key key, this.answerTile, this.isCorrect}) : super(key: key);

  final RadioListTile answerTile;
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
