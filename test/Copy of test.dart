import "package:macro_processor/macro_processor.dart";

void main() {
  var sw = new Stopwatch();
  sw.start();
  var processor = new MacroProcessor();
  var blocks = processor.process(text, {});
  sw.stop();
  print(sw.elapsedMilliseconds / 1000);
}

String text = '''
''';
