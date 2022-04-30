import 'dart:async';
import 'dart:math';

import 'package:movie_collection/paged_collection_card_view.dart';
import 'package:movie_collection/paged_collection_list_view.dart';
import 'package:share/share.dart';

import 'package:flutter/material.dart';
import 'package:movie_collection/goto.dart';

import 'action_buttons.dart';
import 'collection_database.dart';
import 'conf/config.dart';
import 'conf/list_preferences.dart';
import 'utils/dropdownBase.dart';
import 'conf/strings.dart';
import 'conf/styles.dart';
import 'export_helper.dart';
import 'loading_overlay.dart';
import 'popup.dart';

class HomeView extends StatefulWidget {

  HomeView(){
    print("####################################################################");
  }
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {

  ListPreferences _listPreferences = ListPreferences(
    sortBy: Config.ORDER_BY,
    viewType: Config.VIEW,
    search: Config.SEARCH,
      dbModification: Config.dbModification
  );
  var _controller, _iconToolController, _arrowAnimation;

  // var _toolPanelcontroller;
  var _offsetToolPanel;

  //var resetListView;
  var searchDelay;

  //var collectionView;

  var _toolPanelIsVisible = false;
  ConnectionDB _db;
  DropdownItem _sortSelected;
  List<DropdownMenuItem<DropdownItem>> _sortMenuItems;
  final List<DropdownItem> _sortItems = [
    DropdownItem(1, "By Added", "id asc"),
    DropdownItem(2, "By Name", "name asc"),
    DropdownItem(2, "By Year", "IFNULL(year,99999) asc"),
    // error al agregar un nuevo que no esté en la ultima posicion de la BD
  ];

  DropdownItem _viewSelected;
  List<DropdownMenuItem<DropdownItem>> _viewMenuItems;
  final List<DropdownItem> _viewItems = [
    DropdownItem(1, "List", "L"),
    DropdownItem(2, "Card", "C"),
    // error al agregar un nuevo que no esté en la ultima posicion de la BD
  ];

  int _isSearching = 0;
  final TextEditingController _searchQuery = new TextEditingController();

  var appBarTitle;
  Icon actionIcon = new Icon(Icons.search);

  var lastSearch = "";

  _updatePeferences() {

   if(Config.SEARCH != _listPreferences.search ||
      Config.VIEW != _listPreferences.viewType ||
       Config.dbModification != _listPreferences.dbModification ||
      Config.ORDER_BY != _listPreferences.sortBy){
     _listPreferences = ListPreferences(
         sortBy: Config.ORDER_BY,
         viewType: Config.VIEW,
         search: Config.SEARCH,
         dbModification: Config.dbModification
     );
   }

  }

  _setNewSearch(String newSearch) {
    print("_isNewSearch -$newSearch-");
    if (lastSearch != newSearch) {
      lastSearch = newSearch;
      Config.SEARCH = newSearch;
      Config.NEEDS_UPDATE = true;
    }
    _isSearching = 0;
  }

  _isValidSeach(newSearchText) {
    print(
        "_isSearching $_isSearching Empty:${newSearchText.isEmpty} val:-$newSearchText-");
    return (newSearchText.isNotEmpty &&
        newSearchText != "" &&
        newSearchText != lastSearch);
  }

  _HomeViewState() {

    _searchQuery.addListener(() {
      setState(() {
        if (_isValidSeach(_searchQuery.text)) {
          _isSearching++;
        }

        if (_isSearching > 0) {
          searchDelay.debounce(() {
            var search = "";
            print(" _searchQuery ");

            if (_searchQuery.text.isNotEmpty) {
              search = _searchQuery.text;
            }

            setState(() {
              _setNewSearch(search);
            });
          });
        }
      });
    });
  }


  _oldExport() async{
    var export = ExportData();
    var items = await _db.item.getToExport(0, -1, allTranslations: true);
    var itemsDataToExport = {};
    for (var i = 0; i < items.length; i++) {
      var data = items[i].toBigTable();
      //print(data);
      itemsDataToExport[items[i].id.toString()] = data;
    }

    await export.add("_items", itemsDataToExport);

    var langs = {};
    Config.LANG_LIST.forEach((key, value) {
      langs[key.toString()] = value;
    });

    await export.add("_langs", langs);

    await export.writeExternalStorage();
  }



  _exportAll() async {
    final overlay = LoadingOverlay.of(context);
    overlay.show();
    String dbFile = await _db.export();
    await Share.shareFiles([dbFile], text: 'Save Your Database');
    overlay.hide();

    Popup.info(context, "Export", "Keep your data in a safety place");
  }

  _saveAll() async {
    final overlay = LoadingOverlay.of(context);
    overlay.show();

    String dbFile = await _db.export();
    var export = ExportData();
    String path = await export.writeDbExternalStorage(dbFile);

    overlay.hide();

    if(path != ""){
      Popup.info(context, "Export", "Your data was saved on Downloads $path");
    }else{
      Popup.error(context, "Export", "Data can not be saved");
    }

  }

  _importAll () async{
    String dbFile = await _db.export();
    var export = ExportData();
    var resutl = await export.importDb(dbFile);

    if(resutl != ""){
      Popup.info(context, "Import", "Your data was loaded");
    }
   /* FilePickerCross myFile = await FilePickerCross.importFromStorage(
        type: FileTypeCross.custom,       // Available: `any`, `audio`, `image`, `video`, `custom`. Note: not available using FDE
        fileExtension: 'bd'     // Only if FileTypeCross.custom . May be any file extension like `dot`, `ppt,pptx,odp`
    );*/
  }

  _tools() {
    var roundedPanelValue = Radius.circular(15);
    List<BoxShadow> shadows = [];
    if (_toolPanelIsVisible) {
      shadows.add(BoxShadow(
        color: Colors.black.withOpacity(0.5),
        spreadRadius: 1,
        blurRadius: 5,
        offset: Offset(0, 0.5), // changes position of shadow
      ));
    }
    return Container(
      padding: Styles.rowPadding,
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.only(
              bottomRight: roundedPanelValue, bottomLeft: roundedPanelValue),
          boxShadow: shadows),
      margin:
          EdgeInsets.fromLTRB(Styles.paddingValue, 0, Styles.paddingValue, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /* FlatButton(
           // color: Colors.blueAccent,
            child: Text(Strings.cancel,
              style:Theme.of(context).primaryTextTheme.bodyText1,),
            onPressed: () {
            },
          ),*/
          Icon(
            Icons.sort_by_alpha,
            color: Theme.of(context).primaryTextTheme.bodyText1.color,
          ),
          SizedBox(width: Styles.paddingValue),
          DropdownButton<DropdownItem>(
              hint: Text(_sortSelected.name,
                  style: Theme.of(context).primaryTextTheme.bodyText1),
              value: null,
              icon: Icon(
                // Add this
                Icons.arrow_drop_down, // Add this
                color: Theme.of(context)
                    .primaryTextTheme
                    .bodyText1
                    .color, // Add this
              ),
              items: _sortMenuItems,
              onChanged: (value) {
                setState(() {
                  Config.ORDER_BY = value.type;
                  Config.NEEDS_UPDATE = true;
                  // collectionView.resetItems();
                  _sortSelected = value;
                });
              }),
          SizedBox(width: Styles.paddingValue * 2),
          Icon(
            Icons.preview,
            color: Theme.of(context).primaryTextTheme.bodyText1.color,
          ),
          SizedBox(width: Styles.paddingValue),
          DropdownButton<DropdownItem>(
              hint: Text(_viewSelected.name,
                  style: Theme.of(context).primaryTextTheme.bodyText1),
              value: null,
              icon: Icon(
                // Add this
                Icons.arrow_drop_down, // Add this
                color: Theme.of(context)
                    .primaryTextTheme
                    .bodyText1
                    .color, // Add this
              ),
              items: _viewMenuItems,
              onChanged: (value) {
                setState(() {
                  Config.VIEW = value.type;
                  Config.NEEDS_UPDATE = true;
                  // collectionView.resetItems();
                  _viewSelected = value;
                });
              }),
          Spacer(),
          /*FlatButton(
            child: Text(Strings.ok),
            onPressed: () {},
          ),

           */
        ],
      ),
    );
  }

  _showHideToolPanel() {
    //print("_showHideToolPanel ${_controllerPanelTool.isCompleted}");

    setState(() {
      print("_showHideToolPanel ${_iconToolController.isCompleted}");
      _toolPanelIsVisible = !_toolPanelIsVisible;
      if (_toolPanelIsVisible) {
        _iconToolController.forward();
        //_toolPanelcontroller.forward();
      } else {
        _iconToolController.reverse();
        //_toolPanelcontroller.reverse();
      }
      _updatePeferences();
    });
  }

  _getAppBar() {
    appBarTitle = Text(Strings.mainTitle);
  }

  void _handleSearchStart() {
    print(">> INIT _handleSearchStart");
    /* setState(() {
      _isSearching = true;
    });*/
  }

  void _handleSearchEnd() {
    print(">> END _handleSearchEnd");
    setState(() {
      _setNewSearch("");
      actionIcon = new Icon(Icons.search);
      _getAppBar();
      _searchQuery.clear();
    });
  }

  _addSection(String name){
    return Container(
      padding: Styles.rowPadding,
      child: Text(name,
        style: Theme.of(context).textTheme.subtitle1
      )
    );
  }

  getDrawerMenu() {
   return Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Image.asset(
          'images/logo.png',
          fit: BoxFit.contain,
        ),
          decoration: BoxDecoration(
            color: Theme.of(context).accentColor,
          ),
        ),
        ListTile(
          title: Text(Strings.settings),
          onTap: () {
            //_getIMDBAPIKEYInput();
             GoTo.SettingsView(context);
          },
          leading: Icon(Icons.settings, color: Theme.of(context).accentColor),
        ),
        Divider(),
        _addSection(Strings.backupTitle),
        ListTile(
          title: Text(Strings.exportIconText),
          onTap: _exportAll,
          leading: Icon(Icons.save, color: Theme.of(context).accentColor),
        ),
        ListTile(
          title: Text(Strings.backupIconText),
          onTap: _saveAll,
          leading: Icon(Icons.save, color: Theme.of(context).accentColor),
        ),
        ListTile(
          title: Text(Strings.importIconText),
          onTap: _importAll,
          leading: Icon(Icons.restore, color: Theme.of(context).accentColor),
        ),
        Divider(
          height: 5.0,
        )
      ],
    ));
  }

  @override
  void dispose() {
    print(">> home dispose");
    super.dispose();
    _controller?.dispose();
    _searchQuery?.dispose();
  }

  @override
  void initState() {
    print(">> initState");
    super.initState();
    _sortMenuItems = DropdownMenu().build(_sortItems);
    _sortSelected = _sortItems.firstWhere((item) {
      return item.type == Config.ORDER_BY;
    }, orElse: () {
      return _sortItems[0];
    });

    _viewMenuItems = DropdownMenu().build(_viewItems);
    _viewSelected = _viewItems.firstWhere((item) {
      return item.type == Config.VIEW;
    }, orElse: () {
      return _viewItems[0];
    });

    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _iconToolController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    //collectionView = CollectionListView();
    _arrowAnimation = Tween(begin: 0.0, end: pi).animate(_iconToolController);

    //_toolPanelcontroller =
    //    AnimationController(vsync: this, duration: Duration(milliseconds: 100));

    _offsetToolPanel = Tween<Offset>(begin: Offset(0.0, -1.0), end: Offset.zero)
        .animate(_iconToolController);

    _getAppBar();
    searchDelay = Debouncer();

    _db = ConnectionDB();
    _db.start();
    print(">> initState end");
  }

  @override
  Widget build(BuildContext context) {
    //print(">>>> build Home reset  $resetListView");
    var collectionView;
    _updatePeferences();
    if (_isSearching > 0) {
      print("---LOADING");
      collectionView = Center(child: CircularProgressIndicator());
    } else {

      if (Config.VIEW == "L") {
        collectionView = PagedCollectionListView(_db, _listPreferences);
      } else {
        collectionView = PagedCollectionCardView(_db, _listPreferences);
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: appBarTitle,
          actions: [
            //IconButton(icon: Icon(Icons.save), onPressed: _exportAll),
            IconButton(
              icon: actionIcon,
              onPressed: () {
                setState(() {
                  if (actionIcon.icon == Icons.search) {
                    actionIcon = Icon(Icons.close);
                    appBarTitle = Container(
                        height: 30,
                        margin: Styles.rowPadding,
                        decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: TextField(
                          autofocus: true,
                          controller: _searchQuery,
                          style: TextStyle(
                            color: Theme.of(context)
                                .primaryTextTheme
                                .bodyText1
                                .color,
                          ),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              isDense: true,
                              // important line
                              contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                              //contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                              hintText: "Search...",
                              hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .primaryTextTheme
                                    .bodyText1
                                    .color,
                              )),
                        ));
                    _handleSearchStart();
                  } else {
                    _handleSearchEnd();
                  }
                });
              },
            ),
            AnimatedBuilder(
                animation: _iconToolController,
                builder: (context, child) => Transform.rotate(
                    angle: _arrowAnimation.value,
                    child: IconButton(
                        icon: Icon(Icons.expand_more),
                        onPressed: _showHideToolPanel))),
          ],
        ),
        body: Stack(
          children: [
            //Expanded(child: collectionView)
            Positioned.fill(child: collectionView),
            //collectionView,
            Align(
                alignment: Alignment.topCenter,
                child: SlideTransition(
                  position: _offsetToolPanel,
                  // child: Visibility(
                  child: _tools(),
                  //visible: _toolPanelIsVisible,
                ))
          ],
        ),
        floatingActionButton: ActionButtons(_db, _controller),
        drawer: getDrawerMenu());
  }
}




class Debouncer {
  Duration delay;
  Timer _timer;
  VoidCallback _callback;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  void debounce(VoidCallback callback) {
    this._callback = callback;

    this.cancel();
    _timer = new Timer(delay, this.flush);
  }

  void cancel() {
    if (_timer != null) {
      _timer.cancel();
    }
  }

  void flush() {
    this._callback();
    this.cancel();
  }
}
