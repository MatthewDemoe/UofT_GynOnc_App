import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  Preferences() {
    //init();
  }

  SharedPreferences prefs;

  String bullet = '•';

  Color _appColor = Colors.cyan[700];
  double _defaultFontSize = 14.0;
  double _fontScale = 1;

  bool _nightMode = false;

  Future<bool> init() async {
    prefs = await SharedPreferences.getInstance();

    if (prefs.getDouble('fontScale') != null)
      _fontScale = prefs.getDouble('fontScale');

    if (prefs.getBool('nightMode') != null)
      _nightMode = prefs.getBool('nightMode');

    return true;
  }

  void toggleNightMode() {
    _nightMode = !_nightMode;

    prefs.setBool('nightMode', _nightMode);
  }

  bool getNightMode() {
    return _nightMode;
  }

  Color getBackgroundColor() {
    if (_nightMode)
      return Colors.grey[900];
    else
      return Colors.grey[300];
  }

  Color getFontColor() {
    if (_nightMode)
      return Colors.grey[300];
    else
      return Colors.grey[900];
  }

  Color getAppColor() {
    return _appColor;
  }

  double getFontScale() {
    return _fontScale;
  }

  double getPrefFontSize() {
    return (_defaultFontSize * _fontScale);
  }

  void setFontScale(double newScale) {
    _fontScale = newScale;
    prefs.setDouble('fontScale', newScale);
  }
}
