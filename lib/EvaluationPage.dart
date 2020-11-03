import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'QuestionWidget.dart';
import 'package:url_launcher/url_launcher.dart';

class EvaluationPage extends StatefulWidget {
  EvaluationPage({Key key, this.title, this.doc}) : super(key: key);

  final String title;
  //The evaluation document in firebase
  final QueryDocumentSnapshot doc;

  @override
  _EvaluationPageState createState() => new _EvaluationPageState();

  //Return the list of questions that is stored in the state of this widget
}

class _EvaluationPageState extends State<EvaluationPage> {
  int currentQuestion = 0;
  //The list of question widgets in the evaluation
  List<QuestionWidget> theQuestions = new List<QuestionWidget>();
  //All widgets we will display, contains question widgets as well as other types of widgets
  List<Widget> theWidgets = new List<Widget>();
  //After the users submit their answers, we will show which are correct/incorrect
  bool hideAnswers = true;
  int correctAnswers = 0;

  List<int> evaluations = new List<int>();

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

        theQuestions = formQuestions(snapshot);

        if (theWidgets.isEmpty) {
          theWidgets.addAll(theQuestions);

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
                  theQuestions.forEach((element) {
                    element.showAnswers();
                  });
                  //Iterate through each question
                  evaluations.forEach((element) {
                    //Evaluate the submitter answer, will return 1 if correct, 0 if incorrect
                    //int tmp = element.evaluateAnswer();

                    //Count the correct answers
                    correctAnswers += element;
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
                            left: 10, right: 10, top: 10, bottom: 10),
                        child: Text(
                          (percent * 100.0).round().toString() + '%',
                          style: TextStyle(
                              fontSize: 48,
                              //Interpolate between green and red based on score
                              color: Color.lerp(
                                  Colors.red, Colors.green, percent)),
                        )));

                    theWidgets.add(Container(
                      padding: EdgeInsets.only(bottom: 25),
                      child: RichText(
                      textAlign: TextAlign.center,
                      text: new TextSpan(children: [
                      TextSpan(text: 'Click ', style: TextStyle(color: Colors.black, fontSize: 18)), 
                      TextSpan(text: 'here', 
                        style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 18), 
                        recognizer: TapGestureRecognizer()..onTap = (){launch(widget.doc.data()['Link']);}), 
                      TextSpan(text: ' for further reading.', style: TextStyle(color: Colors.black, fontSize: 18)), 

                    ]))));
                  });
                },
              )));
        }

        return CustomScrollView(physics: BouncingScrollPhysics(), slivers: [
          SliverList(
              delegate: SliverChildListDelegate(
            theWidgets,
          ))
        ]);
      },
    ));
  }

  List<QuestionWidget> formQuestions(AsyncSnapshot<QuerySnapshot> snapshot) {
    //Initialize a question counter,
    //this is just used to add a number at the beginning of the question's text
    int counter = 0;
    return snapshot.data.docs.map((question) {
      counter = counter + 1;

      QuestionWidget tmp = QuestionWidget(
        doc: question,
        questionNum: counter,
      );

      evaluations.add(0);

      tmp.evaluationEvent.subscribe((args) {
        evaluations[tmp.questionNum - 1] = args.value;
      });

      return tmp;
    }).toList();
  }
}
