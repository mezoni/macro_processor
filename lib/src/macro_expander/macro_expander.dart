part of macro_processor.macro_expander;

class MacroExpander {
  String expand(String name, Map<String, MacroDefinition> definitions, String defaultValue) {
    if (name == null) {
      throw new ArgumentError.notNull("name");
    }

    if (definitions == null) {
      throw new ArgumentError.notNull("definitions");
    }

    return _expand(name, definitions, defaultValue, new Set<String>());
  }

  String _expand(String name, Map<String, MacroDefinition> definitions, String defaultValue, Set<String> processed) {
    if (processed.contains(name)) {
      return name;
    }

    processed.add(name);
    var defintion = definitions[name];
    if (defintion == null) {
      return name;
    }

    var fragments = defintion.fragments;
    if (fragments.isEmpty) {
      if (defaultValue != null) {
        return defaultValue;
      }

      return name;
    }

    var buffer = new StringBuffer();
    for (var fragment in fragments) {
      if (fragment is Symbol) {
        fragment = _symbolToString(fragment);
        buffer.write(_expand(fragment, definitions, defaultValue, processed));
      } else {
        buffer.write(fragment);
      }
    }

    return buffer.toString();
  }

  String _symbolToString(Symbol symbol) {
    var string = symbol.toString();
    return string.substring(8, string.length - 2);
  }
}
