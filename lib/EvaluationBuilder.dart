import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:uoft_gynonc_app/CallbackTimer.dart';
import 'package:uoft_gynonc_app/QuestionWidget.dart';
import 'package:uoft_gynonc_app/SliverTimerHeader.dart';
import 'package:uoft_gynonc_app/VisualTimer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'HelperFunctions.dart';

class EvaluationBuilder extends StatefulWidget {
  EvaluationBuilder({Key key, this.title, this.doc, this.pageNum, this.flipToPage}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final QueryDocumentSnapshot doc;
  final String title;
  final int pageNum;
  final Function(int) flipToPage;


  @override
  _EvaluationBuilderState createState() => _EvaluationBuilderState();
}

class _EvaluationBuilderState extends State<EvaluationBuilder> {
  int currentQuestion = 0;
  int numQuestions = 5;

  //The list of question widgets in the evaluation
  List<QuestionWidget> theQuestions = new List<QuestionWidget>();
  List<QuestionWidget> allQuestions = new List<QuestionWidget>();

  //All widgets we will display, contains question widgets as well as other types of widgets
  List<Widget> theWidgets = new List<Widget>();
  //After the users submit their answers, we will show which are correct/incorrect
  bool hideAnswers = true;
  int correctAnswers = 0;
  double percent = 0;

  Widget submitButton;
  Widget homeButton;

  List<Widget> mark = new List<Widget>();

  List<int> evaluations = new List<int>();

  //The name of the module we are in
  String moduleID;

  bool started = false;

  VisualTimer myTimer;
  int timerDuration;
  BuildContext scaffoldContext;

  @override
  void initState() {
    initEvaluation();

    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: getBackgroundColor(),
        appBar: widget.doc == null
            ? AppBar(
                title: Text(
                  widget.title,
                  style: TextStyle(color: Colors.white),
                ),
              )
            : null,
        key: widget.scaffoldKey,
        body: Builder(builder: (context) {
          //Show a notification when the timer runs out
          if (started)
            myTimer.subscribe(() {
              showSnackbar(context,
                  'Time has run out. Your answers have been submitted.');
            });
          return started
              ? CustomScrollView(physics: BouncingScrollPhysics(), slivers: [
                  //Display a persistent timer at the top of the screen
                  SliverPersistentHeader(
                      pinned: true, delegate: SliverTimerHeader(myTimer)),
                  SliverList(
                      delegate: SliverChildListDelegate(
                          theWidgets + ((hideAnswers) ? [submitButton] : mark + [homeButton ])))
                ])
              : buildStartPage();
        }));
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
      
      hideAnswers = false;
    });

    for(int i = 0; i < theWidgets.length; i++)
    {
      if(theWidgets[i] is Visibility)
      {
        setState(() {
          Visibility visibilityWidget = theWidgets[i] as Visibility;

          theWidgets[i] = new Visibility(
            visible: !visibilityWidget.visible,
            child: visibilityWidget.child,
            );
        });
      }
    }

    mark.add(new Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
        child: Text(
          (percent * 100.0).round().toString() + '%',
          style: TextStyle(
              fontSize: 48 * getFontScale(),
              //Interpolate between green and red based on score
              color: Color.lerp(Colors.red, Colors.green, percent)),
        )));

    updateMark(
        section: moduleID, mark: (percent * 100.0).round().toString() + '%');
    //Display the link to further reading if one is provided
    if (widget.doc != null) {
      mark.add(
        Container(
          padding: EdgeInsets.only(bottom: 25),
          child: RichText(
            textAlign: TextAlign.center,
            text: new TextSpan(children: [
              TextSpan(
                text: 'Click ',
                style: TextStyle(
                  color: getFontColor(),
                  fontSize: getPrefFontSize(),
                ),
              ),
              TextSpan(
                  text: 'here',
                  style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontSize: getPrefFontSize()),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launch(widget.doc.data()['Link']);
                    }),
              TextSpan(
                text: ' for further reading.',
                style: TextStyle(
                  color: getFontColor(),
                  fontSize: getPrefFontSize(),
                ),
              ),
            ]),
          ),
        ),
      );
    }
    
    homeButton = new Container(
          padding: EdgeInsets.all(10),
          height: 100,
          width: 200,
          child: RaisedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/HomePage');
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            color: getAppColor(),
            child: Container(
              padding: EdgeInsets.all(8),
              child: Text(
                'Home',
                style: TextStyle(
                    fontSize: 28 * getFontScale(), color: Colors.white),
              ),
            )));
    
  }

  Future<bool> initializeTimer() async {
    Stream<DocumentSnapshot> evalDoc = (widget.doc == null)
        ? FirebaseFirestore.instance.doc('Question Bank/Questions').snapshots()
        : FirebaseFirestore.instance.doc(widget.doc.reference.path).snapshots();

    StreamIterator<DocumentSnapshot> iterator =
        StreamIterator<DocumentSnapshot>(evalDoc);

    //Create a timer with the information in the database if it's there, otherwise set the timer to unlimited
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

  //Initialize the timer, and subscribe to evaluate the questions when the timer runs out
  void createTimers({int durationMinutes}) {
    myTimer = VisualTimer(
        timerDuration: durationMinutes,
        eTimer: CallbackTimer(durationSeconds: durationMinutes * 60));

    myTimer.subscribe(() {
      evaluateQuestions();
    });
  }

  //We use this function if we are loading questions in a module quiz
  Future<void> loadQuestions() async {
    Stream<QuerySnapshot> snap = FirebaseFirestore.instance
        .collection(widget.doc.reference.collection('Questions').path)
        .snapshots();

    StreamIterator<QuerySnapshot> iterator =
        StreamIterator<QuerySnapshot>(snap);

    int counter = 0;
    while (await iterator.moveNext()) {
      List<QueryDocumentSnapshot> unshuffledQuestions = iterator.current.docs;
      unshuffledQuestions.shuffle();
      unshuffledQuestions.forEach((element) {
        counter++;
        //Create a question widget with the loaded question
        QuestionWidget tmp = QuestionWidget(
          doc: element,
          initialNum: counter,
          shouldShow: true,
        );

        Visibility sectionButton = Visibility(
          visible: !hideAnswers ? true : false,       
          child: Container(
            alignment: Alignment.center,
            child: ElevatedButton(
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(getAppColor()),),
            
            onPressed: () {
              widget.flipToPage((element.data()["AnswerPage"] as int) - widget.pageNum);
            },

            child: Container(
              child: Text("Found in " + element.data()["AnswerPageName"].toString(), 
            style: TextStyle(
              fontSize: 14 * getFontScale(),
              color: Colors.white,
            ),
            ), 
            ),),

          ));

        //Create a new list item set to false for the new question
        evaluations.add(0);

        //When an answer is chosen, evaluate whether it is correct, and set the evaluation list item to reflect that
        tmp.evaluationEvent.subscribe((args) {
          evaluations[tmp.initialNum - 1] = args.value;
        });

        theQuestions.add(tmp);
        theWidgets.add(tmp);

        if(element.data()["AnswerPage"] != null)
          theWidgets.add(sectionButton);
      });
    }
  }

  //We use this function if we are loading questions for the general evaluation
  Future<void> loadQuestionsGeneral() async {
    DocumentReference doc =
        FirebaseFirestore.instance.collection('Question Bank').doc('Questions');
    //Load the questions from each module, then choose some amount of them at random
    int counter = 0;
    doc.snapshots().forEach((element) {
      numQuestions = element.data()['Num Questions'];

      element.data().forEach((key, value) {
        if (value.runtimeType != int) {
          CollectionReference tmpCol =
              FirebaseFirestore.instance.collection(value);
          tmpCol.snapshots().forEach((quiz) {
            quiz.docs.forEach((e) {
              allQuestions.add(QuestionWidget(
                doc: e,
                initialNum: counter,
                shouldShow: false,
              ));
            });
          });
        }
      });
    });
  }

  Future<void> initEvaluation() async {
    //If we are in 'Evaluation' then two levels up is the module name
    //We'll use this to store user scores
    moduleID = (widget.doc == null)
        ? 'Overall'
        : widget.doc.reference.parent.parent.id;

    initializeTimer().whenComplete(() {
      if (widget.doc == null) {
        loadQuestionsGeneral();
      } else {
        loadQuestions();
      }

      submitButton = Container(
          padding: EdgeInsets.all(10),
          height: 100,
          width: 200,
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            color: getAppColor(),
            child: Container(
              padding: EdgeInsets.all(8),
              child: Text(
                'Submit',
                style: TextStyle(
                    fontSize: 28 * getFontScale(), color: Colors.white),
              ),
            ),

            //Evaluate each answer when we click submit
            onPressed: () {
              myTimer.cancel();

              //initialize the amount of correct answers             
              evaluateQuestions();   
            },
          ));
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
                    ///////////////////////Logo//////////////////////////
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
                    ///////////////////Title///////////////////////////
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 50, horizontal: 10),
                      alignment: Alignment.center,
                      child: Text(
                        moduleID + ' Evaluation',
                        style: TextStyle(
                          fontSize: 24 * getFontScale(),
                          fontWeight: FontWeight.bold,
                          color: getFontColor(),
                        ),
                      ),
                    ),
                    ///////////////////////Timer Text////////////////////////
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                      alignment: Alignment.center,
                      child: Text(
                        (timerDuration > 0)
                            ? 'Evaluation Time : ' +
                                buildTimerText(timerDuration) +
                                ((timerDuration == 1) ? ' minute.' : 'minutes.')
                            : 'Evaluation Time : Unlimited',
                        style: TextStyle(
                          fontSize: 24 * getFontScale(),
                          fontWeight: FontWeight.bold,
                          color: getFontColor(),
                        ),
                      ),
                    ),
                    ///////////////////////////////////Start Button/////////////////////////////////////////
                    Container(
                        padding: EdgeInsets.all(50),
                        height: 200,
                        width: 200,
                        child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            color: getAppColor(),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'Start',
                                style: TextStyle(
                                    fontSize: 28 * getFontScale(),
                                    color: Colors.white),
                              ),
                            ),
                            onPressed: () {
                              if (widget.doc == null) {
                                chooseQuestions();
                              }

                              setState(() {
                                started = true;
                              });
                            }))
                  ],
                ));
          }

          return LinearProgressIndicator();
        });
  }

  //Function that will choose the questions randomly for the general evaluation page
  void chooseQuestions() {
    Random rng = new Random();
    int idx = 0;

    //Loop for number of questions
    for (int i = 0; i < numQuestions; i++) {
      //Choose a random index in the range
      idx = rng.nextInt(allQuestions.length - 1);
      evaluations.add(0);

      //Get the question at the random index, and create a new widget from it
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
      //Remove the chosen question from the list of potential questions
      allQuestions.removeAt(idx);
    }

    theWidgets.addAll(theQuestions);
  }

  void initializeQuiz() {
    setState(() {
      started = true;
    });
  }
}
