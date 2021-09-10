import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:movie_collection/popup.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

import 'collection_database.dart';
import 'conf/config.dart';
import 'conf/strings.dart';
import 'format_view.dart';
import 'item_data.dart';
import 'conf/styles.dart';

class ConfigView extends StatefulWidget {
  @override
  _ConfigViewState createState() => _ConfigViewState();
}

class _ConfigViewState extends State<ConfigView> {
  static String noChanges = "*****";

  List<List<String>> settingsArray = [
    [
      Config.IMDB_API_KEY != null ? noChanges : "",
      Strings.imdbApiKey,
      "https://imdb-api.com/api"
    ],
    [
      Config.IMDB_KEY != null ? noChanges : "",
      Strings.imdbKey,
      "https://rapidapi.com/apidojo/api/imdb8/"
    ],
    [
      Config.OMDB_KEY != null ? noChanges : "",
      Strings.omdbKey,
      "http://www.omdbapi.com/apikey.aspx"
    ],
    [
      Config.E_BAY_KEY != null ? noChanges : "",
      Strings.ebayKey,
      "https://rapidapi.com/yahoo.finance.low.latency/api/ebay-com/"
    ]
  ];

  _buildView() {
    print(settingsArray);
    List<Widget> configElements = [];
    for (var i = 0; i < settingsArray.length; i++) {
      List<String> settingsStrings = settingsArray[i];
      Widget newConfig = Container(
          padding: Styles.rowPadding,
          child: Column(children: [
            Row(children: [
              Icon(
                Icons.vpn_key,
                color: Theme.of(context).accentColor,
              ),
              SizedBox(width: Styles.paddingValue),
              Expanded(
                  child: TextFormField(
                initialValue: settingsStrings[0],
                //autofocus: true,
                decoration: InputDecoration(
                    labelText: settingsStrings[1], hintText: ""),
                onChanged: (value) {
                  settingsStrings[0] = value;
                },
              ))
            ]),
            Row(children: [
              SizedBox(
                width: 50,
              ),
              Expanded(
                child: InkWell(
                    child: Container(
                      padding: Styles.padding,
                      child: Text(
                        Strings.apiKeyInfo
                            .replaceFirst("%s", settingsStrings[1])
                            .replaceFirst("%s", settingsStrings[2]),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: Styles.hiperlink.copyWith(
                            color: Theme.of(context).accentColor, fontSize: 13),
                      ),
                    ),
                    onTap: () => launch(settingsStrings[2])),
              )
            ])
          ]));

      configElements.add(newConfig);
    }

    configElements.add(Container(
        padding: Styles.rowPadding.copyWith(top: 50),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ElevatedButton.icon(
            onPressed: () {
              _onSave();
              // Respond to button press
            },
            icon: Icon(Icons.save, size: 18),
            label: Text(Strings.save),
          ),
        )));

    return ListView(
      children: configElements,
    );
  }

  _onSave(){
    for (var i = 0; i < settingsArray.length; i++) {
      List<String> settingsStrings = settingsArray[i];
      String newKey = settingsStrings[0];
      if(newKey != noChanges && newKey != ""){
        print("saving $settingsStrings ");
        switch(i){
          case 0:
            Config.IMDB_API_KEY = newKey;
            break;
          case 1:
            Config.IMDB_KEY = newKey;
            break;
          case 2:
            Config.OMDB_KEY = newKey;
            break;
          case 3:
            Config.E_BAY_KEY = newKey;
            break;
        }
        
      }
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    _getIMDBAPIKEYInput() async {
      print("--------- key ${Config.IMDB_API_KEY}");

      var key = await Popup.inputDialog(context,
          name: "KEY",
          description: "https://imdb-api.com/ KEY",
          label: "Key",
          example: "put a key");

      if (key != null) {
        key = key.trim();
        Config.IMDB_API_KEY = key;
        print("--------- key ${Config.IMDB_API_KEY} updated");
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.settings),
      ),
      body: _buildView(),
    );
  }
}
