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
    children: createButtons(),
  );    
  }

  List<TextButton> createButtons()
  {
    List<TextButton> buttons = new List<TextButton>();

    for(int i = 0; i < pageTitles.length; i++)
    {
      buttons.add(new TextButton(
        child: Text(
          i.toString() + ". " + pageTitles[i],
          style: TextStyle(
            fontSize: getPrefFontSize(),
            color: Colors.blue,
            ),
          ),
        onPressed: function(i),
        ));
    }

    return buttons;
  }
}