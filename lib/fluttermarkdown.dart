import 'package:markdown/markdown.dart' as md;
import 'package:flutter/material.dart';

class MarkdownStyle {

  MarkdownStyle({
    this.p,
    this.h1,
    this.h2,
    this.h3,
    this.h4,
    this.h5,
    this.h6,
    this.em,
    this.strong
  }) {
    _init();
  }

  MarkdownStyle.fromTheme(ThemeData theme) :
    p = theme.text.body1,
    h1 = theme.text.display3,
    h2 = theme.text.display2,
    h3 = theme.text.display1,
    h4 = theme.text.headline,
    h5 = theme.text.title,
    h6 = theme.text.subhead,
    em = new TextStyle(fontStyle: FontStyle.italic),
    strong = new TextStyle(fontWeight: FontWeight.bold) {
    _init();
  }

  MarkdownStyle copyWith({
    TextStyle p,
    TextStyle h1,
    TextStyle h2,
    TextStyle h3,
    TextStyle h4,
    TextStyle h5,
    TextStyle h6,
    TextStyle em,
    TextStyle strong
  }) {
    return new MarkdownStyle(
      p: p != null ? p : this.p,
      h1: h1 != null ? h1 : this.h1,
      h2: h2 != null ? h2 : this.h2,
      h3: h3 != null ? h3 : this.h3,
      h4: h4 != null ? h4 : this.h4,
      h5: h5 != null ? h5 : this.h5,
      h6: h6 != null ? h6 : this.h6,
      em: em != null ? em : this.em,
      strong: strong != null ? strong : this.strong
    );
  }

  final TextStyle p;
  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle h4;
  final TextStyle h5;
  final TextStyle h6;
  final TextStyle em;
  final TextStyle strong;

  Map<String, TextStyle> _styles;

  void _init() {
    _styles = {
      'p': p,
      'li': p,
      'h1': h1,
      'h2': h2,
      'h3': h3,
      'h4': h4,
      'h5': h5,
      'h6': h6,
      'em': em,
      'strong': strong
    };
  }
}

class Markdown extends StatefulComponent {
  Markdown({
    this.data,
    this.style
  });

  final String data;
  final MarkdownStyle style;

  State<Markdown> createState() => new _MarkdownState();
}

class _MarkdownState extends State<Markdown> {

  void initState() {
    super.initState();

    MarkdownStyle style = config.style;
    if (style == null)
      style = new MarkdownStyle.fromTheme(Theme.of(context));

    _cachedBlocks = _blocksFromMarkup(config.data, style);
  }

  List<_Block> _cachedBlocks;

  Widget build(BuildContext context) {
    List<Widget> blocks = <Widget>[];
    for (_Block block in _cachedBlocks) {
      blocks.add(block.build(context));
    }

    return new Column(
      alignItems: FlexAlignItems.start,
      children: blocks
    );
  }
}

List<_Block> _blocksFromMarkup(String data, MarkdownStyle styles) {
  var lines = data.replaceAll('\r\n', '\n').split('\n');
  md.Document document = new md.Document();

  _Renderer renderer = new _Renderer();
  return renderer.render(document.parseLines(lines), styles);
}

class _Renderer implements md.NodeVisitor {
  List<_Block> render(List<md.Node> nodes, MarkdownStyle styles) {
    assert(styles != null);

    _blocks = <_Block>[];
    _listIndents = <String>[];
    _styles = styles;

    for (final md.Node node in nodes) {
      node.accept(this);
    }

    print("blocks: $_blocks");
    return _blocks;
  }

  List<_Block> _blocks;
  List<String> _listIndents;
  MarkdownStyle _styles;

  void visitText(md.Text text) {
    print("visitText: ${text.text}");

    // Add text to topmost list on the stack
    List<dynamic> top = _currentBlock.stack.last;
    top.add(text.text);
  }

  bool visitElementBefore(md.Element element) {
    if (_isBlockTag(element.tag)) {
      _blocks.add(new _Block(element.tag, _styles, new List<String>.from(_listIndents)));
    } else if (_isListTag(element.tag)) {
      _listIndents.add(element.tag);
    } else {
      // Add a new element, that contains the tag's style, to the stack
      TextStyle style = _styles._styles[element.tag];
      if (style == null)
        style = new TextStyle();

      List<dynamic> styleElement = <dynamic>[style];
      _currentBlock.stack.add(styleElement);
    }

    print("visitElementBefore: tag: ${element.tag}");


    return true;
  }

  void visitElementAfter(md.Element element) {
    print("visitElementAfter: tag: ${element.tag}");

    if (_isBlockTag(element.tag)) {
      if (_currentBlock.stack.length > 0)
        _currentBlock.stack = _currentBlock.stack.first;
      else
        _currentBlock.stack = <dynamic>[""];
    } else if (_isListTag(element.tag)) {
      _listIndents.removeLast();
    } else {
      if (_currentBlock.stack.length > 1) {
        List<dynamic> popped = _currentBlock.stack.last;
        _currentBlock.stack.removeLast();

        List<dynamic> top = _currentBlock.stack.last;
        top.add(popped);
      }
    }
  }

  bool _isBlockTag(String tag) {
    return <String>["p", "h1", "h2", "h3", "h4", "h5", "h6", "li"].contains(tag);
  }

  bool _isListTag(String tag) {
    return <String>["ul", "ol"].contains(tag);
  }

  _Block get _currentBlock => _blocks.last;
}

class _Block {
  _Block(this.tag, this.styles, this.listIndents) {
    TextStyle style = styles._styles[tag];
    if (style == null)
      style = new TextStyle(color: Colors.red[500]);

    stack = <dynamic>[<dynamic>[style]];
  }

  final String tag;
  final MarkdownStyle styles;
  final List<String> listIndents;
  List<dynamic> stack;

  Widget build(BuildContext context) {
    Widget contents = new StyledText(elements: stack);
    if (listIndents.length > 0) {
      contents = new Row(
        children: <Widget>[
          new SizedBox(
            width: listIndents.length * 16.0,
            child: new Text("•")
          ),
          contents
        ]
      );
    }

    return new Container(
      margin: new EdgeDims.only(bottom: 8.0),
      child: contents
    );
  }

  String toString() {
    return "<$tag | $stack>";
  }
}
