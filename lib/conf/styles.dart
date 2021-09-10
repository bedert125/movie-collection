import 'package:flutter/material.dart';

class Styles {
  static const primarySwatch = Colors.indigo;
  static const double paddingValue = 10;
  static const padding = EdgeInsets.all(paddingValue);
  static const rowPadding =
      EdgeInsets.fromLTRB(paddingValue, 5, paddingValue, 5);
  static const itemText = TextStyle(fontSize: 16.0);

  static const boxShadow =
      BoxShadow(color: Colors.black, offset: Offset(0, 2), blurRadius: 10);

  static const double imageDialogRadiusValue = 100;

  static const TextStyle hiperlink = TextStyle(decoration: TextDecoration.underline,fontStyle: FontStyle.italic);
}
