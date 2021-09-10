import 'package:flutter/material.dart';
import 'item_data.dart';

class FormatView extends StatefulWidget {
  ItemData _item;

  FormatView(ItemData item) {
    //print(item);
    _item = item;
  }

  @override
  _FormatViewState createState() => _FormatViewState();
}

class _FormatViewState extends State<FormatView> {
  _getFormatRow() {
    final tiles = <CheckboxListTile>[];

    widget._item.formats.values.forEach((key, val) {
      tiles.add(CheckboxListTile(
        title: Text(key),
        value: widget._item.formats.values[key] != FormatStatus.unselected,
        onChanged: (bool value) {
          setState(() {
            value
                ? (widget._item.formats.values[key] = FormatStatus.newSelection)
                : (widget._item.formats.values[key] = FormatStatus.unselected);

          });
        },
        secondary: Image.asset(
          "images/" + key + ".png",
          width: 50,
          height: 50,
          fit: BoxFit.contain,
        ),
      ));

      /* ListTile(
          title: Text(
            val,
            style: Styles.itemText,
          ),
          trailing: Image.asset("images/"+val+".png"),
          onTap: () {}));*/
    });

    return ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();
  }

  Widget buildFormatValues() {
    return ListView(children: _getFormatRow());
  }

  @override
  Widget build(BuildContext context) {
    var iconSetup = widget._item.getIcon();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._item.name),
      ),
      body: buildFormatValues(),
    );
  }
}
