import 'package:flutter/material.dart';
import 'package:movie_collection/conf/styles.dart';
import 'package:movie_collection/utils/ClipShadowPath.dart';
import 'package:movie_collection/utils/ribbon_shape.dart';

class VisualElements {
  static Widget getYearLabel(int _year, BuildContext context) {
    Widget yearLabel;
    if (_year != null) {
      yearLabel = Align(
        alignment: Alignment.topLeft,
        child: Container(
          //margin: EdgeInsets.only(bottom: 10.0),
          child: ClipShadowPath(
            clipper: RibbonClipper(),
            shadow: Shadow(blurRadius: 3),
            child: Container(
                color: Theme.of(context).primaryColor,
                //width: 200.0,
                //height: 50.0,
                padding: Styles.rowPadding.copyWith(right: 25),
                //color: Colors.red,
                child: Text(
                  '$_year',
                  style: Theme.of(context).primaryTextTheme.bodyText1,
                  softWrap: true,
                )),
          ),
        ),
      );
    }

    return yearLabel;
  }
}
