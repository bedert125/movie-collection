import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:movie_collection/paged_view.dart';


import 'collection_card_view.dart';
import 'collection_database.dart';
import 'conf/list_preferences.dart';

class PagedCollectionCardView extends PagedView{
  const PagedCollectionCardView(ConnectionDB repository,ListPreferences listPreferences)
      :super(
        repository: repository,
        listPreferences: listPreferences
      );

  @override
  PagedViewState createState() => _PagedCollectionCardViewState();


}

class _PagedCollectionCardViewState extends PagedViewState{

  @override
  Widget createItem(item, int index){
    return CollectionCardView(
      item: item,
      index: index,
    );
  }

  @override
  Widget getMainElement(){
    return PagedGridView<int, Widget>(
      // 4
      pagingController: pagingController,
      padding: const EdgeInsets.all(16),
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
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 2 / 3,
        //crossAxisSpacing: 10,
        //mainAxisSpacing: 10,
        crossAxisCount: 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return getWrapperPanel();
  }

}