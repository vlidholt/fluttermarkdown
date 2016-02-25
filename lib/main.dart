import 'dart:async';

import 'package:flutter/material.dart';
import 'fluttermarkdown.dart';
import 'syntax_highlighter.dart';

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

  Future load() async {
    data = await DefaultAssetBundle.of(context).loadString('assets/example.md');
    code = await DefaultAssetBundle.of(context).loadString('lib/main.dart');

    formattedText = new SyntaxHighlighter('/* Testing a code example */\nclass Foo {\n  // Comment\n  foo = new Monkey();\n}').format();
    formattedText = new SyntaxHighlighter(code).format();
  }

  void initState() {
    super.initState();

    load().then((_) {
      setState(() {
        loaded = true;
      });
    });
  }

  String data;
  String code;
  List<dynamic> formattedText;
  bool loaded = false;

  Widget build(BuildContext context) {
    if (!loaded) {
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
          // children: <Widget>[new Markdown(data: data)])
          children: <Widget>[new StyledText(elements: formattedText)])
      )
    );
  }
}
