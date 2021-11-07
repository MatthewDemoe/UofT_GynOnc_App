import 'package:flutter/material.dart';
import 'HelperFunctions.dart';

class TableOfContentsPage extends StatelessWidget
{
  TableOfContentsPage({this.pageTitles, this.function});

  final List<String> pageTitles;
  final Function(int) function;

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
        + createButtons(),
  );    
  }

  List<Widget> createButtons()
  {
    List<Widget> buttons = [];

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
}