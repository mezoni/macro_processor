part of macro_processor;

class TextBlock {
  final String filename;

  final int position;

  final String text;

  TextBlock(this.text, this.position, {this.filename}) {
    if (text == null) {
      throw new ArgumentError.notNull("text");
    }

    if (position == null || position < 0) {
      throw new ArgumentError.value(position, "position");
    }
  }

  int get length => text.length;

  String toString() => text;
}
