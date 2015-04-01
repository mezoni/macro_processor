part of preprocessor.internal.ast;

class GeneralVisitor<T> implements Visitor<T> {
  T visitBinaryExpression(BinaryExpression node) => visitNode(node);

  T visitCharacterLiteral(CharacterLiteral node) => visitNode(node);

  T visitConditionalExpression(ConditionalExpression node) => visitNode(node);

  T visitDefinedExpression(DefinedExpression node) => visitNode(node);

  T visitDefineDirective(DefineDirective node) => visitNode(node);

  T visitElseDirective(ElseDirective node) => visitNode(node);

  T visitEndifDirective(EndifDirective node) => visitNode(node);

  T visitErrorDirective(ErrorDirective node) => visitNode(node);

  T visitFloatingPointLiteral(FloatingPointLiteral node) => visitNode(node);

  T visitIdentifier(Identifier node) => visitNode(node);

  T visitIfDirective(IfDirective node) => visitNode(node);

  T visitIfSection(IfSection node) => visitNode(node);

  T visitIncludeDirective(IncludeDirective node) => visitNode(node);

  T visitIntegerLiteral(IntegerLiteral node) => visitNode(node);

  T visitNode(AstNode node) {
    node.visitChildren(this);
    return null;
  }

  T visitParenthesisExpression(ParenthesisExpression node) => visitNode(node);

  T visitPreprocessingFile(PreprocessingFile node) => visitNode(node);

  T visitSourceFragment(SourceFragment node) => visitNode(node);

  T visitSourceLine(SourceLine node) => visitNode(node);

  T visitStringLiteral(StringLiteral node) => visitNode(node);

  T visitUnaryExpression(UnaryExpression node) => visitNode(node);

  T visitUndefDirective(UndefDirective node) => visitNode(node);
}

class PrintVisitor implements Visitor<Object> {
  final StringBuffer buffer;

  PrintVisitor(this.buffer) {
    if (buffer == null) {
      throw new ArgumentError.notNull("buffer");
    }
  }

  String toString() => buffer.toString();

  Object visitBinaryExpression(BinaryExpression node) {
    node.left.accept(this);
    buffer.write(" ");
    buffer.write(node.operator);
    buffer.write(" ");
    node.right.accept(this);
    return null;
  }

  Object visitCharacterLiteral(CharacterLiteral node) {
    buffer.write(node.text);
    return null;
  }

  Object visitConditionalExpression(ConditionalExpression node) {
    node.condition.accept(this);
    buffer.write(" ? ");
    node.success.accept(this);
    buffer.write(" : ");
    node.fail.accept(this);
    return null;
  }

  Object visitDefinedExpression(DefinedExpression node) {
    buffer.write("defined(");
    node.identifier.accept(this);
    buffer.write(")");
    return null;
  }

  Object visitDefineDirective(DefineDirective node) {
    buffer.write(node.name);
    buffer.write(" ");
    node.identifier.accept(this);
    buffer.write(" ");
    _visitNodes(node.replacement);
    return null;
  }

  Object visitElseDirective(ElseDirective node) {
    buffer.write(node.name);
    buffer.writeln();
    _visitNodes(node.body);
    return null;
  }

  Object visitEndifDirective(EndifDirective node) {
    buffer.write(node.name);
    return null;
  }

  Object visitErrorDirective(ErrorDirective node) {
    buffer.write(node.name);
    buffer.write(" ");
    buffer.write(node.message);
    return null;
  }

  Object visitFloatingPointLiteral(FloatingPointLiteral node) {
    buffer.write(node.text);
    return null;
  }

  Object visitIdentifier(Identifier node) {
    buffer.write(node.name);
    return null;
  }

  Object visitIfDirective(IfDirective node) {
    buffer.write(node.name);
    buffer.write(" ");
    node.condition.accept(this);
    var tokens = node.body;
    if (tokens != null) {
      buffer.writeln();
      _visitNodes(node.body);
    }

    return null;
  }

  Object visitIfSection(IfSection node) {
    node.ifGroup.accept(this);
    buffer.writeln();
    var elifGroups = node.elifGroups;
    if (elifGroups != null) {
      for (var group in elifGroups) {
        group.accept(this);
        buffer.writeln();
      }
    }

    var elseGroup = node.elseGroup;
    if (elseGroup != null) {
      elseGroup.accept(this);
      buffer.writeln();
    }

    node.endifLine.accept(this);
    buffer.writeln();
    return null;
  }

  Object visitIncludeDirective(IncludeDirective node) {
    buffer.write(node.name);
    buffer.write(" ");
    buffer.write(node.header);
    return null;
  }

  Object visitIntegerLiteral(IntegerLiteral node) {
    buffer.write(node.text);
    return null;
  }

  Object visitParenthesisExpression(ParenthesisExpression node) {
    buffer.write("(");
    node.expression.accept(this);
    buffer.write(")");
    return null;
  }

  Object visitPreprocessingFile(PreprocessingFile node) {
    _visitNodes(node.groups);
    return null;
  }

  Object visitSourceFragment(SourceFragment node) {
    buffer.write(node.text);
    return null;
  }

  Object visitSourceLine(SourceLine node) {
    _visitNodes(node.fragments);
    return null;
  }

  Object visitStringLiteral(StringLiteral node) {
    buffer.write(node.text);
    return null;
  }

  Object visitUnaryExpression(UnaryExpression node) {
    buffer.write(node.operator);
    node.operand.accept(this);
    return null;
  }

  Object visitUndefDirective(UndefDirective node) {
    buffer.write(node.name);
    buffer.write(" ");
    buffer.write(node.identifier);
    return null;
  }

  Object _visitNodes(List<AstNode> nodes) {
    if (nodes != null) {
      for (var node in nodes) {
        node.accept(this);
      }
    }

    return null;
  }
}

abstract class Visitor<T> {
  T visitBinaryExpression(BinaryExpression node);

  T visitCharacterLiteral(CharacterLiteral node);

  T visitConditionalExpression(ConditionalExpression node);

  T visitDefinedExpression(DefinedExpression node);

  T visitDefineDirective(DefineDirective node);

  T visitElseDirective(ElseDirective node);

  T visitEndifDirective(EndifDirective node);

  T visitErrorDirective(ErrorDirective node);

  T visitFloatingPointLiteral(FloatingPointLiteral node);

  T visitIdentifier(Identifier node);

  T visitIfDirective(IfDirective node);

  T visitIfSection(IfSection node);

  T visitIncludeDirective(IncludeDirective node);

  T visitIntegerLiteral(IntegerLiteral node);

  T visitParenthesisExpression(ParenthesisExpression node);

  T visitPreprocessingFile(PreprocessingFile node);

  T visitSourceFragment(SourceFragment node);

  T visitSourceLine(SourceLine node);

  T visitStringLiteral(StringLiteral node);

  T visitUnaryExpression(UnaryExpression node);

  T visitUndefDirective(UndefDirective node);
}
