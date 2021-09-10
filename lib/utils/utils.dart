import 'package:flutter/material.dart';

class Utils {
  static RegExp _yearExp = new RegExp(r"\d{4}");
  static int toYear(dynamic value){
    Iterable<Match> matches = _yearExp.allMatches('$value');
    // print("--->>${json["Year"]}<<<-");
    var year;
    if (matches != null && matches.length != 0) {
      year = int.parse(matches.elementAt(0).group(0));
    }
    return year;
  }

}

