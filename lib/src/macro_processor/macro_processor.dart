part of macro_processor;

class MacroProcessor {
  List<TextBlock> process(String filename, Map<String, String> files,
      {Map<String, MacroDefinition> definitions, Map<String, dynamic> environment}) {
    var processor = new _MacroProcessor();
    return processor.process(filename, files, definitions: definitions, environment: environment);
  }
}

class _MacroProcessor extends GeneralVisitor {
  List<TextBlock> _blocks;

  Map<String, MacroDefinition> _definitions;

  Map<String, dynamic> _environment;

  String _filename;

  Map<String, String> _files;

  String _source;

  List<TextBlock> process(String filename, Map<String, String> files,
      {Map<String, MacroDefinition> definitions, Map<String, dynamic> environment}) {
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
      definitions = <String, MacroDefinition>{};
    }

    _definitions = definitions;
    _environment = environment;
    _filename = filename;
    _files = files;
    _source = _files[_filename];
    if (_source == null) {
      throw new StateError("File not found: $_filename");
    }

    var parser = new DirectiveParser();
    var file = parser.parse(_source);
    if (environment != null) {
      for (var key in environment.keys) {
        var value = environment[key];
        if (!(value is String || value is int || value is double || value is Symbol)) {
          throw new ArgumentError("Illegal type of environment variable '$key': ${value.runtimeType}");
        }

        // TODO: Parse source fragments
        var fragments = new UnmodifiableListView([value]);
        var definition = new MacroDefinition(fragments: fragments, name: key);
        _definitions[key] = definition;
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
    var fragments = [];
    for (var fragment in node.fragments) {
      var value = fragment.value;
      if (value is! Symbol) {
        value = fragment.text;
      }

      fragments.add(value);
    }

    fragments = new UnmodifiableListView(fragments);
    var definition = new MacroDefinition(filename: _filename, fragments: fragments, name: key);
    _definitions[key] = definition;
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
        var condition = ifGroup.condition;
        var result = _evaluateIfCondition(ifGroup);
        success = result != 0;
        break;
      case "#ifdef":
        var symbol = ifGroup.condition[0].value;
        var name = _symbolToString(symbol);
        success = _definitions[name] != null;
        break;
      case "#ifndef":
        var symbol = ifGroup.condition[0].value;
        var name = _symbolToString(symbol);
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
        var result = _evaluateIfCondition(elifGroup);
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
    var text = _expand(fragments);
    var block = new TextBlock(text, node.position, filename: _filename);
    _blocks.add(block);
    return null;
  }

  Object visitUndefDirective(UndefDirective node) {
    var key = node.identifier.name;
    _definitions.remove(key);
    return null;
  }

  int _evaluateIfCondition(IfDirective node) {
    var condition = node.condition;
    var text = _expand(condition);
    var result;
    try {
      result = _evaluate(text);
    } on FormatException catch (e) {
      int position;
      if (!condition.isEmpty) {
        position = condition[0].position;
      } else {
        position = node.position + node.name.length + 1;
      }

      var messages = [];
      messages.add(new ParserErrorMessage("Not a valid expression", position, position));
      var strings = ParserErrorFormatter.format(_source, messages);
      strings.add(e.message);
      throw new FormatException(strings.join("\n"));
    }

    if (result is! int) {
      int position;
      if (!condition.isEmpty) {
        position = condition[0].position;
      } else {
        position = node.position + node.name.length + 1;
      }

      var messages = [];
      messages.add(new ParserErrorMessage("Expected an integer expression", position, position));
      var strings = ParserErrorFormatter.format(_source, messages);
      for (var fragment in condition) {
        if (fragment.value is Symbol) {
          strings.add("${node.name} $text");
          break;
        }
      }

      throw new FormatException(strings.join("\n"));
    }

    return result;
  }

  dynamic _evaluate(String text) {
    bool defined(String name) {
      return _definitions.containsKey(name);
    }

    var evaluator = new ExpressionEvaluator();
    return evaluator.evaluate(text, defined: defined);
  }

  String _expand(List<SourceFragment> fragments, [String defaultValue = ""]) {
    var expander = new MacroExpander();
    if (fragments != null) {
      var data = [];
      for (var fragment in fragments) {
        var value = fragment.value;
        if (value is Symbol) {
          data.add(value);
        } else {
          data.add(fragment.text);
        }
      }

      return expander.expand(data, _definitions);
    }

    return "";
  }

  String _symbolToString(Symbol symbol) {
    var string = symbol.toString();
    return string.substring(8, string.length - 2);
  }

  void _visitNodes(List<AstNode> nodes) {
    if (nodes != null) {
      for (var node in nodes) {
        node.accept(this);
      }
    }
  }
}
