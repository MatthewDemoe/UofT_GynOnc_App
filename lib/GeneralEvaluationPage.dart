import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:uoft_gynonc_app/HelperFunctions.dart';
import 'package:uoft_gynonc_app/SliverTimerHeader.dart';
import 'dart:math';
import 'QuestionWidget.dart';
import 'CallbackTimer.dart';
import 'VisualTimer.dart';

class GeneralEvaluationPage extends StatefulWidget {
  GeneralEvaluationPage({Key key, this.title}) : super(key: key);

  final String title;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  _GeneralEvaluationPageState createState() =>
      new _GeneralEvaluationPageState();

  //Return the list of questions that is stored in the state of this widget
}

class _GeneralEvaluationPageState extends State<GeneralEvaluationPage> {
  //The list of question widgets in the evaluation
  List<QuestionWidget> theQuestions = new List<QuestionWidget>();
  List<QuestionWidget> allQuestions = new List<QuestionWidget>();

  //All widgets we will display, contains question widgets as well as other types of widgets
  List<Widget> theWidgets = new List<Widget>();
  //After the users submit their answers, we will show which are correct/incorrect
  bool hideAnswers = true;
  int correctAnswers = 0;

  int numQuestions = 5;

  List<int> evaluations = new List<int>();

  Widget startButton;
  Widget mark;
  bool started = false;
  bool submitted = false;

  double percent = 0;

  int timerDuration = 0;

  VisualTimer myTimer;

  @override
  void initState() {
    super.initState();

    loadQuestions();

    /*myTimer.subscribe(() {
      evaluateQuestions();

      showSnackbar(Scaffold.of(widget.scaffoldKey.currentContext).context,
          'Time has run out. Your answers have been submitted.');
    });*/

    initWidgets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: widget.scaffoldKey,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        //Get the list of questions from firebase
        body: started
            ? CustomScrollView(physics: BouncingScrollPhysics(), slivers: [
                SliverPersistentHeader(
                    pinned: true, delegate: SliverTimerHeader(myTimer)),
                SliverList(
                    delegate: SliverChildListDelegate(
                        (submitted ? theWidgets + [mark] : theWidgets)))
              ])
            : buildStartPage() /*Container(
                alignment: Alignment.center,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      padding: EdgeInsets.symmetric(vertical: 50),
                      height: 150,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.fitHeight,
                              image: AssetImage('assets/GynOnc_Logo.png'))),
                    ),
                    startButton
                  ],
                ),
              )*/
        );
  }

  Future<void> loadQuestions() async {
    DocumentReference doc =
        FirebaseFirestore.instance.collection('Question Bank').doc('Questions');

    int counter = 0;
    doc.snapshots().forEach((element) {
      element.data().forEach((key, value) {
        CollectionReference tmpCol =
            FirebaseFirestore.instance.collection(value);

        tmpCol.snapshots().forEach((element) {
          element.docs.forEach((e) {
            counter++;

            allQuestions.add(QuestionWidget(
              doc: e,
              initialNum: counter,
              shouldShow: false,
            ));
          });
        });
      });
    });
  }

  void evaluateQuestions() {
    myTimer.cancel();

    //Iterate through each question
    evaluations.forEach((element) {
      //Evaluate the submitter answer, will return 1 if correct, 0 if incorrect

      //Count the correct answers
      setState(() {
        correctAnswers += element;
      });
    });
    //Calculate the percentage of correct answers

    setState(() {
      submitted = true;
      percent = (correctAnswers.toDouble() / theQuestions.length.toDouble());
      //Clear widgets on the page(we just want to get rid of the submit button )
      theWidgets.clear();
      theWidgets = new List<Widget>();

      //Stop hiding correct answers
      hideAnswers = false;

      //Add the questions back
      theWidgets.addAll(theQuestions);

      mark = Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 50),
          child: Text(
            (percent * 100.0).round().toString() + '%',
            style: TextStyle(
                fontSize: 48,
                //Interpolate between green and red based on score
                color: Color.lerp(Colors.red, Colors.green, percent)),
          ));
    });

    updateMark(
        section: 'Overall', mark: (percent * 100.0).round().toString() + '%');
  }

  void initializeQuiz() {
    setState(() {
      started = true;
    });

    theWidgets.addAll(theQuestions);

    theWidgets.add(Container(
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
            evaluateQuestions();
          },
        )));
  }

  void initWidgets() {
    mark = Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 50),
        child: Text(
          (percent * 100.0).round().toString() + '%',
          style: TextStyle(
              fontSize: 48,
              //Interpolate between green and red based on score
              color: Color.lerp(Colors.red, Colors.green, percent)),
        ));

    startButton = Container(
        padding: EdgeInsets.all(50),
        height: 200,
        width: 200,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          color: getAppColor(),
          child: Text(
            'Start',
            style: TextStyle(fontSize: 28, color: Colors.white),
          ),

          //Evaluate each answer when we click submit
          onPressed: () {
            //myTimer.init();

            Random rng = new Random();
            int idx = 0;
            for (int i = 0; i < numQuestions; i++) {
              idx = rng.nextInt(allQuestions.length - 1);
              evaluations.add(0);

              //allQuestions[idx]
              QuestionWidget q = allQuestions[idx];

              QuestionWidget tmp = new QuestionWidget(
                doc: q.doc,
                shouldShow: q.shouldShow,
                initialNum: i + 1,
              );

              tmp.evaluationEvent.subscribe((args) {
                evaluations[tmp.initialNum - 1] = args.value;
              });

              theQuestions.add(tmp);
              allQuestions.removeAt(idx);
            }

            initializeQuiz();
          },
        ));
  }

  Future<bool> initializeTimer() async {
    Stream<DocumentSnapshot> evalDoc =
        FirebaseFirestore.instance.doc('Question Bank/Questions').snapshots();

    StreamIterator<DocumentSnapshot> iterator =
        StreamIterator<DocumentSnapshot>(evalDoc);

    if (await iterator.moveNext()) {
      if (iterator.current.data().containsKey('Timer')) {
        setState(() {
          timerDuration = iterator.current.data()['Timer'];
        });

        createTimers(durationMinutes: timerDuration);
        return true;
      }
    }

    createTimers(durationMinutes: 0);
    return false;
  }

  void createTimers({int durationMinutes}) {
    myTimer = VisualTimer(
        timerDuration: durationMinutes,
        eTimer: CallbackTimer(durationSeconds: durationMinutes * 60));

    myTimer.subscribe(() {
      evaluateQuestions();

      showSnackbar(Scaffold.of(widget.scaffoldKey.currentContext).context,
          'Time has run out. Your answers have been submitted.');
    });
  }

  Widget buildStartPage() {
    return FutureBuilder(
        future: initializeTimer(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.hasData) {
            return Container(
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
                      padding: EdgeInsets.only(top: 50),
                      alignment: Alignment.center,
                      child: Text(
                        'Overall Evaluation',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800]),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 25),
                      alignment: Alignment.center,
                      child: Text(
                        'Evaluation Time : ' +
                            buildTimerText(timerDuration) +
                            ((timerDuration < 2) ? ' minute.' : ' minutes.'),
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800]),
                      ),
                    ),
                    startButton,
                  ],
                ));
          }

          return LinearProgressIndicator();
        });
  }
}
