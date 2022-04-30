import 'package:flutter/material.dart';

import 'collection_common_view.dart';
import 'collection_database.dart';
import 'conf/config.dart';
import 'conf/styles.dart';
import 'item_data.dart';


class CollectionListView extends StatefulWidget {
  final ItemData item;
  final int index;

  const CollectionListView({
    @required this.item,
    @required this.index
  });


  @override
  _CollectionListViewState createState() => _CollectionListViewState();
}

// usar implemet ??? o extend
class _CollectionListViewState extends State<CollectionListView>{

  _CollectionListViewState(){
    print("restart stae   _CollectionListViewState");
  }

  @override
  Widget build(BuildContext context) {
    return _buildRow(widget.item, widget.index);
  }

  Widget _buildRow(ItemData item, int index) {
    var iconSetup = item.getIcon();
    // print("row ${item.id} ${item.name} ");
    var name = item.name;
    if (name == null) {
      name = "-----";
    }

    return Column(children: <Widget>[
      ListTile(
        title: Text(
          name,
          style: Styles.itemText,
        ),
        /*trailing: IconButton(
        icon: iconSetup[0],
        color: iconSetup[1],
        onPressed: () {
          setState(item.onTapFav);
        },
      ),*/
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14.0,
        ),
        onTap: () {
          //goToItemViewById(item.id);
        },
        leading: Text((index + 1).toString()),
      ),
      Divider(
        height: 5.0,
      ),
    ]);
  }


}