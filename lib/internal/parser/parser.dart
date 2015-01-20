library preprocessor.internal.parser;

import "package:macro_processor/internal/ast/ast.dart";
import "package:macro_processor/internal/parser/p_parser.dart";

class Parser {
  Expression parseExpression(String text) {
    var parser = new PParser(text);
    Expression result = parser.parse_eval_line();
    _errors(parser);
    return result;
  }

  PreprocessingFile parsePreprocessingFile(String text) {
    var parser = new PParser(text);
    PreprocessingFile result = parser.parse_preprocessing_file();
    _errors(parser);
    return result;
  }

  void _errors(PParser parser) {
    if (!parser.success) {
      var exceptions = <String>[];
      for (var error in parser.errors()) {
        try {
          throw new FormatException(error.message, parser.text, error.position);
        } on FormatException catch (e) {
          var line = e.toString().replaceFirst("FormatException: ", "");
          exceptions.add(line);
        }
      }

      throw new FormatException(exceptions.join("\n"));
    }
  }
}
