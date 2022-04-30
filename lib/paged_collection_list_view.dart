import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:movie_collection/paged_view.dart';


import 'collection_card_view.dart';
import 'collection_database.dart';
import 'collection_list_view.dart';
import 'conf/list_preferences.dart';

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

  @override
  Widget createItem(item, int index){
    return CollectionListView(
      item: item,
      index: index,
    );
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