part of macro_processor.internal.parsers.expression_parser;

class ExpressionParser {
  Expression parse(String text) {
    var parser = new ExprParser(text);
    Expression result = parser.parse_eval_line();
    _errors(parser);
    return result;
  }

  void _errors(ExprParser parser) {
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
