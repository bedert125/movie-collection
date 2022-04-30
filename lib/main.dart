
import 'package:flutter/material.dart';

import 'home_view.dart';
import 'splash_screen.dart';
import 'conf/strings.dart';
import 'conf/styles.dart';

/*
void main() {

  WidgetsFlutterBinding.ensureInitialized();

    runApp(
      SplashApp(
        key: UniqueKey(),
        onInitializationComplete: () => runMainApp(),
      ),
    );

}

void runMainApp() {
  runApp(CollectionApp());
}

*/

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CollectionApp());
}


class CollectionApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Strings.appName,
      theme: ThemeData(
        primarySwatch: Styles.primarySwatch,
        visualDensity: VisualDensity.adaptivePlatformDensity,
         /* buttonTheme: ButtonThemeData(
            buttonColor: Colors.deepPurple,     //  <-- dark color
            textTheme: ButtonTextTheme.normal, //  <-- this auto selects the right color
          )*/
      ),
      home: new SplashScreen(),
      routes: <String, WidgetBuilder>{
        '/HomeScreen': (BuildContext context) => HomeView()

        //new CollectionListView()
      },
    );
  }
}
