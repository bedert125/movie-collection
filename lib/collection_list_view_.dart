import 'package:flutter/material.dart';

import 'collection_common_view.dart';
import 'collection_database.dart';
import 'conf/config.dart';
import 'conf/styles.dart';
import 'item_data.dart';


class CollectionListView extends CollectionView {
  //var rng = new Random();

  /* CollectionListView({toReset}){
    toReset = toReset ?? false;
    Config.NEEDS_UPDATE = toReset;
    print("restarting ${toReset}");
  }*/

  @override
  getState(){
    print("get state override LIST ");
    return _CollectionListViewState();
  }

}

// usar implemet ??? o extend
class _CollectionListViewState extends CollectionViewState{

  _CollectionListViewState(){
    print("restart stae   _CollectionListViewState");
  }

  @override
  Widget buildCollectionList() {

    return ListView.builder(
        shrinkWrap: true,
        // itemCount: _itemList.length,
        itemBuilder: (context, i) {
          if (itemList.length == i) {
            return null;
          } else {
            return _buildRow(itemList[i], i);
          }
        });
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
          goToItemViewById(item.id);
        },
        leading: Text((index + 1).toString()),
      ),
      Divider(
        height: 5.0,
      ),
    ]);
  }


}