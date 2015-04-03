part of macro_processor.macro_definition;

class MacroDefinition {
  final String filename;

  final List<dynamic> fragments;

  final String name;

  MacroDefinition({this.filename, this.fragments, this.name}) {
    if (fragments == null) {
      throw new ArgumentError.notNull("filename");
    }

    for (var fragment in fragments) {
      if (!(fragment is int || fragment is Symbol || fragment is String || fragment is double)) {
        throw new ArgumentError("List of the fragments contains an invaild values");
      }
    }

    if (name == null) {
      throw new ArgumentError.notNull("name");
    }
  }

  String toString() {
    var sb = new StringBuffer();
    for (var fragment in fragments) {
      if (fragment is Symbol) {
        var string = fragment.toString();
        var name = string.substring(8, string.length - 2);
        sb.write(name);
      } else {
        sb.write(fragment);
      }
    }

    return sb.toString();
  }
}
