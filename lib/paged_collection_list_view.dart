import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:movie_collection/paged_view.dart';

import 'collection_database.dart';
import 'conf/list_preferences.dart';
import 'conf/styles.dart';
import 'item_data.dart';

class PagedCollectionListView extends PagedView{
  const PagedCollectionListView(ConnectionDB repository,ListPreferences listPreferences)
      :super(
        repository: repository,
        listPreferences: listPreferences
      );

  @override
  PagedViewState createState() => _PagedCollectionListViewState();

}

class _PagedCollectionListViewState extends PagedViewState{

  Widget _buildItem(ItemData item, int index) {
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

  @override
  Widget createItem(item, int index){
    return _buildItem(item,index );
  }

  @override
  Widget getMainElement(){
    return PagedListView<int, Widget>(
      // 4
        pagingController: pagingController,
        // padding: const EdgeInsets.all(16),
        //separatorBuilder: (context, index) => const SizedBox(
        //  height: 16,
        // ),
        builderDelegate: PagedChildBuilderDelegate<Widget>(
          itemBuilder: (context, article, index) => buildRow(context, article, index),
          /*firstPageErrorIndicatorBuilder: (context) => ErrorIndicator(
          error: _pagingController.error,
          onTryAgain: () => _pagingController.refresh(),
        ),*/
          //noItemsFoundIndicatorBuilder: (context) => EmptyListIndicator(),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return getWrapperPanel();
  }

}