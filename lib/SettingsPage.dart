import 'package:flutter/material.dart';
import 'package:uoft_gynonc_app/HelperFunctions.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _currentSliderValue = getFontScale();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: getBackgroundColor(),
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
                    style: TextStyle(
                      fontSize: getPrefFontSize(),
                      color: getFontColor(),
                    ),
                  )),

              Container(
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.symmetric(vertical: 25),
                  child: Slider(
                    value: _currentSliderValue,
                    min: 1,
                    max: 2,
                    divisions: 10,
                    label: _currentSliderValue.toString(),
                    onChanged: (double val) {
                      setFontScale(val);

                      setState(() {
                        _currentSliderValue = val;
                      });
                    },
                  )),

              Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.symmetric(vertical: 25),
                child: RaisedButton(
                  color: getAppColor(),
                  onPressed: () {
                    setState(() {
                      prefs.toggleNightMode();
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      'Toggle Night Mode',
                      style: getButtonTextStyle(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
