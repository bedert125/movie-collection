import 'package:flutter/material.dart';

import 'conf/list_preferences.dart';
import 'dialog_box.dart';
import 'conf/strings.dart';

class Popup {
  static Future error(
      BuildContext context, String title, String message) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogBox(
            title: title,
            descriptions: message,
            text: Strings.ok,
            img: "images/error.png",
          );
        });
  }

  static Future info(BuildContext context, String title, String message) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogBox(
            title: title,
            descriptions: message,
            text: Strings.ok,
            img: "images/info.png",
          );
        });
  }

  static Future confirmation(BuildContext context, String title, String message) async{

    var actions = _getOkCancelBtn(context, () {

      Navigator.of(context).pop(
          ListPreferences(
              sortBy: " > $title"
          )
      );
    });

    return await showDialog(
        context: context,
        builder: (BuildContext context) {
      return DialogBox(
        title: title,
        descriptions: message,
        text: Strings.ok,
        img: "images/question.png",
        actions: actions
      );
    });
  }

  static _getOkCancelBtn(context,onOk) {
    var actionList = [
      FlatButton(
        child: Text(Strings.cancel),
        onPressed: () {
          Navigator.of(context).pop(null);
        },
      ),
      FlatButton(
        child: Text(Strings.ok),
        //color: Theme.of(context).accentColor,
        onPressed: onOk
      ),
    ];

    return Container(
        width: double.infinity,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:actionList
        )
    );
  }

  static Future inputDialog(BuildContext context,
      {String name, String description, String label,String example}) async {
    String stringName = name == null ? "" : name;
    description = description == null ? "" : description;
    label = label ?? Strings.nameToSearchInput;
    example = example ?? Strings.nameToSearchExample;

    var actions = _getOkCancelBtn(context, () {
      Navigator.of(context).pop(stringName);
    });

    var extraElements = <Widget>[
      Row(
      children:[Expanded(
          child: new TextFormField(
        initialValue: stringName,
        autofocus: true,
        decoration: new InputDecoration(
            labelText: label,
            hintText: example),
        onChanged: (value) {
          stringName = value;
        },
      ))]
      )
    ];

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogBox(
            title: Strings.nameToSearchTitle,
            descriptions: description,
            text: Strings.ok,
            img: "",
            actions: actions,
            extraElements: extraElements,
          );
        });

    /*
    return showDialog(
      context: context,
      barrierDismissible: false,
      // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Strings.nameToSearchTitle),
          content: Column(
            children: [
              Text(description),
              new
            ],
          ),
          actions:,
        );
      },
    );*/
  }
}
