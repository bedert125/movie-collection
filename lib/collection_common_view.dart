import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movie_collection/conf/config.dart';
import 'package:movie_collection/paged_view.dart';

import 'collection_database.dart';
import 'conf/list_preferences.dart';
import 'goto.dart';
import 'item_data.dart';
import 'loading_overlay.dart';

class CollectionView extends StatefulWidget {

  // bool toReset = false;
/*  getState(){
    print("get state base ");
    return CollectionViewState();
  }]*/

  const CollectionView({
    this.item
  });

  final ItemData item;

  @override
  CollectionViewState createState() => CollectionViewState(); //_CollectionViewState();
}


// https://stackoverflow.com/questions/54494024/how-to-make-stacked-card-list-view-in-flutter
// https://sergiandreplace.com/planets-flutter-creating-a-planet-card/

class CollectionViewState extends State<CollectionView> {

  //bool toReset = false;
  ListPreferences _listPreferences;
  int conuntReset =0;

  final List<ItemData> itemList = [];
  ConnectionDB _db;

  shouldBeUpdated(){
    var update = Config.NEEDS_UPDATE;
    //Config.NEEDS_UPDATE = false;
    return update;
  }

  _asyncView() {
    var _toReset = shouldBeUpdated();
    if (_toReset) {
      conuntReset++;
      setState(() {
        _listPreferences = ListPreferences(
            sortBy: ">> $conuntReset"
        );
      });
    }

    return PagedView(

      listPreferences: _listPreferences,
    );
/*
    var _toReset = shouldBeUpdated();
    print("_asyncView -------- common ${_toReset}");
    var waitDone = false;
    if (_toReset == true) {
      waitDone = true;
      print("reset list");
      itemList.clear();
      //_toReset= false;
      Config.NEEDS_UPDATE = false;
    }

    return FutureBuilder(
      future: _getDataList(_toReset),
      // if you mean this method well return image url
      builder: (BuildContext context, AsyncSnapshot<List<ItemData>> snapshot) {
        if (!snapshot.hasData ||
            (waitDone && snapshot.connectionState != ConnectionState.done)) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return buildCollectionList();
        }
      },
    );

    */
  }

  Future<List<ItemData>> _getDataList(bool getDataFromBD) async {
    Future<List<ItemData>> itemFuture;
    if(getDataFromBD){
      await Future.delayed(Duration(milliseconds: 500));
      await _db.start();
      //print("_itemList.length ${_itemList.length}");
      itemFuture = _db.item.getAllAsList();
      //var name = await Popup.InputDialog(context, name:"holaaa   aaaaa", description: " sadfsdg sdfs dfsg sd sjdhf jsdf sjdhf sdjfhsjd fjscndsc sjdnc h");
      itemFuture.then((newItemList) {
        setState(() {
          // print(newItemList);
          // print(itemList);
          if (newItemList.length != 0) {
            itemList.addAll(newItemList);
            print("added");
          }
        });
      });
    }else{
      print("avoiding db request");
      itemFuture = Future(()async {return [];});
    }
    return itemFuture;
  }



  /* Future<List<ItemData>> _getItems(int num) async {
    var listDB = await _db.item.get(_currentItem, -1);
    _currentItem = _currentItem + num;
    return listDB;
  }
   */

  goToItemViewById(int id) async {
    final overlay = LoadingOverlay.of(context);
    overlay.show();
    ItemData item = await _db.item.getById(id);
    overlay.hide();
    var reason = await GoTo.ItemDataView(context, item);
    print("return home view $reason");

    /* if(reason == "delete"){
      setReset(true);
    }

     */
  }



  Widget buildCollectionList(){

  }

  @override
  void initState() {
    print(">> initState list");
    super.initState();
    _db = ConnectionDB();
    _db.start();

    super.initState();
    print(">> initState list end");
  }


  @override
  Widget build(BuildContext context) {
    print(">>> build list");
    _db = ConnectionDB();

    /*_controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );*/

    return _asyncView();
  }
}
