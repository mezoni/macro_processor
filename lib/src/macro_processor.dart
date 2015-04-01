part of preprocessor;

class MacroProcessor {
  List<TextBlock> process(String filename, Map<String, String> files,
      {Map<String, List<SourceFragment>> definitions, Map<String, dynamic> environment}) {
    var processor = new _MacroProcessor();
    return processor.process(filename, files, definitions: definitions, environment: environment);
  }
}

class _MacroProcessor extends GeneralVisitor {
  List<TextBlock> _blocks;

  Map<String, List<SourceFragment>> _definitions;

  Map<String, dynamic> _environment;

  bool _expand;

  String _filename;

  Map<String, String> _files;

  String _source;

  List<TextBlock> process(String filename, Map<String, String> files,
      {Map<String, List<SourceFragment>> definitions, Map<String, dynamic> environment}) {
    if (filename == null) {
      throw new ArgumentError.notNull("filename");
    }

    if (files == null) {
      throw new ArgumentError.notNull("files");
    }

    if (environment == null) {
      environment = <String, dynamic>{};
    }

    if (definitions == null) {
      definitions = <String, List<SourceFragment>>{};
    }

    _definitions = definitions;
    _environment = environment;
    _expand = true;
    _filename = filename;
    _files = files;
    _source = _files[_filename];
    if (_source == null) {
      throw new StateError("File not found: $_filename");
    }

    var parser = new Parser();
    var file = parser.parsePreprocessingFile(_source);
    if (environment != null) {
      for (var key in environment.keys) {
        var value = environment[key];
        if (!(value is String || value is int || value is double || value is Symbol)) {
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
    filename = prev.filename;
    var start = 0;
    var result = <TextBlock>[prev];
    for (var i = 1; i < length; i++) {
      var block = _blocks[i];
      if (end == block.position && block.filename == filename) {
        var newBlock = new TextBlock(prev.text + block.text, start, filename: filename);
        result[result.length - 1] = newBlock;
        end += block.length;
        prev = newBlock;
      } else {
        start = block.position;
        end = start + block.length;
        result.add(block);
        prev = block;
        filename = prev.filename;
      }
    }

    return result;
  }

  Object visitDefineDirective(DefineDirective node) {
    var key = node.identifier.name;
    var fragments = node.replacement;
    for (var fragment in fragments) {
      fragment.filename = _filename;
    }

    _definitions[key] = fragments;
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

  visitIncludeDirective(IncludeDirective node) {
    var header = node.header;
    var filename = header.substring(1, header.length - 1);
    var processor = new MacroProcessor();
    var blocks = processor.process(filename, _files, definitions: _definitions);
    _blocks.addAll(blocks);
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
        var value = fragment.value;
        var text = fragment.text;
        if (value is Symbol && _expand) {
          text = expander.expand(text, _definitions, "");
        }

        buffer.write(text);
      }
    }

    var block = new TextBlock(buffer.toString(), node.position, filename: _filename);
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
