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

  void initState() {
    super.initState();

    DefaultAssetBundle.of(context).loadString('assets/example.md').then((String data) {
      setState(() {
        this.data = data;
      });
    });
  }

  String data;

  Widget build(BuildContext context) {
    if (data == null) {
      return new Scaffold(
        toolBar: new ToolBar(
          center: new Text("Markdown Demo")
        )
      );
    }

    return new Scaffold(
      toolBar: new ToolBar(
        center: new Text("Flutter Demo")
      ),
      body: new Material(
        child: new Block(
          children: <Widget>[new Markdown(data: data)])
      )
    );
  }
}
