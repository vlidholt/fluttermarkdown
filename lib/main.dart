import 'package:flutter/material.dart';
import 'fluttermarkdown.dart';

void main() {
  runApp(
    new MaterialApp(
      title: "Flutter Demo",
      routes: <String, RouteBuilder>{
        '/': (RouteArguments args) => new FlutterDemo()
      }
    )
  );
}

class FlutterDemo extends StatefulComponent {
  @override
  State createState() => new FlutterDemoState();
}

class FlutterDemoState extends State {



  Widget build(BuildContext context) {
    return new Scaffold(
      toolBar: new ToolBar(
        center: new Text("Flutter Demo")
      ),
      body: new Material(
        child: new Center(
          // child: new Markdown(data: "Testing *italic* font __bold__ fanciness. *Italic text with __bold__ embedded!* Some normal text at the end.\nSecond line.\nThird line.\n\nSecond paragraph"))
          child: new Markdown(data: "One\n\nTwo\n\nThree"))
      )
    );
  }
}
