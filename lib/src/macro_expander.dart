part of preprocessor;

class _MacroExpander {
  String expand(String name, Map<String, List<SourceFragment>> definitions, String defaultValue) {
    if (name == null) {
      throw new ArgumentError.notNull("name");
    }

    if (definitions == null) {
      throw new ArgumentError.notNull("definitions");
    }

    return _expand(name, definitions, defaultValue, new Set<String>());
  }

  String _expand(String name, Map<String, List<SourceFragment>> definitions, String defaultValue, Set<String> processed) {
    if (processed.contains(name)) {
      return name;
    }

    processed.add(name);
    var defintion = definitions[name];
    if (defintion == null) {
      return name;
    }

    if (defintion.isEmpty) {
      if (defaultValue != null) {
        return defaultValue;
      }

      return name;
    }

    var buffer = new StringBuffer();
    for (var fragment in defintion) {
      if (fragment.name != null) {
        buffer.write(_expand(fragment.name, definitions, defaultValue, processed));
      } else {
        buffer.write(fragment.text);
      }
    }

    return buffer.toString();
  }
}
