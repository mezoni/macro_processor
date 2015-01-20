preprocessor
=====

Lightweight macro processor with syntax similar to C language.

Version: 0.0.1

Initial release. Use at your own risk!

```dart
import "package:macro_processor/macro_processor.dart";

void main() {
  var processor = new MacroProcessor();
  var environment = {};
  environment["OS"] = "linux";
  var blocks = processor.process(text, environment);
  var result = blocks.map((e) => e.text).join();
  print(result);
  ;
}

String text = '''
#define _HELLO_ _HI_
#define _HI_ Hello
#if OS == windows
_HELLO_ OS
#elif OS == linux
_HELLO_ OS
Bye windows!
#else
_HELLO_ OS
#endif
#define E YEE!
1E2 E
#define _MIN_VERSION_ 100
#define _VERSION_ 180
#if _VERSION_ < _MIN_VERSION_
#error Wrong version 
#endif
Our version: _VERSION_''';

```
