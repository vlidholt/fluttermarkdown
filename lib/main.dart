import 'package:flutter/material.dart';
import 'fluttermarkdown.dart';
import 'syntax_highlighter.dart';

void main() {

new SyntaxHighlighter('PublicClass ^%|/~_PrivateClass variable class classic _privateVar kConstant kowabunga _kConstant').readFile();

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
        center: new Text("Markdown Demo")
      ),
      body: new Material(
        child: new Block(
          padding: new EdgeDims.all(16.0),
          children: <Widget>[new Markdown(data: data)])
      )
    );
  }
}
