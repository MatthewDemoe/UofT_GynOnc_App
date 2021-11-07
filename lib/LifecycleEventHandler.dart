
import 'package:flutter/cupertino.dart';

typedef FutureVoidCallback = Future<void> Function();

class LifecycleEventHandler extends WidgetsBindingObserver{
  LifecycleEventHandler({this.resumeCallBack, this.detachedCallBack});

  final FutureVoidCallback resumeCallBack;
  final FutureVoidCallback detachedCallBack;

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async{
    switch(state){
      case AppLifecycleState.inactive:
        break;  
      case AppLifecycleState.paused:
        await detachedCallBack();
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.resumed:
        await resumeCallBack();
        break;
    }
    print('''
    =============================================================
               $state
    =============================================================
    ''');
  }

}