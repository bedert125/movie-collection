import 'package:flutter/material.dart';

import 'collection_database.dart';
import 'main.dart';
import 'conf/strings.dart';
import 'conf/styles.dart';

class SplashApp extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashApp({
    Key key,
    @required this.onInitializationComplete,
  }) : super(key: key);

  @override
  _SplashAppState createState() => _SplashAppState();
}

class _SplashAppState extends State<SplashApp> {
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeAsyncDependencies();
  }

  Future<void> _initializeAsyncDependencies() async {
    var _db = ConnectionDB();
    await _db.start();
    // >>> initialize async dependencies <<<
    // >>> register favorite dependency manager <<<
    // >>> reap benefits <<<
    Future.delayed(
      Duration(milliseconds: 1500),
          () => widget.onInitializationComplete(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appName,
      theme: ThemeData(
        primarySwatch: Styles.primarySwatch,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return Center(
        child: RaisedButton(
          child: Text('retry'),
          onPressed: () => main(),
        ),
      );
    }
    return Container(
      padding: Styles.padding,
      child:Column(
        children: [
          Text(Strings.appName),
          CircularProgressIndicator()
        ],
      ) ,
    );
  }
}