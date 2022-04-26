import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;

import 'collection_database.dart';
import 'conf/config.dart';
import 'conf/strings.dart';
import 'goto.dart';
import 'item_data.dart';
import 'loading_overlay.dart';
import 'popup.dart';
import 'selection_view.dart';

class ActionButtons extends StatefulWidget {
  ConnectionDB _db;
  AnimationController _controller;


  ActionButtons(db, controller) {
    this._db = db;
    this._controller = controller;
  }

  @override
  _ActionButtonsState createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  static const IconData _editIcon = Icons.edit;
  static const IconData _scannerIcon = Icons.qr_code_scanner;

  static const List<IconData> _icons = const [_editIcon, _scannerIcon];

  Widget _buildActionButtons() {
    var _controller = widget._controller;
    Color backgroundColor = Theme.of(context).cardColor;
    Color foregroundColor = Theme.of(context).accentColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: new List.generate(_icons.length, (int index) {
        Widget child = new Container(
          height: 70.0,
          width: 56.0,
          alignment: FractionalOffset.topCenter,
          child: new ScaleTransition(
            scale: new CurvedAnimation(
              parent: _controller,
              curve: new Interval(0.0, 1.0 - index / _icons.length / 2.0,
                  curve: Curves.easeOut),
            ),
            child: new FloatingActionButton(
              heroTag: null,
              backgroundColor: backgroundColor,
              mini: true,
              child: new Icon(_icons[index], color: foregroundColor),
              onPressed: () {
                _onPressedActionButton(_icons[index]);
              },
            ),
          ),
        );
        return child;
      }).toList()
        ..add(
          new FloatingActionButton(
            heroTag: null,
            child: new AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget child) {
                return new Transform(
                  transform:
                      new Matrix4.rotationZ(_controller.value * 0.5 * math.pi),
                  alignment: FractionalOffset.center,
                  child: new Icon(
                      _controller.isDismissed ? Icons.add : Icons.close),
                );
              },
            ),
            onPressed: () {
              if (_controller.isDismissed) {
                _controller.forward();
              } else {
                _controller.reverse();
              }
            },
          ),
        ),
    );
  }

  Future<String> _getNameByInput({initialName, description}) async {
      var name = await Popup.inputDialog(context, name:initialName, description: description);
    //var name = await _asyncInputDialog(context, name:initialName, description: description);
    if (name != null) {
      name = name.trim();
      if (name == "") {
        name = null;
      }
    }
    print("--------- name $name");
    return name;
  }

  _onPressedActionButton(IconData iconPressed) async {
    //print(iconPressed);
    ItemData newItem;
    final overlay = LoadingOverlay.of(context);

    try {
      if (iconPressed == _scannerIcon) {
        overlay.show();
        String barcodeScanRes; // ="097361244266";
        barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
            "#ff6666", Strings.cancel, true, ScanMode.BARCODE);

        newItem = await _searchOnlineByBarcode(barcodeScanRes);
      } else if (iconPressed == _editIcon) {
        var name = await _getNameByInput();
        overlay.show();
        newItem = await _getMovieDataByName(name, false);
      }
    } catch (e) {
      print(e);
      await Popup.error(context, "Error", e.toString());
    }

    if (newItem != null) {
      print("----------------------------------------------- inset");

      int id = await widget._db.item.insertNew(newItem);
      newItem = await widget._db.item.getById(id);

      print("----------------------------------------------- insert OK ${id}");

      setState(overlay.hide);
      await GoTo.ItemDataView(context, newItem);
    } else {
      setState(overlay.hide);
    }
  }

  Future _asyncInputDialog(BuildContext context, {String name, String description}) async {
    String stringName = name == null ? "" : name;
    description = description == null ? "": description;
    return showDialog(
      context: context,
      barrierDismissible: false,
      // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Strings.nameToSearchTitle),
          content: Column(
            children: [
              Text(description),
              new Expanded(
                  child: new TextFormField(
                initialValue: stringName,
                autofocus: true,
                decoration: new InputDecoration(
                    labelText: Strings.nameToSearchInput,
                    hintText: Strings.nameToSearchExample),
                onChanged: (value) {
                  stringName = value;
                },
              ))
            ],
          ),
          actions: [
            FlatButton(
              child: Text(Strings.ok),
              onPressed: () {
                Navigator.of(context).pop(stringName);
              },
            ),
            FlatButton(
              child: Text(Strings.cancel),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
          ],
        );
      },
    );
  }

  _searchOnlineByBarcode(String barcode) async {
    if (barcode == "-1") {
      return null;
    }
    ItemData newItem;
    print(">>>  barcode $barcode");
    String aloneName = await _getNameFromBarCode(barcode);

    print("_searchOnlineByBarcode $aloneName");

    if (aloneName != null) {
      newItem = await _getMovieDataByName(aloneName, true);
      if (newItem != null) {
        newItem.barcode = barcode;
      }
    } else {
      await Popup.error(context, "Not Found", 'Try to search by name');
    }

    return newItem;
  }

  Future<List<dynamic>> _searchByNameIMDB(name) async {
    if (name == null) return null;
    //var urlMovieData = "https://imdb8.p.rapidapi.com/title/find?q=" + name;
    var httpsUri = Uri(
        scheme: 'https',
        host: 'imdb8.p.rapidapi.com',
        path: 'title/find',
        queryParameters: {'q': name});

    print(">> imdb $httpsUri");
    var response = await http.get(
      httpsUri,
      headers: {
        "x-rapidapi-key": Config.IMDB_KEY,
        "x-rapidapi-host": "imdb8.p.rapidapi.com",
        "useQueryString": "true"
      },
    );
    var responseData = jsonDecode(response.body);
    List<dynamic> results = responseData["results"];
    //print("All movies: $results");

    return results;
/*
    movieData = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectionView(results)),
    );

    print("selected: $movieData");

    if(movieData != null) {
      String imdbId = movieData["id"];
      imdbId = imdbId.replaceFirst("/title/", "").replaceAll("/", "");
      //movieData["id"] = imdbId;

      movieData = await _getComplementData(imdbId);
    }

    return movieData;*/
  }

  Future<List<dynamic>> _searchByNameOMBD(name) async {
    List<dynamic> resultAsList;
    /*var urlMovieData = 'http://www.omdbapi.com/?plot=full&t=' +
        name +
        '&apikey=' +
        Config.OMDB_KEY;
*/
    var urlMovieData = Uri(
        scheme: 'http',
        host: 'www.omdbapi.com',
        queryParameters: {
          'plot': 'full',
          't':name,
          'apikey':Config.OMDB_KEY
        });

    print(">> omdbapi $urlMovieData");

    var response = await http.get(urlMovieData);
    print("response ${response.statusCode}  ---  ${response.body}");

    var responseData = jsonDecode(response.body);
    if (responseData["Error"] == null) {
      resultAsList = [responseData];
    }

    return resultAsList;
  }

  _openMovieSelector(List<dynamic> resultAsList, bool addComplement) async {
    var movieData = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectionView(resultAsList)),
    );
    print("selected: $movieData");

    if (movieData != null && addComplement) {
      String imdbId = movieData["id"];
      imdbId = imdbId.replaceFirst("/title/", "").replaceAll("/", "");

      movieData = await _getComplementData(imdbId);
    }

    return movieData;
  }

  _getMovieDataByName(name, fromBarcode) async {
    if (name == null) return null;

    ItemData newItem;
    List<dynamic> itemsFound;
    var movieData;
    bool searchComplement = false;
    if (fromBarcode) {
      itemsFound = await _searchByNameOMBD(name);
    }

    if (itemsFound == null) {
      searchComplement = true;
      itemsFound = await _searchByNameIMDB(name);
    }
    if (itemsFound == null) {
      name = await _getNameByInput(initialName: name, description: "The Movie was not found, edit the name to search again.");
      if (name != null) {
        searchComplement = true;
        itemsFound = await _searchByNameIMDB(name);
      }
    } else {
      print("found ${itemsFound.length}   ------  $itemsFound");
    }

    movieData = await _openMovieSelector(itemsFound, searchComplement);

    /* if (movieData == null) {

    } */

    if (movieData != null) {
      newItem = ItemData.fromOMDB(movieData, true);
    }
    print("_getMovieDataByName $movieData");

    return newItem;
  }

  _getComplementData(String id) async {
   /* var urlMovieData = 'http://www.omdbapi.com/?plot=full&i=' +
        id +
        '&apikey=' +
        Config.OMDB_KEY;*/

    var urlMovieData  = Uri(
        scheme: 'http',
        host: 'www.omdbapi.com',
        queryParameters: {
          'plot': 'full',
          'i':id,
          'apikey':Config.OMDB_KEY
        });

    var response = await http.get(urlMovieData);

    return jsonDecode(response.body);
  }




  _getNameFromBarCode(barcode) async {
    print("barcode $barcode");
    if (barcode == -1) {
      return null;
    }
    String name;
    //barcode = "7999005920754";//"7506005920754";
    //var url = 'https://ebay-com.p.rapidapi.com/products/' + barcode;

    var url  = Uri(
        scheme: 'https',
        host: 'ebay-com.p.rapidapi.com',
        path: 'products/'+barcode);

    //var response;
    var response = await http.get(
      url,
      headers: {
        "x-rapidapi-key": Config.E_BAY_KEY,
        "x-rapidapi-host": "ebay-com.p.rapidapi.com"
      },
    );
    var jsonVar = jsonDecode(response.body);

    //var jsonVar = jsonDecode("{}");
    //print('Response status: ${response.statusCode}');
    print(">>> ebay  $jsonVar");

    if (response.statusCode != 200) {
      var url  = Uri(
          scheme: 'https',
          host: 'barcode.monster',
          path: 'api/'+barcode);
      response = await http.get(url);//'https://barcode.monster/api/' + barcode);
      jsonVar = jsonDecode(response.body);

      print('Response status: ${response.statusCode}');
      print('>>> barcode.monster: ${response.body}');

      if (jsonVar['description'] != null) {
        name = jsonVar["description"];
      }
    } else {
      name = jsonVar["Title"];
    }

    print("NAME by barcode $name");
    var aloneName;
    if (name != null) {
      var regexToClean = new RegExp(r'[\<\(\[].*?[\)\]\>]');
      // aloneName = name.replaceAll(new RegExp(r'[\<\(\[].*?[\)\]\>]'), '').trim();
      Iterable<RegExpMatch> matches = regexToClean.allMatches(name);

      if (matches.length > 1) {
        aloneName =
            name.replaceRange(matches.first.start, name.length, "").trim();
      } else {
        if (matches.length > 0) {
          aloneName = name
              .replaceRange(matches.first.start, matches.first.end, "")
              .trim();
        } else {
          aloneName = name.trim();
        }
      }
    }

    print("ALONE name: $aloneName");
    return aloneName;
  }

  @override
  Widget build(BuildContext context) {
    return _buildActionButtons();
  }
}
