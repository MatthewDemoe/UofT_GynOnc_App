import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  LoadingScreen({Key key}) : super(key: key);
  
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[Text('Loading')],
          ),
        ),
      ),
    );
  }
}
