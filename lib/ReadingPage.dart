import 'package:cloud_firestore/cloud_firestore.dart';
import 'HelperFunctions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

String bullet = '• ';
List<String> bullets = ['• ', '◦ ', '‣ ', '∙ ', '- '];

class ReadingPage extends StatefulWidget {
  ReadingPage({Key key, this.title = 'Reading', this.doc}) : super(key: key);

  final String title;
  final QueryDocumentSnapshot doc;

  @override
  _ReadingPageState createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  bool isInitialized = false;

  List<Widget> pageComponents = new List<Widget>();

  @override
  void initState() {
    if (!isInitialized) {
      initComponents();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        addAutomaticKeepAlives: true,
        physics: BouncingScrollPhysics(),
        children: isInitialized
            ? pageComponents
            : [
                Container(
                  padding: EdgeInsets.all(10),
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(),
                )
              ]);
  }

  void initComponents() {
    Stream<QuerySnapshot> col =
        widget.doc.reference.collection('Content').snapshots();

    pageComponents.add(Container(
      padding: EdgeInsets.symmetric(vertical: 25),
    ));

    col.listen((event) {
      event.docs.forEach((element) {

        if (element.id.contains('Image')) {
          pageComponents.add(buildZoomableImage(element.data()['Image']));
        }

        if (element.id.contains('Text') && !element.id.contains('Rich')) {
          //Create a header for a section
          if (element.data().containsKey('Header')) {
            pageComponents.add(Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7.5),
                child: Text(
                  element.data()['Text'].toString(),
                  style: TextStyle(
                    fontSize: getPrefFontSize() * 2,
                    color: getFontColor(),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                )));
          }

          //Mini Header
          else if (element.data().containsKey('Bold')) {
            pageComponents.add(Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7.5),
                child: Text(
                  element.data()['Text'].toString(),
                  style: TextStyle(
                    fontSize: getPrefFontSize(),
                    color: getFontColor(),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                )));
          }
          //Create a list of bullet points
          else if (element.data().containsKey('Bullets')) {
            //Create a piece of text for each bullet
            List<String> bulletList = new List<String>();

            element.data()['Bullets'].forEach((textKey, bulletMap) {
              bulletList.add(textKey);

              bulletList.sort((a, b) {
                int intA = int.parse(a.split(' ')[0]);
                int intB = int.parse(b.split(' ')[0]);

                return intA.compareTo(intB);
              });
            });
            for (int i = 0; i < bulletList.length; i++) {
              element.data()['Bullets'][bulletList[i]].forEach((key, indent) {
                int goodIndent = 0;
                if (indent.runtimeType == ''.runtimeType)
                  goodIndent = int.parse(indent);
                else
                  goodIndent = indent;
                pageComponents.add(Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(
                        left: 15 + (30.0 * (goodIndent).toDouble()),
                        top: 7,
                        bottom: 7,
                        right: 15),
                    child: Text(
                      bullets[goodIndent] + key,
                      style: TextStyle(
                        fontSize: getPrefFontSize(),
                        color: getFontColor(),
                      ),
                      textAlign: TextAlign.left,
                    )));
              });
            }
          } else {
            pageComponents.add(Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7.5),
                child: Text(
                  element.data()['Text'].toString(),
                  style: TextStyle(
                    fontSize: getPrefFontSize(),
                    color: getFontColor(),
                  ),
                  textAlign: TextAlign.left,
                )));
          }
        }

        //Rich text for hyperlinks 
        if (element.id.contains('Rich')) {
          pageComponents.add(StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(element.reference.collection('TextSpans').path)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData)
                return new Container(
                  alignment: Alignment.center,
                  height: 110.0,
                  width: 110.0,
                  //While we wait for data...
                  child: CircularProgressIndicator(),
                );
              return buildRichText(context, snapshot);
            },
          ));
        }
      });
      setState(() {
        isInitialized = true;
        pageComponents.add(Container(
          padding: EdgeInsets.symmetric(vertical: 25),
        ));
      });
    });
  }

  Widget buildTable(QueryDocumentSnapshot doc) {
    List<String> rowList = new List<String>();

    doc.data()['Table'].forEach((textKey, bulletMap) {
      rowList.add(textKey);

      rowList.sort((a, b) {
        int intA = int.parse(a.split(' ')[0]);
        int intB = int.parse(b.split(' ')[0]);

        return intA.compareTo(intB);
      });
    });

    for (int i = 0; i < rowList.length; i++) {
      doc.data()['Table'][rowList[i]].forEach((key, cell) {
        cell.forEach((cellKey, indent) {
          int goodIndent = 0;
          if (indent.runtimeType == ''.runtimeType)
            goodIndent = int.parse(indent);
          else
            goodIndent = indent;
          pageComponents.add(Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(
                  left: 15 + (30.0 * (goodIndent).toDouble()),
                  top: 7,
                  bottom: 7,
                  right: 15),
              child: Text(
                bullets[goodIndent] + key,
                style: TextStyle(
                  fontSize: getPrefFontSize(),
                  color: getFontColor(),
                ),
                textAlign: TextAlign.left,
              )));
        });
      });
    }
  }

  List<TableRow> buildTableRows(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    List<TableRow> rows = new List<TableRow>();

    return snapshot.data.docs.map((doc) {
      List<Widget> rowChildren = new List<Widget>();

      return TableRow(children: [
        StreamBuilder(
          stream: doc.reference.collection('Content').snapshots(),
          builder: (cont, snap) {
            if (snap.hasData) {

              return Container(
                  child: Column(children: buildTableCell(cont, snap)));
            } else
              return new Container(
                alignment: Alignment.center,
                height: 110.0,
                width: 110.0,
                //While we wait for data...
                child: CircularProgressIndicator(),
              );
          },
        )
      ]);

        }).toList();

  }

  List<Widget> buildTableCell(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    List<Widget> cells = new List<Widget>();
    return snapshot.data.docs.map((doc) {
      if (doc.data().containsKey('Bullets')) {
        //Create a piece of text for each bullet
        List<String> bulletList = new List<String>();

        doc.data()['Bullets'].forEach((textKey, bulletMap) {
          bulletList.add(textKey);

          bulletList.sort((a, b) {
            int intA = int.parse(a.split(' ')[0]);
            int intB = int.parse(b.split(' ')[0]);

            return intA.compareTo(intB);
          });
        });

        for (int i = 0; i < bulletList.length; i++) {
          doc.data()['Bullets'][bulletList[i]].forEach((key, indent) {
            int goodIndent = 0;
            if (indent.runtimeType == ''.runtimeType)
              goodIndent = int.parse(indent);
            else
              goodIndent = indent;
            cells.add(Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(
                    left: 15 + (30.0 * (goodIndent).toDouble()),
                    top: 7,
                    bottom: 7,
                    right: 15),
                child: Text(
                  bullets[goodIndent] + key,
                  style: TextStyle(
                    fontSize: getPrefFontSize(),
                    color: getFontColor(),
                  ),
                  textAlign: TextAlign.left,
                )));
          });

          return Row(
            children: cells,
          );
        }
      } else {
        return (Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7.5),
            child: Text(
              doc.data()['Text'].toString(),
              style: TextStyle(
                fontSize: getPrefFontSize(),
                color: getFontColor(),
              ),
              textAlign: TextAlign.left,
            )));
      }
    }).toList();
  }

  Widget buildRichText(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      alignment: Alignment.center,
      child: RichText(
          textAlign: TextAlign.left,
          text: new TextSpan(
              children: snapshot.data.docs.map((doc) {
            if (doc.data().containsKey('Link'))
              return TextSpan(
                  text: doc.data()['Text'],
                  style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontSize: getPrefFontSize()),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launch(doc.data()['Link']);
                    });

            return TextSpan(
                text: doc.data()['Text'],
                style: TextStyle(
                    color: getFontColor(), fontSize: getPrefFontSize()));
          }).toList())),
    );
  }
}
