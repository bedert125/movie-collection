import 'package:flutter/material.dart';
import 'config_view.dart';
import 'item_data.dart';

import 'item_view.dart';

class GoTo {
  static ItemDataView(BuildContext context, ItemData item) async {
    return await Navigator.push(
        context,
       /* PageRouteBuilder(
          transitionDuration: Duration(seconds: 2),
          pageBuilder: (_, __, ___) =>  ItemView(item),
        )*/
        MaterialPageRoute(builder: (context) => ItemView(item))
    );
  }


  static SettingsView(BuildContext context) async {
    return await Navigator.push(
        context,
        /* PageRouteBuilder(
          transitionDuration: Duration(seconds: 2),
          pageBuilder: (_, __, ___) =>  ItemView(item),
        )*/
        MaterialPageRoute(builder: (context) => ConfigView())
    );
  }
}