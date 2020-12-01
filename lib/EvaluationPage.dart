import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:uoft_gynonc_app/CountdownTimer.dart';
import 'package:uoft_gynonc_app/HelperFunctions.dart';
import 'package:uoft_gynonc_app/SliverTimerHeader.dart';
import 'QuestionWidget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'EvaluationTimer.dart';

class EvaluationPage extends StatefulWidget {
  EvaluationPage({Key key, this.title, this.doc}) : super(key: key);

  final String title;
  //The evaluation document in firebase
  final QueryDocumentSnapshot doc;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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

  bool started = false;

  //EvaluationTimer eTimer = EvaluationTimer(duration: 15);

  CountdownTimer myTimer =
      CountdownTimer(timerDuration: 15, eTimer: EvaluationTimer(duration: 15));

  @override
  void initState() {
    myTimer.subscribe(() {
      evaluateQuestions();

      showSnackbar(
          context, 'Time has run out. Your answers have been submitted.');
    });

    super.initState();

    //If we are in 'Evaluation' then two levels up is the module name
    //We'll use this to store user scores
    moduleID = widget.doc.reference.parent.parent.id;

    loadQuestions();

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
            style: TextStyle(fontSize: 28, color: Colors.white),
          ),

          //Evaluate each answer when we click submit
          onPressed: () {
            myTimer.cancel();

            //initialize the amount of correct answers
            evaluateQuestions();
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: widget.scaffoldKey,
        body: started
            ? CustomScrollView(physics: BouncingScrollPhysics(), slivers: [
                SliverPersistentHeader(
                    pinned: true, delegate: SliverTimerHeader(myTimer)),
                SliverList(
                    delegate: SliverChildListDelegate(
                        theWidgets + ((hideAnswers) ? [submitButton] : mark)))
              ])
            : Container(
                alignment: Alignment.center,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 50),
                      height: 150,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        fit: BoxFit.fitHeight,
                        image: AssetImage('assets/GynOnc_Logo.png'),
                      )),
                    ),
                    Container(
                        padding: EdgeInsets.all(50),
                        height: 200,
                        width: 200,
                        child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            color: getAppColor(),
                            child: Text(
                              'Start',
                              style:
                                  TextStyle(fontSize: 28, color: Colors.white),
                            ),
                            onPressed: () {
                              myTimer.init();

                              setState(() {
                                started = true;
                              });
                            }))
                  ],
                )));
  }

  void evaluateQuestions() {
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
      percent = (correctAnswers.toDouble() / theQuestions.length.toDouble());

      //Stop hiding correct answers
      hideAnswers = false;
    });
    mark.add(new Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
        child: Text(
          (percent * 100.0).round().toString() + '%',
          style: TextStyle(
              fontSize: 48,
              //Interpolate between green and red based on score
              color: Color.lerp(Colors.red, Colors.green, percent)),
        )));

    updateMark(
        section: moduleID, mark: (percent * 100.0).round().toString() + '%');

    mark.add(Container(
        padding: EdgeInsets.only(bottom: 25),
        child: RichText(
            textAlign: TextAlign.center,
            text: new TextSpan(children: [
              TextSpan(
                  text: 'Click ',
                  style: TextStyle(
                      color: Colors.black, fontSize: getDefaultFontSize())),
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
                      color: Colors.black, fontSize: getDefaultFontSize())),
            ]))));
  }

  Future<void> loadQuestions() async {
    Stream<QuerySnapshot> snap = FirebaseFirestore.instance
        .collection(widget.doc.reference.collection('Questions').path)
        .snapshots();

    StreamIterator<QuerySnapshot> iterator =
        StreamIterator<QuerySnapshot>(snap);

    int counter = 0;
    while (await iterator.moveNext()) {
      iterator.current.docs.forEach((element) {
        counter++;

        QuestionWidget tmp = QuestionWidget(
          doc: element,
          initialNum: counter,
          shouldShow: true,
        );

        evaluations.add(0);

        tmp.evaluationEvent.subscribe((args) {
          evaluations[tmp.initialNum - 1] = args.value;
        });

        theQuestions.add(tmp);
        theWidgets.add(tmp);
      });
    }
  }
}
