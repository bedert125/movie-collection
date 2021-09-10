import 'package:flutter/material.dart';
import 'package:movie_collection/utils/utils.dart';
import 'collection_database.dart';
import 'conf/config.dart';

class ItemData {
  int id;
  String imdb;
  String barcode;
  String name;
  String description;
  bool favorite = false;
  String image;
  Formats formats;
  int year;
  String lang;
  String url;
  int langId;

  List<Translated> translations;

  Map<String, String> data = new Map<String, String>();

  ItemData(
      {id,
      name,
      description,
      image,
      fields,
      favorite,
      barcode, year,
        langId,
      imdb,
        url,
      formatList, translations}) {
    assert(name != null);

    if (id == null) {
      id = new DateTime.now().millisecondsSinceEpoch;
    }
    this.id = id;
    this.name = name;
    this.year = year;
    this.url = url;
    this.langId =langId;
    this.description = description == null ? "" : description;
    this.image = image;

    if (fields != null) this.data.addAll(fields);
    this.data["hola"] = "test";
    this.barcode = barcode;
    this.imdb = imdb;
    this.favorite = favorite == 1;
    this.translations = translations;
    formats = Formats(itemId: this.id, selected: formatList);
  }

  Map<String, dynamic> toDB() {
    return {
      'id': id,
      'imdb': imdb,
      'barcode': barcode,
      'favorite': favorite,
      'year': year,
      'image': image
    };
  }

  Map<String, dynamic> toBigTable() {
    var translationsData = [];
    if(translations != null){
      for(var i=0; i<translations.length;i++){
        translationsData.add(translations[i].toDB());
      }
    }

    return {
      'id': id,
      'imdb': imdb,
      'barcode': barcode,
      'favorite': favorite,
      'image': image,
      'year': year,
      '_formats': formats.toDB(allValues: false),
      '_translations': translationsData
    };
  }

  factory ItemData.fromOMDB(Map<String, dynamic> json, bool formatByDefect) {
    Map<int, bool> newFormatList;
    if(formatByDefect){
      newFormatList = {
        ConnectionDB.FORMAT_IDS["BR"] : true
      };
    }

    int year = Utils.toYear(json["Year"]);
    return new ItemData(
        imdb: json['imdbID'],
        barcode: json['barcode'],
        name: json['Title'],
        description: json["Plot"],
        image: json["Poster"],
        year: year,
        formatList: newFormatList
    );
  }

  factory ItemData.fromIMDB(Map<String, dynamic> json) {
    return new ItemData(name: json['title'], image: json["image"]["url"]);
  }

  static _formatsFromDB(List<Map<String, dynamic>> formats){
    Map<int, bool> formatsSelected = {};
    for (var i = 0; i < formats.length; i++) {
      var formatId = formats[i][ConnectionDB.FK_FORMATS_ID];
      formatsSelected[formatId] = true;
    }

    return formatsSelected;
  }

  factory ItemData.fromDB(
      Map<String, dynamic> item,
      List<Map<String, dynamic>> formats,
      Map<String, dynamic> translated) {

    //print("get Data from DB ${json['name']}" );

    Map<int, bool> formatsSelected = _formatsFromDB(formats);

    //print("lang ${translated[ConnectionDB.FK_LANG_ID]} ${Config.LANG_LIST}");

    var lang = Config.LANG_LIST[translated[ConnectionDB.FK_LANG_ID]];
    // print("lang ${translated[ConnectionDB.FK_LANG_ID]}");

    return new ItemData(
        id: item['id'],
        name: translated['name'],
        url: translated['url'],
        langId: translated[ConnectionDB.FK_LANG_ID],
        imdb: item['imdb'],
        barcode: item['barcode'],
        description: translated["description"],
        image: item["image"],
        year: item["year"],
        formatList: formatsSelected);
  }

  factory ItemData.fromDBfully(
      Map<String, dynamic> item,
      List<Map<String, dynamic>> formats,
      List<Map<String, dynamic>> translations) {

    //print("get Data from DB ${json['name']}" );

    Map<int, bool> formatsSelected = _formatsFromDB(formats);

    List<Translated> translationsList = [];
    for(var i=0; i<translations.length;i++){
      translationsList.add( Translated.fromDB(translations[i]));
    }

    return new ItemData(
        id: item['id'],
        imdb: item['imdb'],
        barcode: item['barcode'],
        image: item["image"],
        year: item["year"],
        translations: translationsList,
        formatList: formatsSelected);
  }


  getIcon() {
    var color = favorite ? Colors.red : null;
    var icon = Icon(favorite ? Icons.favorite : Icons.favorite_border);
    return [icon, color];
  }

  onTapFav() {
    if (favorite) {
      favorite = false;
    } else {
      favorite = true;
    }
  }
}

class Formats {
  int _itemId;

  Map<String, int> values =
      {}; // = {"DVD": FormatStatus.unselected, "BR": FormatStatus.unselected, "4K": FormatStatus.unselected};


  List<Widget> getIcons({size}) {
    var formatsSelected = <Widget>[];

    double wSize;
    switch(size){
      case "s":
        wSize = 30;
        break;
      default:
        wSize =50;
        break;
    }

    values.forEach((key, val) {
      if (val != FormatStatus.unselected) {
        formatsSelected.add(Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
          child: Image.asset(
            "images/" + key + ".png",
            width: wSize,
            height: wSize,
            fit: BoxFit.contain,
          ),
        )
        );
      }
    });
    return formatsSelected;
  }

  Formats({itemId, selected}) {
    assert(itemId != null);

    /*dvd != null && (this.values["dvd"] = dvd);
    br != null && (this.values["br"] = br);
    fourK != null && (this.values["4k"] = fourK);*/
    _itemId = itemId;
    if (selected == null) {
      selected = {};
    }

    ConnectionDB.FORMAT_IDS.forEach((key, val) {
      this.values[key] =
          selected[val] == true ? itemId : FormatStatus.unselected;
    });

    //print(">> Formats ${this.values}");
    //  Icons.four_k
  }

  List<Map<String, dynamic>> toDB({bool allValues}) {
    allValues = (allValues == false) ? false : true;

    List<Map<String, dynamic>> formats = [];
    values.forEach((key, val) {
      Map<String, dynamic> toDB = {};
      if (allValues || val > FormatStatus.validValues) {
        toDB[ConnectionDB.FK_ITEMS_ID] = _itemId;
        toDB[ConnectionDB.FK_FORMATS_ID] = ConnectionDB.FORMAT_IDS[key];
        toDB["id"] = val;
        formats.add(toDB);
      }
    });

    print(">> save format to DB $formats");

    return formats;
  }
}

class FormatStatus {
  static int unselected = -1;
  static int newSelection = -2;
  static int validValues = 0;
}

class Translated {
  int id;
  String name;
  String description;
  int itemId;
  String url;


  Translated({id,name,description,itemId, url}) {
    assert(itemId != null);
    this.id = id;
    this.name = name;
    this.description = description;
    this.url = url;
    this.itemId = itemId;
  }

  Map<String, dynamic> toDB() {
    var data = {
      'id': id,
      'name': name,
      'url': url,
      'description': description,
    };

    data[ConnectionDB.FK_ITEMS_ID] = itemId;

    return data;
  }

  factory Translated.fromDB(Map<String, dynamic> json) {
    return new Translated(
        id: json['id'],
        name: json['name'],
        url: json['url'],
        description: json['description'],
        itemId: json[ConnectionDB.FK_ITEMS_ID]);
    }
}