part of preprocessor;

class _ExpressionEvaluator extends GeneralVisitor {
  Map<String, List<SourceFragment>> _definitions;

  String _source;

  dynamic evaluate(Expression expression, String source, Map<String, List<SourceFragment>> definitions) {
    if (expression == null) {
      throw new ArgumentError.notNull("expression");
    }

    _definitions = definitions;
    _source = source;
    return expression.accept(this);
  }

  Object visitBinaryExpression(BinaryExpression node) {
    var left = node.left;
    var right = node.right;
    var lvalue = left.accept(this);
    var rvalue = right.accept(this);
    switch (node.operator) {
      case "+":
        _checkNumericValue(lvalue, left.position);
        _checkNumericValue(rvalue, right.position);
        return lvalue + rvalue;
      case "-":
        _checkNumericValue(lvalue, left.position);
        _checkNumericValue(rvalue, right.position);
        return lvalue - rvalue;
      case "*":
        _checkNumericValue(lvalue, left.position);
        _checkNumericValue(rvalue, right.position);
        return lvalue * rvalue;
      case "/":
        _checkNumericValue(lvalue, left.position);
        _checkNumericValue(rvalue, right.position);
        if (lvalue is int && rvalue is int) {
          return lvalue ~/ rvalue;
        }

        return lvalue / rvalue;
      case "<<":
        _checkIntegerValue(lvalue, left.position);
        _checkIntegerValue(rvalue, right.position);
        return lvalue << rvalue;
      case ">>":
        _checkIntegerValue(lvalue, left.position);
        _checkIntegerValue(rvalue, right.position);
        return lvalue >> rvalue;
      case "&":
        _checkIntegerValue(lvalue, left.position);
        _checkIntegerValue(rvalue, right.position);
        return lvalue & rvalue;
      case "|":
        _checkIntegerValue(lvalue, left.position);
        _checkIntegerValue(rvalue, right.position);
        return lvalue | rvalue;
      case "^":
        _checkIntegerValue(lvalue, left.position);
        _checkIntegerValue(rvalue, right.position);
        return lvalue ^ rvalue;
      case ">=":
        _checkComparableValue(lvalue, left.position);
        _checkComparableValue(rvalue, right.position);
        return lvalue >= rvalue ? 1 : 0;
      case ">":
        _checkComparableValue(lvalue, left.position);
        _checkComparableValue(rvalue, right.position);
        return lvalue > rvalue ? 1 : 0;
      case "<=":
        _checkComparableValue(lvalue, left.position);
        _checkComparableValue(rvalue, right.position);
        return lvalue <= rvalue ? 1 : 0;
      case "<":
        _checkComparableValue(lvalue, left.position);
        _checkComparableValue(rvalue, right.position);
        return lvalue < rvalue ? 1 : 0;
      case "==":
        _checkComparableValue(lvalue, left.position);
        _checkComparableValue(rvalue, right.position);
        return lvalue == rvalue ? 1 : 0;
      case "!=":
        _checkComparableValue(lvalue, left.position);
        _checkComparableValue(rvalue, right.position);
        return lvalue != rvalue ? 1 : 0;
      case "&&":
        _checkIntegerValue(lvalue, left.position);
        _checkIntegerValue(rvalue, right.position);
        return lvalue && rvalue;
      case "||":
        _checkIntegerValue(lvalue, left.position);
        _checkIntegerValue(rvalue, right.position);
        return lvalue || rvalue;
      default:
        throw new FormatException("Unknown binary operation", _source, node.position);
    }
  }

  Object visitCharacterLiteral(CharacterLiteral node) {
    return node.value;
  }

  Object visitConditionalExpression(ConditionalExpression node) {
    var condition = node.condition.accept(this);
    var fail = node.fail.accept(this);
    var success = node.success.accept(this);
    _checkIntegerValue(condition, node.condition.position);
    return condition != 0 ? success : fail;
  }

  Object visitDefinedExpression(DefinedExpression node) {
    var name = node.identifier.name;
    return _definitions.containsKey(name) ? 1 : 0;
  }

  Object visitFloatingPointLiteral(FloatingPointLiteral node) {
    return node.value;
  }

  Object visitIdentifier(Identifier node) {
    var name = node.name;
    var expander = new _MacroExpander();
    var expanded = expander.expand(name, _definitions, null);
    try {
      var parser = new Parser();
      var expression = parser.parseExpression(expanded);
      if (expression is Identifier) {
        return expression.name;
      }

      var evaluator = new _ExpressionEvaluator();
      return evaluator.evaluate(expression, expanded, _definitions);
    } catch (e) {
      throw new FormatException("Expected valid expression", _source, node.position);
    }
  }

  Object visitIntegerLiteral(IntegerLiteral node) {
    return node.value;
  }

  Object visitNode(AstNode node) {
    throw new FormatException("Syntax error", _source, node.position);
  }

  Object visitParenthesisExpression(ParenthesisExpression node) {
    return node.expression.accept(this);
  }

  Object visitUnaryExpression(UnaryExpression node) {
    var operand = node.operand;
    var value = operand.accept(this);
    switch (node.operator) {
      case "+":
        _checkNumericValue(value, operand.position);
        return value;
      case "-":
        _checkNumericValue(value, operand.position);
        return -value;
      case "!":
        _checkIntegerValue(value, operand.position);
        return value == 0 ? 1 : 0;
      case "~":
        _checkIntegerValue(value, operand.position);
        return ~value;
      default:
        throw new FormatException("Unknown unary operation", _source, node.position);
    }
  }

  void _checkComparableValue(value, int position) {
    if (value is! Comparable) {
      throw new FormatException("Expected comparable expression", _source, position);
    }
  }

  void _checkIntegerValue(value, int position) {
    if (value is! int) {
      throw new FormatException("Expected integer expression", _source, position);
    }
  }

  void _checkNumericValue(value, int position) {
    if (value is! num) {
      throw new FormatException("Expected numeric expression", _source, position);
    }
  }
}
