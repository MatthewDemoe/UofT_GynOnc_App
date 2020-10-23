import 'package:flutter/material.dart';
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
  double numCorrect = 0.0;
  double percentCorrect = 0.0;

  @override
  Widget build(BuildContext context) {
    theQuestions = widget.evaluationPage.getQuestions();
    return Container();
  }

  /*List<Widget> showAnswers(List<QuestionWidget> questions) {
    return questions.map((q) {
      int tmp = q.evaluateAnswer();

      setState(() {
        numCorrect += tmp;
      });
      
      return QuestionWidget()
    }).toList();
  }*/
}
