import 'package:flutter/material.dart';

class EvaluationBottomSheet extends StatefulWidget {
  @override
  _EvaluationBottomSheetState createState() => _EvaluationBottomSheetState();
}

class _EvaluationBottomSheetState extends State<EvaluationBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(15),
      height: 160,
      decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.all(Radius.circular(15))),
      child: Column(
          //mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Container(child: Icon(Icons.ac_unit))]),
    );
  }
}
