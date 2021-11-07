import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'HelperFunctions.dart';

class ReferencesPage extends StatelessWidget
{
  ReferencesPage({this.title = 'Contributors', this.doc});

  final String title;
  final QueryDocumentSnapshot doc;

  @override
  Widget build(BuildContext context) {
  return ListView(
    physics: BouncingScrollPhysics(), 
    children: <Widget>[
      Container(
        padding: EdgeInsets.all(8),
        height: 200,
        child: buildImage('GynOnc_Logo.png'))
        ]
        + createAuthorText() 
  );    
  }

  List<Widget> createAuthorText()
  {
    print('Creating contributors');
    List<Widget> authorText = [];

    authorText.add(new Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8),
        child: Text("Authors & Editors", style: TextStyle(
          fontSize: getPrefFontSize() * 1.5,
          color: getFontColor(),
          ),
        ),
      ),
    );

    for(int i = 0; i < doc.data()['Authors'].length; i++)
    {
      authorText.add(new Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8),
        child: Text(
          doc.data()['Authors'][i], style: TextStyle(
          fontSize: getPrefFontSize(),
          color: getFontColor(),
          ),
        ),
        ),
      );
    }

    authorText.add(new Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8),
        child: Text("References", style: TextStyle(
          fontSize: getPrefFontSize() * 1.5,
          color: getFontColor(),
          ),
        ),
      ),
    );

    for(int i = 0; i < doc.data()['References'].length; i++)
    {
      authorText.add(new Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8),
        child: Text(
          doc.data()['References'][i], style: TextStyle(
          fontSize: getPrefFontSize(),
          color: getFontColor(),
          ),
        ),
        ),
      );
    }
    
    
    /*
    authors.forEach((element) {
      authorText.add(new Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8),
        child: Text(element, style: TextStyle(
          fontSize: getPrefFontSize(),
          color: getFontColor(),
          ),
        ),
      ),
      );
     });
     */

     return authorText;
  }
/*
  List<Widget> createButtons()
  {
    List<Widget> buttons = [];

    //buttons.add();

    createAuthorText();

    for(int i = 0; i < pageTitles.length; i++)
    {
      buttons.add(new Container(
        padding: EdgeInsets.symmetric(vertical: (5), horizontal: (20)),
        alignment: Alignment.centerLeft,
        child: TextButton(
          
        child: Text(
          (i + 1).toString() + ". " + pageTitles[i],
          textAlign: TextAlign.left,
          style: TextStyle(
            
            fontSize: getPrefFontSize(),
            color: Colors.blue,
            ),
          ),
          
        onPressed: () => function(i),
        )));
    }

    return buttons;
  }
  */
}