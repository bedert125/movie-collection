import 'package:flutter/material.dart';
import 'conf/strings.dart';
import 'conf/styles.dart';

class SelectionView extends StatelessWidget {
  List<dynamic> itemsFound;

  SelectionView(itemsFound) {
    this.itemsFound = itemsFound;
  }

  _showSelection(context) {
    if (itemsFound == null) {
      return Container(child: Center(child: Text("Not Found")));
    } else {
      final tiles = <ListTile>[];
      for (var i = 0; i < itemsFound.length; i++) {
        var title = itemsFound[i]["title"];
        if (title == null) {
          title = itemsFound[i]["Title"];
        }

        var year = itemsFound[i]["year"];
        if (year == null) {
          year = itemsFound[i]["Year"];
        }
        if (year == null) {
          year = "";
        }
        var image;
        image = itemsFound[i]["image"];

        if( image!= null && image["url"] != null){
          print("imageUrl");
          image = image["url"];
        }else{
          image = null;
        }

        var prev;
        if(image == null && itemsFound[i]["Poster"] != null) {
          print("poster");
          image = itemsFound[i]["Poster"];
        }

        if(image != null){
          print(image);
          prev = Image.network(image,
            fit:BoxFit.contain,
            width: 50,
            height: 50,
            loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
              if (loadingProgress == null) return child;
              return  CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null ?
                  loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                      : null,
                );

            },
          );
        }

        if (title != null) {
          tiles.add(ListTile(
              title: Text( title,
                style: Styles.itemText,
              ),
              trailing: Text("[" + year.toString() + "]"),
              leading: prev,
              onTap: () {
                Navigator.pop(context, itemsFound[i]);
              }));
        }
      }

      final divided = ListTile.divideTiles(
        context: context,
        tiles: tiles,
      ).toList();

      return ListView(children: divided);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(Strings.itemSelectionTitle),
        ),
        body: _showSelection(context));
  }
}
