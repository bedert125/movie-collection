import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';


import 'collection_card_view.dart';
import 'collection_database.dart';
import 'collection_list_view.dart';
import 'conf/config.dart';
import 'conf/list_preferences.dart';
import 'item_data.dart';


// 1
class PagedView extends StatefulWidget {
  const PagedView({
    @required this.repository,
    this.listPreferences,
  });


  final ConnectionDB repository;
  final ListPreferences listPreferences;


  @override
  PagedViewState createState() => PagedViewState();
}

class PagedViewState extends State<PagedView>{
  final pagingController = PagingController<int, Widget>(
    firstPageKey: 0,
  );

  Widget createItem(ItemData item, int index){

  }

  @override
  void initState() {
    pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    super.initState();
  }

  int counter = 0;

  Widget getMainElement(){}

  Widget buildRow(context, article, index) {

    return article;
  }

  int refreshTime =0;

  Future<void> _fetchPage(int pageKey) async {
    try {
     final newPage = await widget.repository.item.getPage(
        pageKey,
        8,
      );

      print(pageKey);

      final previouslyFetchedItemsCount = pagingController.itemList?.length ?? 0;

      final isLastPage = newPage.length==0 ;
      List<Widget> itemList= [];

      for(var i=0;i<newPage.length;i++){
        itemList.add(createItem(newPage[i],(pageKey*8) + i,));

      }
      if (isLastPage) {
        pagingController.appendLastPage(itemList);
      } else {
        final nextPageKey = pageKey + 1;
        pagingController.appendPage(itemList, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }


  @override
  void didUpdateWidget(PagedView oldWidget) {

    if (oldWidget.listPreferences != widget.listPreferences) {
      pagingController.refresh();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // 4
    pagingController.dispose();
    super.dispose();
  }

  Widget getWrapperPanel(){
    return RefreshIndicator(
        onRefresh: () => Future.sync(
              () => pagingController.refresh(),
        ),
        child: getMainElement()
    );
  }

  @override
  Widget build(BuildContext context) =>
  RefreshIndicator(
    onRefresh: () => Future.sync(
          () => pagingController.refresh(),
    ),
    child: getMainElement()
  );
}