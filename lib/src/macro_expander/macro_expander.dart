part of macro_processor.macro_expander;

class MacroExpander {
  String expand(List fragments, Map<String, MacroDefinition> definitions) {
    if (fragments == null) {
      throw new ArgumentError.notNull("fragments");
    }

    if (definitions == null) {
      throw new ArgumentError.notNull("definitions");
    }

    return _expandFragments(fragments, definitions, new Set<String>());
  }

  String _expandFragment(String name, Map<String, MacroDefinition> definitions, Set<String> processed) {
    if (processed.contains(name)) {
      return name;
    }

    var defintion = definitions[name];
    if (defintion == null) {
      return name;
    }

    var fragments = defintion.fragments;
    if (fragments.isEmpty) {
      return name;
    }

    processed.add(name);
    var buffer = new StringBuffer();
    var expand = true;
    for (var fragment in fragments) {
      if (fragment is Symbol) {
        fragment = _symbolToString(fragment);
        if (!expand) {
          expand = true;
        } else {
          if (fragment == "defined") {
            expand = false;
          } else {
            fragment = _expandFragment(fragment, definitions, processed);
          }
        }
      }

      buffer.write(fragment);
    }

    processed.remove(name);
    return buffer.toString();
  }

  String _expandFragments(List fragments, Map<String, MacroDefinition> definitions, Set<String> processed) {
    var buffer = new StringBuffer();
    var expand = true;
    for (var fragment in fragments) {
      if (fragment is Symbol) {
        fragment = _symbolToString(fragment);
        if (!expand) {
          expand = true;
        } else {
          if (fragment == "defined") {
            expand = false;
          } else {
            fragment = _expandFragment(fragment, definitions, processed);
          }
        }
      }

      buffer.write(fragment);
    }

    return buffer.toString();
  }

  String _symbolToString(Symbol symbol) {
    var string = symbol.toString();
    return string.substring(8, string.length - 2);
  }
}
