part of preprocessor.internal.ast;

abstract class AstNode {
  final int position;

  AstNode({this.position}) {
    if (position == null) {
      throw new ArgumentError.notNull("position");
    }
  }

  AstNodeTypes get type;

  dynamic accept(Visitor visitor);

  String toString() {
    var buffer = new StringBuffer();
    var printer = new PrintVisitor(buffer);
    accept(printer);
    return buffer.toString();
  }

  void visitChildren(Visitor visitor) {}
}

class AstNodeTypes {
  static const AstNodeTypes BINARY_EXPRESSION = const AstNodeTypes("BINARY_EXPRESSION");

  static const AstNodeTypes CHARACTER_LITERAL = const AstNodeTypes("CHARACTER_LITERAL");

  static const AstNodeTypes CONDITIONAL_EXPRESSION = const AstNodeTypes("CONDITIONAL_EXPRESSION");

  static const AstNodeTypes DEFINE_DIRECTIVE = const AstNodeTypes("DEFINE_DIRECTIVE");

  static const AstNodeTypes DEFINE_EXPRESSION = const AstNodeTypes("DEFINE_EXPRESSION");

  static const AstNodeTypes ELSE_DIRECTIVE = const AstNodeTypes("ELSE_DIRECTIVE");

  static const AstNodeTypes ENDIF_DIRECTIVE = const AstNodeTypes("ENDIF_DIRECTIVE");

  static const AstNodeTypes ERROR_DIRECTIVE = const AstNodeTypes("ERROR_DIRECTIVE");

  static const AstNodeTypes FLOATING_POINT_LITERAL = const AstNodeTypes("FLOATING_POINT_LITERAL");

  static const AstNodeTypes IDENTIFIER = const AstNodeTypes("IDENTIFIER");

  static const AstNodeTypes IF_DIRECTIVE = const AstNodeTypes("IF_DIRECTIVE");

  static const AstNodeTypes IF_SECTION = const AstNodeTypes("IF_SECTION");

  static const AstNodeTypes INCLUDE_DIRECTIVE = const AstNodeTypes("INCLUDE_DIRECTIVE");

  static const AstNodeTypes INTEGER_LITERAL = const AstNodeTypes("INTEGER_LITERAL");

  static const AstNodeTypes SOURCE_FRAGMENT = const AstNodeTypes("SOURCE_FRAGMENT");

  static const AstNodeTypes SOURCE_LINE = const AstNodeTypes("SOURCE_LINE");

  static const AstNodeTypes PARENTHESIS_EXPRESSION = const AstNodeTypes("PARENTHESIS_EXPRESSION");

  static const AstNodeTypes PREPROCESSING_FILE = const AstNodeTypes("PREPROCESSING_FILE");

  static const AstNodeTypes STRING_LITERAL = const AstNodeTypes("STRING_LITERAL");

  static const AstNodeTypes UNDEF_DIRECTIVE = const AstNodeTypes("UNDEF_DIRECTIVE");

  static const AstNodeTypes UNARY_EXPRESSION = const AstNodeTypes("UNARY_EXPRESSION");

  final String _name;

  const AstNodeTypes(this._name);
}

class BinaryExpression extends Expression {
  final Expression left;

  final String operator;

  final Expression right;

  BinaryExpression({this.left, this.operator, int position, this.right}) : super(position: position);

  AstNodeTypes get type => AstNodeTypes.BINARY_EXPRESSION;

  dynamic accept(Visitor visitor) {
    return visitor.visitBinaryExpression(this);
  }

  void visitChildren(Visitor visitor) {
    left.accept(visitor);
    right.accept(visitor);
  }
}

class CharacterLiteral extends Literal {
  final int value;

  CharacterLiteral({int position, String text, this.value}) : super(position: position, text: text);

  AstNodeTypes get type => AstNodeTypes.CHARACTER_LITERAL;

  dynamic accept(Visitor visitor) {
    return visitor.visitCharacterLiteral(this);
  }
}

class ConditionalExpression extends Expression {
  final Expression condition;

  final Expression fail;

  final Expression success;

  ConditionalExpression({this.condition, this.fail, int position, this.success}) : super(position: position);

  AstNodeTypes get type => AstNodeTypes.CONDITIONAL_EXPRESSION;

  dynamic accept(Visitor visitor) {
    return visitor.visitConditionalExpression(this);
  }

  void visitChildren(Visitor visitor) {
    condition.accept(visitor);
    success.accept(visitor);
    fail.accept(visitor);
  }
}

class DefinedExpression extends Expression {
  final Identifier identifier;

  DefinedExpression({this.identifier, int position}) : super(position: position);

  AstNodeTypes get type => AstNodeTypes.DEFINE_EXPRESSION;

  dynamic accept(Visitor visitor) {
    return visitor.visitDefinedExpression(this);
  }

  void visitChildren(Visitor visitor) {
    identifier.accept(visitor);
  }
}

class DefineDirective extends Directive {
  final Identifier identifier;

  final List<SourceFragment> replacement;

  DefineDirective({this.identifier, int position, this.replacement}) : super(position: position);

  String get name => "#define";

  AstNodeTypes get type => AstNodeTypes.DEFINE_DIRECTIVE;

  dynamic accept(Visitor visitor) {
    return visitor.visitDefineDirective(this);
  }

  void visitChildren(Visitor visitor) {
    identifier.accept(visitor);
    for (var token in replacement) {
      token.accept(visitor);
    }
  }
}

abstract class Directive extends AstNode {
  Directive({int position}) : super(position: position);

  String get name;
}

class ElseDirective extends GroupDirective {
  ElseDirective({List<AstNode> body, int position}) : super(body: body, position: position);

  String get name => "#else";

  AstNodeTypes get type => AstNodeTypes.ELSE_DIRECTIVE;

  dynamic accept(Visitor visitor) {
    return visitor.visitElseDirective(this);
  }

  void visitChildren(Visitor visitor) {
    if (body != null) {
      for (var node in body) {
        node.accept(visitor);
      }
    }
  }
}

class EndifDirective extends Directive {
  EndifDirective({int position}) : super(position: position);

  String get name => "#endif";

  AstNodeTypes get type => AstNodeTypes.ENDIF_DIRECTIVE;

  dynamic accept(Visitor visitor) {
    return visitor.visitEndifDirective(this);
  }
}

class ErrorDirective extends Directive {
  final String message;

  ErrorDirective({this.message, int position}) : super(position: position);

  String get name => "#error";

  AstNodeTypes get type => AstNodeTypes.ERROR_DIRECTIVE;

  dynamic accept(Visitor visitor) {
    return visitor.visitErrorDirective(this);
  }
}

abstract class Expression extends AstNode {
  Expression({int position}) : super(position: position);
}

class FloatingPointLiteral extends Literal {
  final double value;

  FloatingPointLiteral({int position, String text, this.value}) : super(position: position, text: text);

  AstNodeTypes get type => AstNodeTypes.FLOATING_POINT_LITERAL;

  dynamic accept(Visitor visitor) {
    return visitor.visitFloatingPointLiteral(this);
  }
}

abstract class GroupDirective extends Directive {
  final List<AstNode> body;

  GroupDirective({this.body, int position}) : super(position: position);
}

class Identifier extends Expression {
  final String name;

  Identifier({int position, this.name}) : super(position: position);

  AstNodeTypes get type => AstNodeTypes.IDENTIFIER;

  dynamic accept(Visitor visitor) {
    return visitor.visitIdentifier(this);
  }
}

class IfDirective extends GroupDirective {
  final Expression condition;

  final String name;

  IfDirective({List<AstNode> body, this.condition, this.name, int position}) : super(body: body, position: position);

  AstNodeTypes get type => AstNodeTypes.IF_DIRECTIVE;

  dynamic accept(Visitor visitor) {
    return visitor.visitIfDirective(this);
  }

  void visitChildren(Visitor visitor) {
    condition.accept(visitor);
    if (body != null) {
      for (var node in body) {
        node.accept(visitor);
      }
    }
  }
}

class IfSection extends AstNode {
  final List<IfDirective> elifGroups;

  final ElseDirective elseGroup;

  final EndifDirective endifLine;

  final IfDirective ifGroup;

  IfSection({this.ifGroup, this.elifGroups, this.elseGroup, this.endifLine, int position}) : super(position: position);

  AstNodeTypes get type => AstNodeTypes.IF_SECTION;

  dynamic accept(Visitor visitor) {
    return visitor.visitIfSection(this);
  }

  void visitChildren(Visitor visitor) {
    ifGroup.accept(visitor);
    if (elifGroups != null) {
      for (var group in elifGroups) {
        group.accept(visitor);
      }
    }

    if (elseGroup != null) {
      elseGroup.accept(visitor);
    }

    endifLine.accept(visitor);
  }
}

class IncludeDirective extends Directive {
  final String header;

  final String name;

  IncludeDirective({this.header, this.name, int position}) : super(position: position);

  AstNodeTypes get type => AstNodeTypes.INCLUDE_DIRECTIVE;

  dynamic accept(Visitor visitor) {
    return visitor.visitIncludeDirective(this);
  }
}

class IntegerLiteral extends Literal {
  final int value;

  IntegerLiteral({int position, String text, this.value}) : super(position: position, text: text);

  AstNodeTypes get type => AstNodeTypes.INTEGER_LITERAL;

  dynamic accept(Visitor visitor) {
    return visitor.visitIntegerLiteral(this);
  }
}

abstract class Literal extends Expression {
  final String text;

  Literal({int position, this.text}) : super(position: position);

  dynamic get value;
}

class ParenthesisExpression extends Expression {
  final Expression expression;

  ParenthesisExpression({this.expression, int position}) : super(position: position);

  AstNodeTypes get type => AstNodeTypes.PARENTHESIS_EXPRESSION;

  dynamic accept(Visitor visitor) {
    return visitor.visitParenthesisExpression(this);
  }

  void visitChildren(Visitor visitor) {
    expression.accept(visitor);
  }
}

class PreprocessingFile extends AstNode {
  final List<AstNode> groups;

  PreprocessingFile({this.groups, int position}) : super(position: position);

  AstNodeTypes get type => AstNodeTypes.PREPROCESSING_FILE;

  dynamic accept(Visitor visitor) {
    return visitor.visitPreprocessingFile(this);
  }

  void visitChildren(Visitor visitor) {
    if (groups != null) {
      for (var group in groups) {
        group.accept(visitor);
      }
    }
  }
}

class SourceFragment extends AstNode {
  String filename;

  final String text;

  final dynamic value;

  SourceFragment({int position, this.text, this.value}) : super(position: position);

  AstNodeTypes get type => AstNodeTypes.SOURCE_FRAGMENT;

  dynamic accept(Visitor visitor) {
    return visitor.visitSourceFragment(this);
  }
}

class SourceLine extends AstNode {
  final List<SourceFragment> fragments;

  SourceLine({this.fragments, int position}) : super(position: position);

  AstNodeTypes get type => AstNodeTypes.SOURCE_LINE;

  dynamic accept(Visitor visitor) {
    return visitor.visitSourceLine(this);
  }

  void visitChildren(Visitor visitor) {
    if (fragments != null) {
      for (var fragment in fragments) {
        fragment.accept(visitor);
      }
    }
  }
}

class StringLiteral extends Literal {
  final String value;

  StringLiteral({int position, String text, this.value}) : super(position: position, text: text);

  AstNodeTypes get type => AstNodeTypes.STRING_LITERAL;

  dynamic accept(Visitor visitor) {
    return visitor.visitStringLiteral(this);
  }
}

class UnaryExpression extends Expression {
  final Expression operand;

  final String operator;

  UnaryExpression({this.operand, this.operator, int position}) : super(position: position);

  AstNodeTypes get type => AstNodeTypes.UNARY_EXPRESSION;

  dynamic accept(Visitor visitor) {
    return visitor.visitUnaryExpression(this);
  }

  void visitChildren(Visitor visitor) {
    operand.accept(visitor);
  }
}

class UndefDirective extends Directive {
  final Identifier identifier;

  UndefDirective({this.identifier, int position}) : super(position: position);

  String get name => "#undef";

  AstNodeTypes get type => AstNodeTypes.UNDEF_DIRECTIVE;

  dynamic accept(Visitor visitor) {
    return visitor.visitUndefDirective(this);
  }

  void visitChildren(Visitor visitor) {
    identifier.accept(visitor);
  }
}
