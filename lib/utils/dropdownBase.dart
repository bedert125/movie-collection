import 'package:flutter/material.dart';

class DropdownMenu {

  List<DropdownMenuItem<DropdownItem>> build(List listItems) {
    List<DropdownMenuItem<DropdownItem>> items = List();
    for (DropdownItem listItem in listItems) {
      items.add(
        DropdownMenuItem(
          child: Text(listItem.name),
          value: listItem,
        ),
      );
    }
    return items;
  }

  List<DropdownMenuItem<int>> buildByMap(Map itemsMap) {
    List<DropdownMenuItem<int>> items = List();
    itemsMap.forEach((key, value){
      print("$key   $value  ");
      items.add(
        DropdownMenuItem(
          child: Text(value),
          value: key,
        ),
      );
    });

    return items;
  }
}

class DropdownItem {
  int value;
  String name;
  String type;

  DropdownItem(this.value, this.name, this.type);
}
