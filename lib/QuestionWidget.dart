import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum SelectedAnswer { q1, q2, q3, q4 }

class QuestionWidget extends StatefulWidget {
  QuestionWidget({
    Key key,
    this.doc,
    this.questionNum,
  }) : super(key: key);

  final QueryDocumentSnapshot doc;
  final int questionNum;

  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  bool _isRadioSelected = false;
  SelectedAnswer selectedAnswer = SelectedAnswer.q1;

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

            return Column(
              children: formAnswers(snapshot),
            );
          },
        )
      ]),
    );
  }

  List<Widget> formAnswers(AsyncSnapshot<QuerySnapshot> snapshot) {
    int counter = -1;
    return snapshot.data.docs.map((answer) {
      counter++;

      return RadioListTile<SelectedAnswer>(
        title: Text(answer.data()['Answer']),
        value: SelectedAnswer.values[counter],
        groupValue: selectedAnswer,
        onChanged: (SelectedAnswer value) {
          setState(() {
            selectedAnswer = value;
          });
        },
      );
    }).toList();
  }
}
