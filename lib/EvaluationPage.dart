import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:uoft_gynonc_app/HelperFunctions.dart';
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
  double percent = 0;

  Widget submitButton;
  List<Widget> mark = new List<Widget>();

  List<int> evaluations = new List<int>();

  //The name of the module we are in
  String moduleID;

  @override
  void initState() {
    super.initState();

    //If we are in 'Evaluation' then two levels up is the module name
    //We'll use this to store user scores
    moduleID = widget.doc.reference.parent.parent.id;
  }

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
            width: 110.0,
            //While we wait...
            child: CircularProgressIndicator(),
          );
        }

        theQuestions = formQuestions(snapshot);

        if (theWidgets.isEmpty) {
          theWidgets.addAll(theQuestions);
          submitButton = Container(
              padding: EdgeInsets.all(10),
              height: 100,
              width: 200,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                color: getAppColor(),
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
                    //Count the correct answers
                    correctAnswers += element;
                  });
                  //Calculate the percentage of correct answers

                  setState(() {
                    percent = (correctAnswers.toDouble() /
                        theQuestions.length.toDouble());

                    //Stop hiding correct answers
                    hideAnswers = false;
                  });
                  mark.add(new Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 10),
                      child: Text(
                        (percent * 100.0).round().toString() + '%',
                        style: TextStyle(
                            fontSize: 48,
                            //Interpolate between green and red based on score
                            color:
                                Color.lerp(Colors.red, Colors.green, percent)),
                      )));

                  updateMark(
                      section: moduleID,
                      mark: (percent * 100.0).round().toString() + '%');

                  mark.add(Container(
                      padding: EdgeInsets.only(bottom: 25),
                      child: RichText(
                          textAlign: TextAlign.center,
                          text: new TextSpan(children: [
                            TextSpan(
                                text: 'Click ',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: getDefaultFontSize())),
                            TextSpan(
                                text: 'here',
                                style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                    fontSize: getDefaultFontSize()),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launch(widget.doc.data()['Link']);
                                  }),
                            TextSpan(
                                text: ' for further reading.',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: getDefaultFontSize())),
                          ]))));
                },
              ));
        }

        return CustomScrollView(physics: BouncingScrollPhysics(), slivers: [
          SliverList(
              delegate: SliverChildListDelegate(
                  theWidgets + ((hideAnswers) ? [submitButton] : mark)))
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

      //print(question.data()['Question']);
      QuestionWidget tmp = QuestionWidget(
        doc: question,
        initialNum: counter,
        shouldShow: true,
      );

      evaluations.add(0);

      tmp.evaluationEvent.subscribe((args) {
        evaluations[tmp.initialNum - 1] = args.value;
      });

      //This is the name of the module
      //print(widget.doc.reference.parent.parent.id);
      //widget.doc.reference.parent.parent

      return tmp;
    }).toList();
  }
}
