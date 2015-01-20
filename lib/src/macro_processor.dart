part of preprocessor;

class MacroProcessor {
  List<TextBlock> process(String source, Map<String, String> environment, {bool expand: true}) {
    var processor = new _MacroProcessor();
    return processor.process(source, environment: environment, expand: expand);
  }
}

class _MacroProcessor extends GeneralVisitor {
  List<TextBlock> _blocks;

  Map<String, List<SourceFragment>> _definitions;

  Map<String, dynamic> _environment;

  bool _expand;

  String _source;

  List<TextBlock> process(String source, {Map<String, String> environment, bool expand: true}) {
    if (source == null) {
      throw new ArgumentError.notNull("source");
    }

    if (expand == null) {
      throw new ArgumentError.notNull("expand");
    }

    _expand = expand;
    _source = source;
    var parser = new Parser();
    var file = parser.parsePreprocessingFile(source);
    _definitions = <String, dynamic>{};
    if (environment != null) {
      for (var key in environment.keys) {
        var value = environment[key];
        if (value is! String) {
          throw new ArgumentError("Illegal type of environment variable '$key': ${value.runtimeType}");
        }

        // TODO: Parse source fragments
        _definitions[key] = [new SourceFragment(position: 0, text: value)];
      }
    }

    file.accept(this);
    var length = _blocks.length;
    if (length <= 1) {
      return _blocks;
    }

    var prev = _blocks.first;
    var end = prev.length;
    var start = 0;
    var result = <TextBlock>[prev];
    for (var i = 1; i < length; i++) {
      var block = _blocks[i];
      if (end == block.position) {
        var newBlock = new TextBlock(prev.text + block.text, start);
        result[result.length - 1] = newBlock;
        end += block.length;
        prev = newBlock;
      } else {
        start = block.position;
        end = start + block.length;
        result.add(block);
        prev = block;
      }
    }

    return result;
  }

  Object visitDefineDirective(DefineDirective node) {
    var key = node.identifier.name;
    _definitions[key] = node.replacement;
    return null;
  }

  Object visitErrorDirective(ErrorDirective node) {
    try {
      throw new FormatException(node.message, _source, node.position);
    } on FormatException catch (e) {
      var message = e.toString().replaceFirst("FormatException: ", "");
      throw new StateError(message);
    }
  }

  Object visitIfSection(IfSection node) {
    var ifGroup = node.ifGroup;
    var success = false;
    switch (ifGroup.name) {
      case "#if":
        var evaluator = new _ExpressionEvaluator();
        var condition = ifGroup.condition;
        var result = evaluator.evaluate(condition, _source, _definitions);
        if (result is! int) {
          throw new FormatException("Expected integer extression: ${condition}", _source, condition.position);
        }

        success = result != 0;
        break;
      case "#ifdef":
        Identifier identifier = ifGroup.condition;
        var name = identifier.name;
        success = _definitions[name] != null;
        break;
      case "#ifndef":
        Identifier identifier = ifGroup.condition;
        var name = identifier.name;
        success = _definitions[name] == null;
        break;
      default:
        throw new FormatException("Unknown directive: ${ifGroup.name}", _source, ifGroup.position);
    }

    var elifGroups = node.elifGroups;
    if (success) {
      _visitNodes(ifGroup.body);
    } else if (elifGroups != null) {
      for (var elifGroup in elifGroups) {
        var evaluator = new _ExpressionEvaluator();
        var condition = elifGroup.condition;
        var result = evaluator.evaluate(condition, _source, _definitions);
        if (result is! int) {
          throw new FormatException("Expected integer extression: ${condition}", _source, condition.position);
        }

        success = result != 0;
        if (success) {
          _visitNodes(elifGroup.body);
          break;
        }
      }
    }

    var elseGroup = node.elseGroup;
    if (!success && elseGroup != null) {
      _visitNodes(elseGroup.body);
    }

    return null;
  }

  Object visitNode(AstNode node) {
    throw new FormatException("Syntax error", _source, node.position);
  }

  Object visitPreprocessingFile(PreprocessingFile node) {
    _blocks = <TextBlock>[];
    node.visitChildren(this);
    return null;
  }

  Object visitSourceLine(SourceLine node) {
    var fragments = node.fragments;
    var buffer = new StringBuffer();
    if (fragments != null) {
      var expander = new _MacroExpander();
      for (var fragment in fragments) {
        var name = fragment.name;
        var text = fragment.text;
        if (name != null && _expand) {
          text = expander.expand(name, _definitions, "");
        }

        buffer.write(text);
      }
    }

    var block = new TextBlock(buffer.toString(), node.position);
    _blocks.add(block);
    return null;
  }

  Object visitUndefDirective(UndefDirective node) {
    var key = node.identifier.name;
    _definitions.remove(key);
    return null;
  }

  void _visitNodes(List<AstNode> nodes) {
    if (nodes != null) {
      for (var node in nodes) {
        node.accept(this);
      }
    }
  }
}
