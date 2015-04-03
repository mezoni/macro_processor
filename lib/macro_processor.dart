library macro_processor;

import "dart:collection";

import "package:macro_processor/expression_evaluator.dart";
import "package:macro_processor/internal/ast/ast.dart";
import "package:macro_processor/internal/parsers/directive_parser.dart";
import "package:macro_processor/macro_definition.dart";
import "package:macro_processor/macro_expander.dart";
import "package:parser_error/parser_error.dart";

part 'src/macro_processor/macro_processor.dart';
part 'src/macro_processor/text_block.dart';
