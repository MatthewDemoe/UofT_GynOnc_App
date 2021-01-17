import 'package:flutter/material.dart';
import 'package:uoft_gynonc_app/HelperFunctions.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _currentSliderValue = getDefaultFontSize();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Settings')),
        body: Container(
          alignment: Alignment.center,
          child: ListView(
            shrinkWrap: true,
            children: [
              /////////////////////LOGO////////////////////////////
              Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.symmetric(vertical: 25),
                height: 150,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.fitHeight,
                        image: AssetImage('assets/GynOnc_Logo.png'))),
              ),

              Container(
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.only(top: 50, bottom: 25),
                  child: Text(
                    'Font Size: ' + _currentSliderValue.toString(),
                    style: TextStyle(fontSize: getDefaultFontSize()),
                  )),

              Container(
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.symmetric(vertical: 25),
                  child: Slider(
                    value: _currentSliderValue,
                    min: 14,
                    max: 36,
                    divisions: 11,
                    label: _currentSliderValue.toString(),
                    onChanged: (double val) {
                      setDefaultFontSize(val);

                      setState(() {
                        _currentSliderValue = val;
                      });
                    },
                  )),
            ],
          ),
        ));
  }
}
