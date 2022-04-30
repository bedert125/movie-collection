import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movie_collection/utils/visualElements.dart';

import 'collection_common_view.dart';
import 'collection_database.dart';
import 'conf/config.dart';
import 'conf/styles.dart';
import 'item_data.dart';

class CollectionCardView extends CollectionView {
  /* CollectionCardView({toReset}) {
    toReset = toReset ?? false;
    Config.NEEDS_UPDATE = toReset;
    print("restarting ${toReset}");
    // this.toReset = toReset;
    //print("restarting ${this.toReset}");
  }

   */

  @override
  getState() {
    return _CollectionCardViewState();
  }
}

class _CollectionCardViewState extends CollectionViewState {

  var borderColor = Colors.blueGrey;
  Radius roundBorder =  Radius.circular(10);


  @override
  Widget buildCollectionList() {
    return GridView.builder(
        primary: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, //(orientation == Orientation.portrait) ? 2 : 3,
          childAspectRatio: 2 / 3,
        ),
        itemCount: itemList.length,
        itemBuilder: (BuildContext context, int index) {
          if (itemList.length == index) {
            return Container();
          } else {
            return _buildCard(itemList[index], index);
          }
        });
  }

  Widget _getIcons(item) {
    List<Widget> icons = [];

    icons.add(
        Container(
          decoration: BoxDecoration(
            /* gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [ Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.8),
                Colors.white.withOpacity(1),
              ],
            ),

             */
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.only( bottomLeft: roundBorder),
            border: Border.all(width: 1,  color: borderColor)

          ),
          padding: EdgeInsets.fromLTRB(10, Styles.paddingValue/5,0, Styles.paddingValue/5),

          child: Column(
            children: item.formats.getIcons(size: "s"),
          ),
        )
    );

    icons.add(Spacer());
    return Column(children: icons);
  }

  Card _buildCard(ItemData item, int pos) {
    print("card ${item.name}");
    return Card(
        borderOnForeground: true,
        //margin: Styles.padding * 0.5,
        elevation: 3,
        /*shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),

         */
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(roundBorder),
            side: BorderSide(
                width: 1,
                color: borderColor) //color: Theme.of(context).accentColor)
            ),
        clipBehavior: Clip.antiAlias,
        child: ClipRRect(
            borderRadius: BorderRadius.all(roundBorder),
            child: Stack(
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              //mainAxisSize: MainAxisSize.min,
              //verticalDirection: VerticalDirection.down,
              children: <Widget>[
                Positioned.fill(
                    child: Center(
                        child: Hero(
                          tag: "itemImage_"+item.id.toString(),
                        child: CachedNetworkImage(
                  width: double.infinity,
                  height: double.infinity,
                  imageUrl: item.image,
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Center(
                    child: CircularProgressIndicator(
                        value: downloadProgress.progress),
                  ),
                  errorWidget: (context, url, error) =>
                      Image.asset('images/logo.png'),
                )))
                ),
                Align(
                    alignment: Alignment.topRight,
                    child: Container(
                        child: _getIcons(item))
                ),
                Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                        child: VisualElements.getYearLabel(item.year, context))
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(0.5),
                            Theme.of(context).primaryColor.withOpacity(0.8),
                          ],
                        ),
                        //color: Theme.of(context).primaryColor.withOpacity(0.8),
                        //Colors.white.withOpacity(0.8),
                        /*borderRadius: BorderRadius.only(
                          topRight: roundedPanelValue,
                          topLeft: roundedPanelValue),

                       */
                        //border: Border.all(width: 1,  color: Theme.of(context).accentColor)
                      ),
                      padding: Styles.rowPadding,
                      //child: Column(
                      //mainAxisSize: MainAxisSize.min,
                      //crossAxisAlignment: CrossAxisAlignment.stretch,
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      //children: <Widget>[
                      //Text((pos + 1).toString(), style: Styles.itemText,),
                      child: Text(item.name,
                          textAlign: TextAlign.center,
                          style: Styles.itemText.copyWith(
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .bodyText1
                                  .color)),
                      //],
                      //)
                    )),
                Positioned.fill(
                    child: Material(
                        color: Colors.transparent,
                        child: new InkWell(
                          onTap: () {
                            goToItemViewById(item.id);
                          },
                        ))),
              ],
            )));
  }
}
