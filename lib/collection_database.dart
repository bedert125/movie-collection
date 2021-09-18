import 'dart:async';
import 'package:flutter/material.dart';
import 'package:movie_collection/request.dart';

import 'conf/config.dart';
import 'item_data.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'loading_overlay.dart';
import 'utils/utils.dart';

class ConnectionDB {
  static Future<Database> _db;

  static const String TABLE_ITEMS = "items";
  static const String TABLE_TRANSLATED = "translated";
  static const String TABLE_FORMATS = "formats";
  static const String TABLE_LANGS = "languages";

  static const String TABLE_ITEM_FORMATS = "items_formats";

  static const String FK_ITEMS_ID = "item_id";
  //static const String FK_TRANSLATED_ID = "item_id";
  static const String FK_FORMATS_ID = "format_id";
  static const String FK_LANG_ID = "lang_id";

  static const Map<String, int> FORMAT_IDS = {
    "DVD": 1,
    "BR": 2,
    "4K": 3,
    "3D": 4,
    "VHS": 5,
    "DIGITAL": 5
  };

  // static const Map<int, String> FORMAT_KEYS = {1:"DVD",2: "BR", 3: "4K"};

  /* FORMAT_IDS.forEach((key, val) {
    FORMAT_KEYS[val] = key;
  });*/

  var item = tableItems();

  _base(db) async {
    print("init DB");
    print("init items");
    await db.execute(
      "CREATE TABLE  IF NOT EXISTS " +
          TABLE_ITEMS +
          "(id INTEGER PRIMARY KEY, "
          //    "name TEXT, "
          //"description TEXT, "
              "favorite INTEGER, "
              "image TEXT, "
              "imdb TEXT, "
              "year INTEGER,"
              "barcode text)",
    );

    print("init format");
    await db.execute(
      "CREATE TABLE  IF NOT EXISTS " +
          TABLE_ITEM_FORMATS +
          "(id INTEGER PRIMARY KEY AUTOINCREMENT, " +
          FK_ITEMS_ID +
          " INTEGER, " +
          FK_FORMATS_ID +
          " INTEGER)",
    );

    print("init langs");
    await db.execute(
      "CREATE TABLE  IF NOT EXISTS " +
          TABLE_LANGS +
          "(id INTEGER PRIMARY KEY AUTOINCREMENT, "
              "name TEXT)",
    );

    print("  langs insert lang EN");
    await db.insert(
      ConnectionDB.TABLE_LANGS,
      {
        "id": 1,
        "name": "EN"
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    print("  langs insert lang ES");
    await db.insert(
      ConnectionDB.TABLE_LANGS,
      {
        "id": 2,
        "name": "ES"
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );


    print("init translated");
    await db.execute(
      "CREATE TABLE  IF NOT EXISTS " +
          TABLE_TRANSLATED +
          "(id INTEGER PRIMARY KEY AUTOINCREMENT, "
              "name TEXT, "
              "description TEXT, "+
              "url TEXT, "+
          FK_ITEMS_ID + " INTEGER, "+
          FK_LANG_ID + " INTEGER DEFAULT 1)",
    );


    print("end DB");
  }

  _toV8_9(db) async {
    // await db.execute( "DROP TABLE " +TABLE_TRANSLATED);
    await _base(db);

    print("starting 8 to 9");
    /* print("   get items");
    final List<Map<String, dynamic>> items = await db.query(
        ConnectionDB.TABLE_ITEMS,
        select: "id, name, description"
    );
    print("items ${items.length}");
     */
    // move data form item to translated
    var toV9Result = await db.transaction((txn) async {
 /*
    for(var i =0; i< items.length; i++) {
      var item = items[i];
      var itemId = await txn.insert(
        ConnectionDB.TABLE_TRANSLATED,
        {
          "name" : item["name"],
          "description" : item["description"],
          FK_ITEMS_ID:  item["id"],
          FK_LANG_ID: 1
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print("updated $itemId ${item["name"]}");
    }

  */
      print(" moving data TABLE_TRANSLATED");
      var result = await txn.execute(
          "INSERT INTO "+
              TABLE_TRANSLATED + "(name,description,"+FK_ITEMS_ID+")"
              "SELECT name,description,id FROM " + TABLE_ITEMS);

      print("moved $result");

      /*
      result = await txn.execute(
        "INSERT INTO "+
            TABLE_TRANSLATED + "("+FK_LANG_ID+")"
            "WHERE "
            "SELECT name,description,id FROM " + TABLE_ITEMS);

      print("moved $result");*/

      print(" moving data _bak");
      await txn.execute(
        "CREATE TABLE " +
            TABLE_ITEMS +"_bak "
          "(id INTEGER PRIMARY KEY, "
            "name TEXT, "
            "favorite INTEGER, "
            "image TEXT, "
            "imdb TEXT, "
            "year INTEGER,"
            "barcode text)");

      print(" moving to new table");
      await txn.execute(
          "INSERT INTO "+
              TABLE_ITEMS +"_bak (id,name,favorite,image,imdb,barcode)"
              "SELECT id,name,favorite,image,imdb,barcode FROM " + TABLE_ITEMS);

      print(" drop _bak");
      await txn.execute( "DROP TABLE " +TABLE_ITEMS);
      print("renaming");
      await txn.execute( "ALTER TABLE "+TABLE_ITEMS +"_bak RENAME TO " + TABLE_ITEMS);

      // assert(1 == 0);

    });

    print("result $toV9Result");

    /* BEGIN TRANSACTION;
    CREATE TEMPORARY TABLE t1_backup(a,b);
    INSERT INTO t1_backup SELECT a,b FROM t1;
    DROP TABLE t1;
    CREATE TABLE t1(a,b);
    INSERT INTO t1 SELECT a,b FROM t1_backup;
    DROP TABLE t1_backup;
    COMMIT;
     */

  }

  _toV9_10(db) async {
    // await db.execute( "DROP TABLE " +TABLE_TRANSLATED);
    await _base(db);

    print("starting 9 to 10");
    // move data form item to translated
    var toUpgradeResult = await db.transaction((txn) async {

      print(" moving data _bak");
      await txn.execute(
          "CREATE TABLE " +
              TABLE_ITEMS +"_bak "
              "(id INTEGER PRIMARY KEY, "
              "favorite INTEGER, "
              "image TEXT, "
              "imdb TEXT, "
              "year INTEGER,"
              "barcode text)");

      print(" moving to new table");
      await txn.execute(
          "INSERT INTO "+
              TABLE_ITEMS +"_bak (id,favorite,image,imdb,barcode)"
              "SELECT id,favorite,image,imdb,barcode FROM " + TABLE_ITEMS);

      print(" drop _bak");
      await txn.execute( "DROP TABLE " +TABLE_ITEMS);
      print("renaming");
      await txn.execute( "ALTER TABLE "+TABLE_ITEMS +"_bak RENAME TO " + TABLE_ITEMS);




      print(" moving data TABLE_TRANSLATED_bak");
      await txn.execute(
          "CREATE TABLE " +
              TABLE_TRANSLATED +"_bak "
              " (id INTEGER PRIMARY KEY AUTOINCREMENT, "
              " name TEXT, "
              " description TEXT, "+
              " url TEXT, "+
              FK_ITEMS_ID + " INTEGER, "+
              FK_LANG_ID + " INTEGER DEFAULT 1)");

      print(" moving to new TABLE_TRANSLATED table");
      await txn.execute(
          "INSERT INTO "+
              TABLE_TRANSLATED +"_bak "
              " (id,name,description,"+FK_ITEMS_ID+","+FK_LANG_ID+") "
              " SELECT id,name,description,"+FK_ITEMS_ID+","+FK_LANG_ID+
              " FROM " + TABLE_TRANSLATED);

      print(" drop TABLE_TRANSLATED_bak");
      await txn.execute( "DROP TABLE " +TABLE_TRANSLATED);
      print("renaming TABLE_TRANSLATED");
      await txn.execute( "ALTER TABLE "+TABLE_TRANSLATED +"_bak RENAME TO " + TABLE_TRANSLATED);

      //assert(1 == 0);

    });

    print("result $toUpgradeResult");

    /* BEGIN TRANSACTION;
    CREATE TEMPORARY TABLE t1_backup(a,b);
    INSERT INTO t1_backup SELECT a,b FROM t1;
    DROP TABLE t1;
    CREATE TABLE t1(a,b);
    INSERT INTO t1 SELECT a,b FROM t1_backup;
    DROP TABLE t1_backup;
    COMMIT;
     */

  }

  start() async {
    if (_db == null) {
      _db = openDatabase(
        join(await getDatabasesPath(), 'collection_database.db'),
        onCreate: (db, version) async {
          print("---------- creating DB --------");

          await _base(db);

          /*
          FORMAT_IDS.forEach((key, val) {
            db.insert(
              TABLE_FORMATS,
              {"id": val, "name": key},
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          });*/
        },
        onUpgrade: (db,  oldVersion,  newVersion) async{
          print("---------- upgrade DB --------");
          print("upgrade $oldVersion,  $newVersion ");
          switch(oldVersion){
            case 8:
              print("upgrade to 9");
              await _toV8_9(db);
              continue v9;

            v9:
            case 9:
              print("upgrade to 10");
              await _toV9_10(db);
          }
        },
        // Set the version. This executes the onCreate function and provides a
        // path to perform database upgrades and downgrades.
        version: 10,
      );


      if(Config.LANG_LIST == null ){
       var list = await tableLangs().getAll();
       Config.LANG_LIST = {};
       for(var i=0; i<list.length;i++){
         Config.LANG_LIST[list[i]["id"]] = list[i]["name"];
       }

       print("LANG ${Config.LANG_LIST}");
      }
      print("---------- LOADED DB --------");
    }
  }
}

class tableItems {

  var formats = tableFormats();
  var translation = tableTranslated();

  Future<int> insertNew(ItemData item) async {
    final Database db = await ConnectionDB._db;

    var itemId = await db.insert(
      ConnectionDB.TABLE_ITEMS,
      item.toDB(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await translation.insert(item.id, item.name, item.description, "", 1); // English by defect

    if (item.formats != null) {
      await formats.update(item);
    }
    return itemId;
  }


  _getDynamicItemsQuery(int _lang, String _order, {String search= ""}){

    String where ="";
    if(search!= ""){
      where =" WHERE ${ConnectionDB.TABLE_TRANSLATED}.name  COLLATE SQL_Latin1_General_CP1_CI_AI LIKE  \"%$search%\" ";
    }

    String query = "SELECT id,name,${ConnectionDB.FK_LANG_ID} FROM ( "
        "SELECT "
        "${ConnectionDB.TABLE_ITEMS}.id, "
        "${ConnectionDB.TABLE_TRANSLATED}.name, "
        "CASE "
        "  WHEN ${ConnectionDB.FK_LANG_ID} = $_lang THEN 1 "
        "  WHEN ${ConnectionDB.FK_LANG_ID} = 1 THEN 2 "
        "  ELSE 3 END "
        "  as langOrder, "
        // "IIF(${ConnectionDB.FK_LANG_ID} = $_lang,1,2) as langOk, "
        "${ConnectionDB.TABLE_TRANSLATED}.${ConnectionDB.FK_LANG_ID} "
        " FROM "
        " ${ConnectionDB.TABLE_ITEMS} "
        " INNER JOIN ${ConnectionDB.TABLE_TRANSLATED} "
        "   ON ${ConnectionDB.TABLE_ITEMS}.id= ${ConnectionDB.FK_ITEMS_ID} "
        " $where "
        "ORDER BY ${ConnectionDB.TABLE_ITEMS}.id, langOrder DESC"
        ") AS t "
        "GROUP BY t.id "
        "ORDER BY $_order";

    return query;
  }

  Future<List<ItemData>> _search() async {


    List<ItemData> toReturn = [];

    final Database db = await ConnectionDB._db;
    var orderBy = Config.ORDER_BY == "" ? null : Config.ORDER_BY;
    var where = null;
    var args = null;
    if (Config.SEARCH != "") {
      where = "name COLLATE SQL_Latin1_General_CP1_CI_AI LIKE ?";
      args = ["%" + Config.SEARCH + "%"];
    }

    /* final List<Map<String, dynamic>> items = await db.rawQuery('SELECT * FROM "${ConnectionDB.TABLE_ITEMS}" '
        'LEFT JOIN ${ConnectionDB.TABLE_TRANSLATED} ON ${ConnectionDB.TABLE_ITEMS}.id = ${ConnectionDB.TABLE_TRANSLATED}.${ConnectionDB.FK_ITEMS_ID} '
        ' $where '
        ' ORDER BY $orderBy limit $max offset $start', args); */
    final List<Map<String, dynamic>> itemsName = await db.query(
      ConnectionDB.TABLE_TRANSLATED,
      columns: [ConnectionDB.FK_ITEMS_ID,"name"],
      orderBy: orderBy,
      groupBy: ConnectionDB.FK_ITEMS_ID,
      where: where,
      whereArgs: args,
    );


    if(itemsName.length>0){

      var foundItems= "";
      for(var i= 0; i< itemsName.length-1;i++){
        foundItems += itemsName[i][ConnectionDB.FK_ITEMS_ID].toString()+", ";
      }
      foundItems += itemsName.last[ConnectionDB.FK_ITEMS_ID].toString();
      where = "id IN ("+foundItems+")";
      //print("idss->>> $foundItems");

      args = [foundItems];
      final List<Map<String, dynamic>> items = await db.query(
        ConnectionDB.TABLE_ITEMS,
        orderBy: orderBy,
        where: where,
        //whereArgs: args,
      );
      // print(items[0]);
      toReturn = await _joinTranslatedFromDB(items,false);
    }


    return toReturn;
  }

  Future<List<ItemData>> _joinTranslatedFromDB(List<Map<String, dynamic>> items , bool allTranslations) async{
    List<ItemData> toReturn = [];
    for (var i = 0; i < items.length; i++) {
      var formatList = await formats.get(items[i]["id"]);
      var itemData;
      if(allTranslations){
        var translatedDataAll = await translation.getAll(items[i]["id"]);
        itemData = ItemData.fromDBfully(
            items[i],
            formatList,
            translatedDataAll
        );
      }else{
        var translatedData = await translation.get(items[i]["id"], Config.LANG);
        if(translatedData == null || (translatedData!= null && translatedData["name"]==null)){
          // translatedData = await _getTranslated(items[i]["id"],items[i]["imdb"],Config.LANG);
          translatedData = await translation.get(items[i]["id"], 1); // english
        }
        itemData = ItemData.fromDB(
            items[i],
            formatList,
            translatedData
        );
      }

      //var newItem = itemData;
      toReturn.add(itemData);
    }

    return toReturn;
  }

  Future<List<ItemData>> getToExport(int start, int max,{bool allTranslations}) async {
    if (start == null || start < 0) {
      start = 0;
      max = 1;
    }

    allTranslations = allTranslations ?? false;

    List<ItemData> toReturn = [];


      final Database db = await ConnectionDB._db;
      // var orderBy = Config.ORDER_BY == "" ? null : Config.ORDER_BY;
      // var where = null;
      // var args = null;

      final List<Map<String, dynamic>> items = await db.query(
        ConnectionDB.TABLE_ITEMS,
        // offset: start,
        // limit: max,
        // orderBy: orderBy,
        // where: where,
        // whereArgs: args,
      );

      if (items != null)
        print("get DB >>  ${items.length}");
      else
        print("get DB >>  ${items}");

      toReturn = await _joinTranslatedFromDB(items, allTranslations);


    return toReturn;
  }

  Future<List<ItemData>> getAllAsList() async{

    List<ItemData> toReturn = [];

    var orderBy = Config.ORDER_BY;
    var lang = Config.LANG;
    var search = Config.SEARCH;

    var query =  _getDynamicItemsQuery(lang, orderBy, search: search);
    print("query $query");

    final Database db = await ConnectionDB._db;

    final List<Map<String, dynamic>> items = await db.rawQuery(query);

    for(var i=0;i<items.length;i++){
      var item =items[i];
      var currentLang = item[ConnectionDB.FK_LANG_ID];
      // print(item);
      //print("------ ${item["id"]} ${item[ConnectionDB.FK_LANG_ID]}  ${item["name"]} ");
      ItemData itemData = await getById(item["id"], lang: currentLang);
      toReturn.add(itemData);
    }


    return toReturn;
  }

  _getTranslated(int itemId,String imdb, int lang,{bool updateYear=false}) async{
    var translatedData;
    if(Config.IMDB_API_KEY != null){

      var translated = await Request.getTranslatedData(imdb);
      print("translated $translated");
      if(translated["plotShort"]["plainText"] == null){
        print("Error :( getTranslatedData not exist");
        assert(translated["plotShort"]["plainText"] != null);
      }
      var title = translated["titleInLanguage"] ?? translated["title"];
      if(title == null){
        print("Error :( getTranslatedData not exist");
        assert(title != null);
      }
      await translation.insert(itemId, title, translated["plotShort"]["plainText"],translated["url"], lang);
      translatedData = await translation.get(itemId, lang);

      if(updateYear){
        int year = Utils.toYear(translated["year"]);

        print("updating Year ->${translated["year"]}<-  >$year<");

        await updateWith(itemId, {"year":year});
      }

    }else{
      print("imdb-api key missing");
      translatedData = await translation.get(itemId, 1);
    }

    return translatedData;
  }

  Future<ItemData> getById(int id, {int lang=-1}) async {
    final Database db = await ConnectionDB._db;

    final List<Map<String, dynamic>> items = await db.query(
      ConnectionDB.TABLE_ITEMS,
      where: "id = ?",
      whereArgs: [id],
    );

    if(lang == -1){
      print("find by using Config.LANG ${Config.LANG} ");
      lang = Config.LANG;
    }

    var formatList = await formats.get(items[0]["id"]);
    var translatedData = await translation.get(items[0]["id"], lang);

    if(translatedData == null){
      print("NOT found $lang ");
      try{
        translatedData = await _getTranslated(items[0]["id"],items[0]["imdb"],Config.LANG,updateYear: items[0]["year"] == null);
      }catch(err) {
        print('Caught error: $err');
      }
    }

    if(translatedData == null || translatedData["name"] == null){
      translatedData = await translation.get(items[0]["id"], 1); // no info in other lang
    }

    // print("translatedData ${translatedData[ConnectionDB.FK_LANG_ID]} $translatedData");
    var itemData = ItemData.fromDB(
        items[0],
        formatList,
        translatedData);
    return itemData;
  }

  Future<void> update(ItemData item) async {
    final db = await ConnectionDB._db;

    await db.update(
      ConnectionDB.TABLE_ITEMS,
      item.toDB(),
      where: "id = ?",
      whereArgs: [item.id],
    );
  }

  Future<void> updateWith(int itemId, Map<String,dynamic> toUpdate) async {
    final db = await ConnectionDB._db;

    await db.update(
      ConnectionDB.TABLE_ITEMS,
      toUpdate,
      where: "id = ?",
      whereArgs: [itemId],
    );
  }

  Future<void> delete(ItemData item) async {
    final db = await ConnectionDB._db;
    var current = item.formats.toDB(allValues:false);
    print("current Formats $current");

    await formats.deleteByItem(item);

    await db.delete(
      ConnectionDB.TABLE_ITEMS,
      where: "id = ?",
      whereArgs: [item.id],
    );
  }
}

class tableTranslated {

  Future<void> insert(int itemId, String name, String description,String url, int lang) async {
    final db = await ConnectionDB._db;

    var oldElement = await get(itemId, lang);

    if(oldElement != null){
      await db.update(
        ConnectionDB.TABLE_TRANSLATED,
        {
          "id": oldElement["id"],
          "name": name ?? oldElement["name"],
          "description": description ?? oldElement["description"],
          "url": url ?? oldElement["url"],
          ConnectionDB.FK_LANG_ID: lang,
          ConnectionDB.FK_ITEMS_ID: itemId
        },
        where: "id = ?",
        whereArgs: [oldElement["id"]]
      );
    }else{
      await db.insert(
        ConnectionDB.TABLE_TRANSLATED,
        {
          "name": name,
          "description": description,
          "url": url,
          ConnectionDB.FK_LANG_ID: lang,
          ConnectionDB.FK_ITEMS_ID: itemId
        },
        conflictAlgorithm: ConflictAlgorithm.replace
      );
    }


  }

  Future<Map<String, dynamic>> get(int itemId, langId) async {
    //print("get Format id $id");
    final db = await ConnectionDB._db;
    var dataList = await db.query(ConnectionDB.TABLE_TRANSLATED,
        where: "${ConnectionDB.FK_ITEMS_ID} = ? and ${ConnectionDB.FK_LANG_ID} = ?", whereArgs: [itemId, langId]);
    if(dataList.length > 1){
      print("ERROR -------------- translations ${dataList.length}");
      return dataList[0];
    }else if(dataList.length == 0) {
      // print("NO DATA -------------- translations $itemId");
      return null;
    } else{
      // print("translated Found");
      return dataList[0];
    }
  }

  Future<List<Map<String, dynamic>>> getAll(int itemId) async {
    //print("get Format id $id");
    final db = await ConnectionDB._db;

    var where =  "${ConnectionDB.FK_ITEMS_ID} = ?";
    var whereArgs = [itemId];

    return await db.query(ConnectionDB.TABLE_TRANSLATED,
        where: where, whereArgs: whereArgs);

  }

}

class tableLangs {

  Future<List<Map<String, dynamic>>> getAll() async {
    //print("get Format id $id");
    final db = await ConnectionDB._db;
    return await db.query(ConnectionDB.TABLE_LANGS);

  }
}


class tableFormats {
  Future<void> update(ItemData item) async {
    final db = await ConnectionDB._db;

    var values = item.formats.toDB();

    for (var i = 0; i < values.length; i++) {
      var toSave = values[i];
      var id = toSave["id"];
      if (id < 0) {
        toSave.remove("id");
      }

      List<Map<String, dynamic>> itemsFormat = await db.query(
        ConnectionDB.TABLE_ITEM_FORMATS,
        where:
            '${ConnectionDB.FK_ITEMS_ID} = ? AND ${ConnectionDB.FK_FORMATS_ID} = ?',
        whereArgs: [
          toSave[ConnectionDB.FK_ITEMS_ID],
          toSave[ConnectionDB.FK_FORMATS_ID]
        ],
      );

      //print(itemsFormat);
      //print(toSave);

      if (itemsFormat.length > 1 || id == FormatStatus.unselected) {
        for (var j = 0; j < itemsFormat.length; j++) {
          print("-------- delete old format ${itemsFormat[j]}");
          deleteById(itemsFormat[j]["id"]);
        }
      } else if (itemsFormat.length == 0) {
        print("-------- insert new format $toSave");
        await db.insert(
          ConnectionDB.TABLE_ITEM_FORMATS,
          toSave,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  Future<void> deleteById(int id) async {
    final db = await ConnectionDB._db;
    var deleted = await db.delete(
      ConnectionDB.TABLE_ITEM_FORMATS,
      where:"id = ?",
      whereArgs: [id],
    );
    print("Format Deleted $deleted , itemID $id");
  }

  Future<void> deleteByItem(ItemData item) async {
    final db = await ConnectionDB._db;
    var deleted = await db.delete(
      ConnectionDB.TABLE_ITEM_FORMATS,
      where:"${ConnectionDB.FK_ITEMS_ID} = ?",
      whereArgs: [item.id],
    );
    print("Format Deleted $deleted , itemID ${item.id}");
  }

  Future<List<Map<String, dynamic>>> get(int id) async {
    //print("get Format id $id");
    final db = await ConnectionDB._db;
    return await db.query(ConnectionDB.TABLE_ITEM_FORMATS,
        where: "${ConnectionDB.FK_ITEMS_ID} = ?", whereArgs: [id]);
  }
}
