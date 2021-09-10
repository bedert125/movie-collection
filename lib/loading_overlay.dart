 import 'package:flutter/material.dart';

class LoadingOverlay {
  BuildContext _context;
  bool isDisplayed = false;
  void hide() {
    if(isDisplayed) {
      isDisplayed= false;
      Navigator.of(_context).pop();
    }
  }

  void show() {
    isDisplayed = true;
    showDialog(
        context: _context,
        barrierDismissible: false,
        builder: (_) => _containerBuilder());
  }

  Widget _containerBuilder(){
    return Container(
        decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.5)),
        child: Center(child: CircularProgressIndicator()));
  }

  Future<T> during<T>(Future<T> future) {
    show();
    return future.whenComplete(() => hide());
  }

  LoadingOverlay._create(this._context);

  factory LoadingOverlay.of(BuildContext context) {
    return LoadingOverlay._create(context);
  }
}

class _FullScreenLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.5)),
        child: Center(child: CircularProgressIndicator()));
  }
}
