import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PageConnection extends StatelessWidget {
  const PageConnection({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LinearProgressIndicator(backgroundColor: Colors.black),
            Text("Checking Internet Connection"),
          ],
        ),
      ),
    );
  }
}
