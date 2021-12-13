import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:movie_collection/popup.dart';
import 'package:movie_collection/utils/visualElements.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

import 'collection_database.dart';
import 'conf/config.dart';
import 'utils/ClipShadowPath.dart';
import 'utils/dropdownBase.dart';
import 'conf/strings.dart';
import 'format_view.dart';
import 'item_data.dart';
import 'conf/styles.dart';
import 'loading_overlay.dart';
import 'utils/ribbon_shape.dart';

class ItemView extends StatefulWidget {
  ItemData _item;

  ItemView(ItemData item) {
    //print(item);
    _item = item;
  }

  @override
  _ItemViewState createState() => _ItemViewState();
}

class _ItemViewState extends State<ItemView> {
  ConnectionDB _db;

  List<DropdownMenuItem<int>> _langMenuItems =
      DropdownMenu().buildByMap(Config.LANG_LIST);

  Widget _titleSection() {
    return Container(
      //padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Oeschinen Lake Campground',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Kandersteg, Switzerland',
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.star,
            color: Colors.red[500],
          ),
          Text('41'),
        ],
      ),
    );
  }

  Widget _textSection() {
    List<Widget> itemData =[
      /*Text(
        'Year: ${widget._item.year}',
        softWrap: true,
      ),*/
      Text(
        widget._item.description,
        softWrap: true,
          textAlign: TextAlign.justify,
          style: TextStyle(
              height: 1.2 // the height between text, default is null
          )
      )
    ];

    // print("widget._item.url >>>>>>>${widget._item.url}<<<<<<<<");
    itemData.add(Padding(padding: EdgeInsets.all(5)));
    if(widget._item.imdb!=null && widget._item.imdb!=""){
      itemData.add(Row(children: [
        InkWell(
            child: Container(
                padding: Styles.padding,
                child: Row(children: [
                  Icon(
                    Icons.open_in_browser, // Add this
                  ),
                  Padding(padding: EdgeInsets.all(2)),
                  Text(
                    'IMDB',
                    style: Styles.hiperlink
                        .copyWith(color: Theme.of(context).accentColor),
                  ),
                ])),
            onTap: () => launch("https://www.imdb.com/title/${widget._item.imdb}")
        ),
        Spacer(),
      ]));
    }
    if(widget._item.url!=null && widget._item.url!=""){
      itemData.add(Row(children: [
            InkWell(
                child: Container(
                    padding: Styles.padding,
                    child: Row(children: [
                      Icon(
                        Icons.open_in_browser, // Add this
                      ),
                      Padding(padding: EdgeInsets.all(2)),
                      Text(
                        'More Information',
                        style: Styles.hiperlink
                            .copyWith(color: Theme.of(context).accentColor),
                      ),
                    ])),
                onTap: () => launch(widget._item.url)
            ),
            Spacer(),
          ]));
    }

    return Container(
      padding: Styles.rowPadding, //const EdgeInsets.fromLTRB(35, 15, 35, 15),
      child: Column(children: itemData),
    );
  }

  Widget _imageSection() {
    List<Widget> dataChildren = [];
    var ratio = (MediaQuery.of(context).size.width /
        MediaQuery.of(context).size.height);
    var hImage = MediaQuery.of(context).size.height * ratio;
    //print("ratio I $ratio   $hImage");

    var widgetImg;

    if (widget._item.image != null) {
      widgetImg = Hero(
          tag: "itemImage_" + widget._item.id.toString(),
          child: CachedNetworkImage(
            imageUrl: widget._item.image,
            // width:  MediaQuery.of(context).size.width *0.1,
            height: hImage,
            fit: BoxFit.contain,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                Center(
              child:
                  CircularProgressIndicator(value: downloadProgress.progress),
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ));
      //Image.network(widget._item.image,  width: 600, height: 240, fit: BoxFit.contain);
    } else {
      widgetImg = Image.asset(
        'images/notFound.png',
        width: 600,
        height: 240,
        fit: BoxFit.cover,
      );
    }
    print(
        "------------ Config.LANG_LIST[Config.LANG] ${Config.LANG_LIST[Config.LANG]}");
    dataChildren.add( Center(child: widgetImg));

    //dataChildren.add(langSelection);

    if(widget._item.year != null){
      Widget yearLabel = VisualElements.getYearLabel(widget._item.year, context);
      /*Align(
        alignment: Alignment.topLeft,
        child: Container(
          //margin: EdgeInsets.only(bottom: 10.0),
          child: ClipShadowPath(
            clipper: RibbonClipper(),
            shadow: Shadow(
                blurRadius: 3
            ),
            child: Container(

                color: Theme.of(context).primaryColor,
                //width: 200.0,
                //height: 50.0,
                padding: Styles.rowPadding.copyWith(right: 25),
                //color: Colors.red,
                child: Text(
                  '${widget._item.year}',
                  style: Theme.of(context).primaryTextTheme.bodyText1,
                  softWrap: true,
                )),
          ),
        ),
      );*/
      dataChildren.add(yearLabel);
    }

    return Stack(
      children: dataChildren,
    );
  }

  refresh() async {
    final overlay = LoadingOverlay.of(context);
    overlay.show();
    ItemData item = await _db.item.getById(widget._item.id);
    overlay.hide();
    setState(() {
      widget._item = item;
    });
  }

  Widget _formatsSection() {
    Color backgroundColor = Theme.of(context).cardColor;
    Color foregroundColor = Theme.of(context).accentColor;

    return Container(
        padding: Styles.rowPadding,
        height: 65.0,
        child: Row(
          children: [
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: widget._item.formats.getIcons(),
              ),
            ),
            IconButton(
                icon: Icon(Icons.edit),
                color: foregroundColor,
                onPressed: () {
                  _goToFormatsView();
                  //setState(widget._item.onTapFav);
                }),
            VerticalDivider(
              thickness: 1,
              // color: Theme.of(context).splashColor,
            ),
            Align(
                alignment: Alignment.topRight,
                child: Container(
                    padding: EdgeInsets.fromLTRB(0, 0, Styles.paddingValue, 0),
                    child: DropdownButton<int>(
                        hint: Text(Config.LANG_LIST[widget._item.langId]),
                        value: null,
                        icon: Icon(
                          // Add this
                          Icons.arrow_drop_down, // Add this
                        ),
                        items: _langMenuItems,
                        onChanged: (value) async {
                          //setState(() {
                          Config.LANG = value;
                          print("Config.LANG ${Config.LANG}");
                          await refresh();
                          //});
                        })))
          ],
        )

        /*  IconButton(
              icon: Icon(Icons.edit_attributes),
              color: foregroundColor,
              onPressed: () {
                //_goToFormatsView();
                setState(widget._item.onTapFav);
              }),*/
        );
  }

  _deleteConfirmation() async {
    var confirm = await Popup.confirmation(
        context, Strings.deleteTitle, Strings.deleteText);
    print("confirm $confirm");
    if (confirm == true) {
      await _db.item.delete(widget._item);
      Config.NEEDS_UPDATE = true;
      Navigator.of(context).pop("delete");
    }
  }

  Widget _toolSection() {
    return ListTile(
      title: Text(Strings.deleteButton),
      leading: Icon(Icons.delete_forever, color: Colors.red),
      onTap: _deleteConfirmation,
    );
  }

  Widget buildItemData() {
    return CustomScrollView(slivers: <Widget>[
      SliverList(
          delegate: SliverChildListDelegate([
        _imageSection(),
        _formatsSection(),
        //_textSection(),
        _textSection(),
        //SizedBox(height: Styles.paddingValue * 10)
      ])),
      SliverFillRemaining(
        hasScrollBody: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[SizedBox(height: Styles.paddingValue * 5)],
        ),
      ),
      SliverFooter(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            children: [
              Divider(
                height: 2,
                thickness: 2,
              ),
              _toolSection()
            ],
          ),
        ),
      ),
    ]);
  }

  Widget buildItemData2() {
    return Stack(children: <Widget>[
      // SafeArea(
      // height: MediaQuery.of(context).copyWith().size.height,
      // height: double.infinity,
      //child:  SafeArea(

      Positioned.fill(
          child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            _imageSection(),
            _formatsSection(),
            _textSection(),
            _textSection(),
            Spacer(),
            Divider(),
            _toolSection()
          ])),
    ]);
  }

  _goToFormatsView() async {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new FormatView(widget._item))).then((value) {
      setState(() {
        _db.item.formats.update(widget._item);
        Config.NEEDS_UPDATE = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _db = ConnectionDB();
    _db.start();
    var iconSetup = widget._item.getIcon();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._item.name),
        actions: [
          IconButton(
              icon: iconSetup[0],
              color: iconSetup[1],
              onPressed: () {
                //_goToFormatsView();
                setState(widget._item.onTapFav);
              }),
        ],
      ),
      body: buildItemData(),
    );
  }
}

// https://stackoverflow.com/questions/49620212/listview-with-scrolling-footer-at-the-bottom
class SliverFooter extends SingleChildRenderObjectWidget {
  /// Creates a sliver that fills the remaining space in the viewport.
  const SliverFooter({
    Key key,
    Widget child,
  }) : super(key: key, child: child);

  @override
  RenderSliverFooter createRenderObject(BuildContext context) =>
      new RenderSliverFooter();
}

class RenderSliverFooter extends RenderSliverSingleBoxAdapter {
  /// Creates a [RenderSliver] that wraps a [RenderBox] which is sized to fit
  /// the remaining space in the viewport.
  RenderSliverFooter({
    RenderBox child,
  }) : super(child: child);

  @override
  void performLayout() {
    final extent =
        (constraints.remainingPaintExtent - math.min(constraints.overlap, 0.0));
    var childGrowthSize = .0; // added
    if (child != null) {
      // changed maxExtent from 'extent' to double.infinity
      child.layout(
          constraints.asBoxConstraints(
              minExtent: extent, maxExtent: double.infinity),
          parentUsesSize: true);
      childGrowthSize = (constraints.axis == Axis.vertical
          ? child.size.height
          : child.size.width); // added
    }

    final paintedChildSize =
        calculatePaintOffset(constraints, from: 0.0, to: (extent * 2));
    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);

    //print('fotter $childGrowthSize   $extent  $paintedChildSize');
    geometry = new SliverGeometry(
      // used to be this : scrollExtent: constraints.viewportMainAxisExtent,
      scrollExtent: math.max(extent, childGrowthSize),
      paintExtent: paintedChildSize,
      maxPaintExtent: paintedChildSize,
      hasVisualOverflow: extent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0.0,
    );
    if (child != null) {
      setChildParentData(child, constraints, geometry);
    }
  }
}
