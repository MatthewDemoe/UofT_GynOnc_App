import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'QuestionWidget.dart';

class GeneralEvaluationPage extends StatefulWidget {
  GeneralEvaluationPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _GeneralEvaluationPageState createState() =>
      new _GeneralEvaluationPageState();

  //Return the list of questions that is stored in the state of this widget
}

class _GeneralEvaluationPageState extends State<GeneralEvaluationPage> {
  int currentQuestion = 0;
  //The list of question widgets in the evaluation
  List<QuestionWidget> theQuestions = new List<QuestionWidget>();
  //All widgets we will display, contains question widgets as well as other types of widgets
  List<Widget> theWidgets = new List<Widget>();
  //After the users submit their answers, we will show which are correct/incorrect
  bool hideAnswers = true;
  int correctAnswers = 0;

  DocumentReference doc;

  List<int> evaluations = new List<int>();

  @override
  void initState() {
    super.initState();

    doc =
        FirebaseFirestore.instance.collection('Question Bank').doc('Questions');

    //print(doc.id);

    /*doc.snapshots().forEach((element) {
      element.data().forEach((key, value) {
        //print(value);
        CollectionReference tmpCol =
            FirebaseFirestore.instance.collection(value);

        tmpCol.snapshots().forEach((element) {
          //print('SOME ELEMENT');
          element.docs.forEach((e) {
            //print(e.id);
            theQuestions.add(QuestionWidget(
              doc: e,
              questionNum: 1,
              shouldShow: false,
            ));
          });
          /*element.docs.map((e) {
            print('SOME DOCUMENT');
            theQuestions.add(new QuestionWidget(
              doc: e,
              questionNum: 1,
              shouldShow: false,
            ));
          });*/
        });
      });
    }).whenComplete(() => setState(() {}));*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //Get the list of questions from firebase
        body: StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Question Bank')
          .doc('Questions')
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 110.0,
            //While we wait...
            child: CircularProgressIndicator(),
          );
        }

        theQuestions = formQuestions(snapshot);

        /*snapshot.data.docs.map((evalReferences) {
          evalReferences.data().map((key, eval) {
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection(eval).snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                theQuestions.addAll(formQuestions(snapshot));
              },
            );
          });
        });*/

        //theQuestions = formQuestions(snapshot);

        if (theWidgets.isEmpty) {
          theWidgets.addAll(theQuestions);

          print('NUMBER OF QUESTIONS : ' + theQuestions.length.toString());

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

        return CustomScrollView(physics: BouncingScrollPhysics(), slivers: [
          SliverList(
              delegate: SliverChildListDelegate(
            theWidgets,
          ))
        ]);
      },
    ));
  }

  List<QuestionWidget> formQuestions(AsyncSnapshot<DocumentSnapshot> snapshot) {
    //Initialize a question counter,
    //this is just used to add a number at the beginning of the question's text
    int counter = 0;
    List<QuestionWidget> tmpQuestions = new List<QuestionWidget>();

    snapshot.data.data().forEach((key, value) {
      CollectionReference tmpCol = FirebaseFirestore.instance.collection(value);

      tmpCol.snapshots().forEach((element) {
        //print('SOME ELEMENT');
        element.docs.forEach((e) {
          //print(e.id);
          counter++;

          tmpQuestions.add(QuestionWidget(
            doc: e,
            questionNum: counter,
            shouldShow: false,
          ));
        });
      });
    });

    return tmpQuestions;
    /*snapshot.data.docs.map((question) {
      counter = counter + 1;

      QuestionWidget tmp = QuestionWidget(
        doc: question,
        questionNum: counter,
        shouldShow: false,
      );

      evaluations.add(0);

      tmp.evaluationEvent.subscribe((args) {
        evaluations[tmp.questionNum - 1] = args.value;
      });

      return tmp;
    }).toList();*/

    /* snapshot.data.data().forEach((key, value) {
      CollectionReference tmpCol = FirebaseFirestore.instance.collection(value);

      tmpCol.snapshots().forEach((element) {
        //print('SOME ELEMENT');
        element.docs.forEach((e) {
          //print(e.id);
          theQuestions.add(QuestionWidget(
            doc: e,
            questionNum: 1,
            shouldShow: false,
          ));
        });
      });
    });*/
  }
}
