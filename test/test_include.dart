import "package:macro_processor/macro_processor.dart";
import "package:unittest/unittest.dart";

void main() {
  group("Macro processor.", () {
    test("Include directive.", () {
      var files = {"header1.h": header1, "header2.h": header2};
      var processor = new MacroProcessor();
      var blocks = processor.process("header2.h", files);
    });
  });
}

String header1 = '''
#if !defined(HEADER1)
#define HEADER1

#define TWO 1 + 1

1
2
abc

#define Foo foo

#endif
''';

String header2 = '''
#if !defined(HEADER2)
#define HEADER2

#include <header1.h>
#include <header1.h>

#if !defined(TWO)
#error TWO not defined
#endif 

#endif
''';
