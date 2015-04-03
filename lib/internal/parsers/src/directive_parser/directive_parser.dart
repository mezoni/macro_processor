part of macro_processor.internal.parsers.directive_parser;

class DirectiveParser {
  PreprocessingFile parse(String text) {
    var parser = new MacroParser(text);
    PreprocessingFile result = parser.parse_preprocessing_file();
    _errors(parser);
    return result;
  }

  void _errors(MacroParser parser) {
    if (!parser.success) {
      var messages = [];
      for (var error in parser.errors()) {
        messages.add(new ParserErrorMessage(error.message, error.start, error.position));
      }

      var strings = ParserErrorFormatter.format(parser.text, messages);
      throw new FormatException(strings.join("\n"));
    }
  }
}
