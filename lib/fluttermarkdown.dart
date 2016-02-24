import 'package:markdown/markdown.dart' as md;
import 'package:flutter/material.dart';

class MarkdownStyle {

  MarkdownStyle({
    this.a,
    this.p,
    this.code,
    this.h1,
    this.h2,
    this.h3,
    this.h4,
    this.h5,
    this.h6,
    this.em,
    this.strong,
    this.blockquote,
    this.blockSpacing,
    this.listIndent
  }) {
    _init();
  }

  MarkdownStyle.defaultFromTheme(ThemeData theme) :
    a = new TextStyle(color: Colors.blue[500]),
    p = theme.text.body1,
    code = new TextStyle(color: Colors.purple[500]),
    h1 = theme.text.headline,
    h2 = theme.text.title,
    h3 = theme.text.subhead,
    h4 = theme.text.body2,
    h5 = theme.text.body2,
    h6 = theme.text.body2,
    em = new TextStyle(fontStyle: FontStyle.italic),
    strong = new TextStyle(fontWeight: FontWeight.bold),
    blockquote = theme.text.body1,
    blockSpacing = 8.0,
    listIndent = 32.0 {
    _init();
  }

  MarkdownStyle.largeFromTheme(ThemeData theme) :
    a = new TextStyle(color: Colors.blue[500]),
    p = theme.text.body1,
    code = new TextStyle(color: Colors.purple[500]),
    h1 = theme.text.display3,
    h2 = theme.text.display2,
    h3 = theme.text.display1,
    h4 = theme.text.headline,
    h5 = theme.text.title,
    h6 = theme.text.subhead,
    em = new TextStyle(fontStyle: FontStyle.italic),
    strong = new TextStyle(fontWeight: FontWeight.bold),
    blockquote = theme.text.body1,
    blockSpacing = 8.0,
    listIndent = 32.0 {
    _init();
  }

  MarkdownStyle copyWith({
    TextStyle a,
    TextStyle p,
    TextStyle code,
    TextStyle h1,
    TextStyle h2,
    TextStyle h3,
    TextStyle h4,
    TextStyle h5,
    TextStyle h6,
    TextStyle em,
    TextStyle strong,
    TextStyle blockquote,
    double blockSpacing,
    double listIndent
  }) {
    return new MarkdownStyle(
      a: a != null ? a : this.a,
      p: p != null ? p : this.p,
      code: code != null ? code : this.code,
      h1: h1 != null ? h1 : this.h1,
      h2: h2 != null ? h2 : this.h2,
      h3: h3 != null ? h3 : this.h3,
      h4: h4 != null ? h4 : this.h4,
      h5: h5 != null ? h5 : this.h5,
      h6: h6 != null ? h6 : this.h6,
      em: em != null ? em : this.em,
      strong: strong != null ? strong : this.strong,
      blockquote: blockquote != null ? blockquote : this.blockquote,
      blockSpacing: blockSpacing != null ? blockSpacing : this.blockSpacing,
      listIndent: listIndent != null ? listIndent : this.listIndent
    );
  }

  final TextStyle a;
  final TextStyle p;
  final TextStyle code;
  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle h4;
  final TextStyle h5;
  final TextStyle h6;
  final TextStyle em;
  final TextStyle strong;
  final TextStyle blockquote;
  final double blockSpacing;
  final double listIndent;

  Map<String, TextStyle> _styles;

  void _init() {
    _styles = {
      'a': a,
      'p': p,
      'li': p,
      'code': code,
      'pre': p,
      'h1': h1,
      'h2': h2,
      'h3': h3,
      'h4': h4,
      'h5': h5,
      'h6': h6,
      'em': em,
      'strong': strong,
      'blockquote': blockquote
    };
  }
}

class Markdown extends StatefulComponent {
  Markdown({
    this.data,
    this.markdownStyle
  });

  final String data;
  final MarkdownStyle markdownStyle;

  State<Markdown> createState() => new _MarkdownState();
}

class _MarkdownState extends State<Markdown> {

  void initState() {
    super.initState();

    MarkdownStyle style = config.markdownStyle;
    if (style == null)
      style = new MarkdownStyle.defaultFromTheme(Theme.of(context));

    _cachedBlocks = _blocksFromMarkup(config.data, style);
  }

  List<_Block> _cachedBlocks;

  Widget build(BuildContext context) {
    List<Widget> blocks = <Widget>[];
    for (_Block block in _cachedBlocks) {
      blocks.add(block.build(context));
    }

    return new Column(
      alignItems: FlexAlignItems.stretch,
      children: blocks
    );
  }
}

List<_Block> _blocksFromMarkup(String data, MarkdownStyle markdownStyle) {
  var lines = data.replaceAll('\r\n', '\n').split('\n');
  md.Document document = new md.Document();

  _Renderer renderer = new _Renderer();
  return renderer.render(document.parseLines(lines), markdownStyle);
}

class _Renderer implements md.NodeVisitor {
  List<_Block> render(List<md.Node> nodes, MarkdownStyle markdownStyle) {
    assert(markdownStyle != null);

    _blocks = <_Block>[];
    _listIndents = <String>[];
    _markdownStyle = markdownStyle;

    for (final md.Node node in nodes) {
      node.accept(this);
    }

    return _blocks;
  }

  List<_Block> _blocks;
  List<String> _listIndents;
  MarkdownStyle _markdownStyle;

  void visitText(md.Text text) {
    List<dynamic> top = _currentBlock.stack.last;
    top.add(text.text);
  }

  bool visitElementBefore(md.Element element) {
    if (_isListTag(element.tag))
      _listIndents.add(element.tag);

    if (_isBlockTag(element.tag)) {
      List<_Block> blockList;
      if (_currentBlock == null)
        blockList = _blocks;
      else
        blockList = _currentBlock.subBlocks;

      _Block newBlock = new _Block(element.tag, element.attributes, _markdownStyle, new List<String>.from(_listIndents), blockList.length);
      blockList.add(newBlock);
    } else {
      TextStyle style = _markdownStyle._styles[element.tag];
      if (style == null)
        style = new TextStyle();

      List<dynamic> styleElement = <dynamic>[style];
      _currentBlock.stack.add(styleElement);
    }
    return true;
  }

  void visitElementAfter(md.Element element) {
    if (_isListTag(element.tag))
      _listIndents.removeLast();

    if (_isBlockTag(element.tag)) {
      if (_currentBlock.stack.length > 0) {
        _currentBlock.stack = _currentBlock.stack.first;
        _currentBlock.open = false;
      } else {
        _currentBlock.stack = <dynamic>[''];
      }
    } else {
      if (_currentBlock.stack.length > 1) {
        List<dynamic> popped = _currentBlock.stack.last;
        _currentBlock.stack.removeLast();

        List<dynamic> top = _currentBlock.stack.last;
        top.add(popped);
      }
    }
  }

  static const List<String> _kBlockTags = const <String>['p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'li', 'blockquote', 'img', 'pre', 'ol', 'ul'];
  static const List<String> _kListTags = const <String>['ul', 'ol'];

  bool _isBlockTag(String tag) {
    return _kBlockTags.contains(tag);
  }

  bool _isListTag(String tag) {
    return _kListTags.contains(tag);
  }

  _Block get _currentBlock => _currentBlockInList(_blocks);

  _Block _currentBlockInList(List<_Block> blocks) {
    if (blocks.length == 0)
      return null;

    if (!blocks.last.open)
      return null;

    _Block childBlock = _currentBlockInList(blocks.last.subBlocks);
    if (childBlock != null)
      return childBlock;

    return blocks.last;
  }
}

class _Block {
  _Block(this.tag, this.attributes, this.markdownStyle, this.listIndents, this.blockPosition) {
    TextStyle style = markdownStyle._styles[tag];
    if (style == null)
      style = new TextStyle(color: Colors.red[500]);

    stack = <dynamic>[<dynamic>[style]];
    subBlocks = <_Block>[];
  }

  final String tag;
  final Map<String, String> attributes;
  final MarkdownStyle markdownStyle;
  final List<String> listIndents;
  final int blockPosition;

  List<dynamic> stack;
  List<_Block> subBlocks;

  bool get open => _open;
  void set open(bool open) {
    _open = open;
    if (!open && subBlocks.length > 0)
      subBlocks.last.last = true;
  }

  bool _open = true;
  bool last = false;

  Widget build(BuildContext context) {

    if (tag == 'img') {
      return new NetworkImage(src: attributes['src'], width: 200.0, height: 200.0);
    }

    double spacing = markdownStyle.blockSpacing;
    if (last) spacing = 0.0;

    Widget contents;
    BoxDecoration decoration;
    EdgeDims padding;

    if (tag == 'blockquote') {
      decoration = new BoxDecoration(
        backgroundColor: Colors.blue[100],
        borderRadius: 2.0
      );
      padding = new EdgeDims.all(8.0);
    } else if (tag == 'pre') {
      decoration = new BoxDecoration(
        backgroundColor: Colors.grey[100],
        borderRadius: 2.0
      );
      padding = new EdgeDims.all(8.0);
    }

    if (subBlocks.length > 0) {
      List<Widget> subWidgets = <Widget>[];
      for (_Block subBlock in subBlocks) {
        subWidgets.add(subBlock.build(context));
      }

      contents = new Column(
        alignItems: FlexAlignItems.stretch,
        children: subWidgets
      );
    } else {
      contents = new StyledText(elements: stack);

      if (listIndents.length > 0) {
        Widget bullet;
        if (listIndents.last == 'ul') {
          bullet = new Text(
            '•',
            style: new TextStyle(textAlign: TextAlign.center)
          );
        }
        else {
          bullet = new Padding(
            padding: new EdgeDims.only(right: 5.0),
            child: new Text(
              "${blockPosition + 1}.",
              style: new TextStyle(textAlign: TextAlign.right)
            )
          );
        }

        contents = new Row(
          alignItems: FlexAlignItems.start,
          children: <Widget>[
            new SizedBox(
              width: listIndents.length * markdownStyle.listIndent,
              child: bullet
            ),
            new Flexible(child: contents)
          ]
        );
      }
    }

    return new Container(
      padding: padding,
      margin: new EdgeDims.only(bottom: spacing),
      child: contents,
      decoration: decoration
    );
  }
}
