import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movie_collection/dialog_box.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'collection_database.dart';
import 'conf/config.dart';
import 'conf/strings.dart';
import 'conf/styles.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime() async {
    //var _duration = new Duration(seconds: 2);
    //return new Timer(_duration, navigationPage);
    var _db = ConnectionDB();
    await _db.start();
    final prefs = await SharedPreferences.getInstance();
    Config.setLocalPreferences(prefs);
    await Future.delayed(Duration(milliseconds: 1000));
    navigationPage();
  }

  void navigationPage() {
    Navigator.of(context).pushReplacementNamed('/HomeScreen');
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Center(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 25,178,238),
                      Color.fromARGB(255, 21,236,229)
                    ],
                  )),

              child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Text(Strings.appName, style: Styles.itemText),
            Container(
                width: 300,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  //fit: StackFit.expand,
                  children: <Widget>[
                    Image.asset('images/logo.png'),
                    Positioned(
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ))
          ]),
    )));
  }
}
