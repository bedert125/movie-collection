import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'conf/styles.dart';

class DialogBox extends StatefulWidget {
  final String title, descriptions, text;
  final String img;
  final Container actions;
  final List<Widget> extraElements;

  const DialogBox({Key key, this.title, this.descriptions, this.text, this.img, this.actions, this.extraElements}) : super(key: key);

  @override
  _DialogBoxState createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  String _image;
  @override
  Widget build(BuildContext context) {
    _image = widget.img == null ? "images/logo.png" :widget.img;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Styles.paddingValue),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _contentBox(context),
    );
  }

  _getActions(){
    var actions;
    if(widget.actions == null){
      actions = FlatButton(
          onPressed: (){
            Navigator.of(context).pop();
          },
          child: Text(widget.text,style: TextStyle(fontSize: 18),));
    }else{
      actions = widget.actions;
    }
    return actions;
  }

  _getImage(){
    var wImage;
    if(_image == ""){

    }else{
      wImage = Positioned(
        left: Styles.paddingValue,
        right: Styles.paddingValue,
        child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: Styles.imageDialogRadiusValue,
          child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(Styles.imageDialogRadiusValue)),
              child: Image.asset(_image)
          ),
        ),
      );
    }
    return wImage;
  }

  _getElementsToShow(){
    var elements = <Widget>[
      Text(widget.title,style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
      SizedBox(height: 15,),
      Text(widget.descriptions,style: Styles.itemText,textAlign: TextAlign.center,),
    ];
    if(widget.extraElements != null) {
      SizedBox(height: 22,);
      elements.addAll(widget.extraElements);
    }

    elements.addAll([
      SizedBox(height: 22,),
      Align(
        alignment: Alignment.bottomRight,
        child: _getActions(),
      ),
    ]);

    return elements;
  }

  _contentBox(context){
    var wList = <Widget>[];
    var wimage = _getImage();
    var paddingTop = wimage== null? Styles.paddingValue: Styles.imageDialogRadiusValue
        + Styles.paddingValue;
    var content = Container(
      padding: EdgeInsets.only(left: Styles.paddingValue,top: paddingTop, right: Styles.paddingValue,bottom: Styles.paddingValue
      ),
      margin: EdgeInsets.only(top: Styles.imageDialogRadiusValue),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(Styles.paddingValue),
          boxShadow: [Styles.boxShadow]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _getElementsToShow(),
      ),
    );

    wList.add(content);

    if(wimage != null) wList.add(wimage);

    return Stack(
      children: wList,
    );
  }
}