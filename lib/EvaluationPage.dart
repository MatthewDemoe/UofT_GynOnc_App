import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'QuestionWidget.dart';

class EvaluationPage extends StatefulWidget {
  EvaluationPage({Key key, this.title, this.doc}) : super(key: key);

  final String title;
  //The evaluation document in firebase
  final QueryDocumentSnapshot doc;

  final _EvaluationPageState myState = new _EvaluationPageState();

  @override
  _EvaluationPageState createState() => myState;

  List<QuestionWidget> getQuestions() {
    return myState.theQuestions;
  }
}

class _EvaluationPageState extends State<EvaluationPage> {
  //The list of question widgets in the evaluation
  List<QuestionWidget> theQuestions = new List<QuestionWidget>();
  //All widgets we will display, contains question widgets as well as other types of widgets
  List<Widget> theWidgets = new List<Widget>();
  //After the users submit their answers, we will show which are correct/incorrect
  bool hideAnswers = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //Get the list of questions from firebase
        body: StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(widget.doc.reference.collection('Questions').path)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 110.0,
            //While we wait...
            child: CircularProgressIndicator(),
          );
        }

        if (hideAnswers) {
          //Create all the question widgets from the snapshot
          theQuestions = formQuestions(snapshot);

          //Add all the questions to the list
          //the if statement we are in prevents them from being added twice
          theWidgets.addAll(theQuestions);

          //Also add the submit button
          theWidgets.add(Container(
              padding: EdgeInsets.all(10),
              height: 100,
              width: 200,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                color: Colors.cyan[700],
                child: Text(
                  'Submit',
                  style: TextStyle(fontSize: 28),
                ),

                //Evaluate each answer when we click submit
                onPressed: () {
                  //initialize the amount of correct answers
                  int correctAnswers = 0;

                  //Iterate through each question
                  theQuestions.forEach((element) {
                    //Evaluate the submitter answer, will return 1 if correct, 0 if incorrect
                    int tmp = element.evaluateAnswer();
                    //Count the correct answers
                    correctAnswers += tmp;
                  });
                  //Calculate the percentage of correct answers
                  double percent = (correctAnswers.toDouble() /
                      theQuestions.length.toDouble());

                  setState(() {
                    //Clear widgets on the page(we just want to get rid of the submit button )
                    theWidgets.clear();
                    theWidgets = new List<Widget>();

                    //Stop hiding correct answers
                    hideAnswers = false;

                    //Add the questions back
                    theWidgets.addAll(theQuestions);

                    //Add a widget showing the evaluation results
                    theWidgets.add(new Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 50),
                        child: Text(
                          (percent * 100.0).round().toString() + '%',
                          style: TextStyle(
                              fontSize: 48,
                              //Interpolate between green and red based on score
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
    //Initialize a question counter,
    //this is just used to add a number at the beginning of the question's text
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
