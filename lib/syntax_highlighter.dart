import 'package:string_scanner/string_scanner.dart';

class SyntaxHighlighter {
  SyntaxHighlighter(this.src) {
    _scanner = new StringScanner(src);
    _spans = <_HighlightSpan>[];
  }

  final String src;
  StringScanner _scanner;

  List<_HighlightSpan> _spans;

  void readFile() {
    int lastLoopPosition = _scanner.position;

    while(!_scanner.isDone) {
      // Skip White space
      _scanner.scan(new RegExp(r"\s+"));

      // Block comments
      if (_scanner.scan(new RegExp(r"/\*(.|\n)*\*/"))) {
        _spans.add(new _HighlightSpan(
          _HighlightType.comment,
          _scanner.lastMatch.start,
          _scanner.lastMatch.end
        ));

        print("Scanned block comment: ${_scanner.lastMatch[0]}");
      }

      // Line comments
      if (_scanner.scan("//")) {
        print("Scanned start comment: ${_scanner.lastMatch[0]}");
        int startComment = _scanner.lastMatch.start;

        bool eof = false;
        int endComment;
        if (_scanner.scan(new RegExp(r".*\n"))) {
          print("Scanned end comment: ${_scanner.lastMatch[0]}");
          endComment = _scanner.lastMatch.end - 1;
        } else {
          eof = true;
          endComment = src.length;
        }

        _spans.add(new _HighlightSpan(
          _HighlightType.comment,
          startComment,
          endComment
        ));

        if (eof)
          break;

        continue;
      }

      // Multiline """String"""
      if (_scanner.scan(new RegExp(r'"""(?:[^"\\]|\\(.|\n))*"""'))) {
        print("Scanned string: ${_scanner.lastMatch[0]}");
        _spans.add(new _HighlightSpan(
          _HighlightType.string,
          _scanner.lastMatch.start,
          _scanner.lastMatch.end
        ));
        continue;
      }

      // Multiline '''String'''
      if (_scanner.scan(new RegExp(r"'''(?:[^'\\]|\\(.|\n))*'''"))) {
        print("Scanned string: ${_scanner.lastMatch[0]}");
        _spans.add(new _HighlightSpan(
          _HighlightType.string,
          _scanner.lastMatch.start,
          _scanner.lastMatch.end
        ));
        continue;
      }

      // "String"
      if (_scanner.scan(new RegExp(r'"(?:[^"\\]|\\.)*"'))) {
        print("Scanned string: ${_scanner.lastMatch[0]}");
        _spans.add(new _HighlightSpan(
          _HighlightType.string,
          _scanner.lastMatch.start,
          _scanner.lastMatch.end
        ));
        continue;
      }

      // 'String'
      if (_scanner.scan(new RegExp(r"'(?:[^'\\]|\\.)*'"))) {
        print("Scanned string: ${_scanner.lastMatch[0]}");
        _spans.add(new _HighlightSpan(
          _HighlightType.string,
          _scanner.lastMatch.start,
          _scanner.lastMatch.end
        ));
        continue;
      }

      // Double
      if (_scanner.scan(new RegExp(r"\d+\.\d+"))) {
        _spans.add(new _HighlightSpan(
          _HighlightType.number,
          _scanner.lastMatch.start,
          _scanner.lastMatch.end
        ));
        print("Scanned double: ${_scanner.lastMatch[0]}");
        continue;
      }

      // Integer
      if (_scanner.scan(new RegExp(r"\d+"))) {
        _spans.add(new _HighlightSpan(
          _HighlightType.number,
          _scanner.lastMatch.start,
          _scanner.lastMatch.end)
        );
        print("Scanned int: ${_scanner.lastMatch[0]}");
        continue;
      }

      // Keywords
      if (_scanner.scan(new RegExp(r"abstract|as|assert|async|await|break|case|catch|class|const|continue|default|deferred|do|dynamic|else|enum|export|external|extends|factory|false|final|finally|for|get|if|implements|import|in|is|library|new|null|operator|part|rethrow|return|set|static|super|switch|sync|this|throw|true|try|typedef|var|void|while|with|yield"))) {
        _spans.add(new _HighlightSpan(
          _HighlightType.keyword,
          _scanner.lastMatch.start,
          _scanner.lastMatch.end
        ));
        print("Scanned keyword: ${_scanner.lastMatch[0]}");
        continue;
      }

      // Punctuation
      if (_scanner.scan(new RegExp(r"[\[\]{}().!=<>&\|\?\+\-\*/%\^~;:]"))) {
        _spans.add(new _HighlightSpan(
          _HighlightType.punctuation,
          _scanner.lastMatch.start,
          _scanner.lastMatch.end
        ));
        print("Scanned punctuation: ${_scanner.lastMatch[0]}");
        continue;
      }

      // Words
      if (_scanner.scan(new RegExp(r"\w+"))) {
        print("Scanned word: ${_scanner.lastMatch[0]}");
        _HighlightType type;

        String word = _scanner.lastMatch[0];
        if (word.startsWith("_"))
          word = word.substring(1);

        if (_firstLetterIsUpperCase(word))
          type = _HighlightType.klass;
        else if (word.length >= 2 && word.startsWith("k") && _firstLetterIsUpperCase(word.substring(1)))
          type = _HighlightType.constant;

        if (type != null) {
          _spans.add(new _HighlightSpan(
            type,
            _scanner.lastMatch.start,
            _scanner.lastMatch.end
          ));
        }
      }

      // Check if this loop did anything
      if (lastLoopPosition == _scanner.position) {
        print("Failed to parse more");
        break;
      }
      lastLoopPosition = _scanner.position;
    }

    for (_HighlightSpan span in _spans) {
      print(span.textForSpan(src));
    }
  }

  bool _firstLetterIsUpperCase(String str) {
    if (str.length > 0) {
      String first = str.substring(0, 1);
      return first == first.toUpperCase();
    }
    return false;
  }
}

enum _HighlightType {
  number,
  comment,
  keyword,
  string,
  punctuation,
  klass,
  constant
}

class _HighlightSpan {
  _HighlightSpan(this.type, this.start, this.end);
  final _HighlightType type;
  final int start;
  final int end;

  String textForSpan(String src) {
    return "$type: ${src.substring(start, end)}";
  }
}
