import "package:macro_processor/macro_processor.dart";
import "package:unittest/unittest.dart";


void main() {
  group("Macro processor.", () {
    test("Directive syntax.", () {
      var processor = new MacroProcessor();
      var blocks = processor.process(text, {});
    });

    test("Produced result.", () {
      var processor = new MacroProcessor();
      var blocks = processor.process(text2, {
        "OS": "windows"
      });
      var result = blocks.map((e) => e.text).join();
      expect(result, "Hello windows\n1E2 YEE!");
      blocks = processor.process(text2, {
        "OS": "linux"
      });
      result = blocks.map((e) => e.text).join();
      expect(result, "Hello linux\nBye windows!\n1E2 YEE!");
    });
  });
}

String text = '''
2 + 2

// Comment

/*
 * Comment
 */

#define ABC DEF
#define DEF 1 + 1
ABC
{}

#if 0x1p3 != 8.0
#error 0x1p3 != 8.0
#endif

#if 0x1.5p3 != 10.5
#error 0x1.5p3 != 10.5
#endif

#if 0x.5p3 != 2.5
#error 0x.5p3 != 2.5
#endif

#if ' ' != 32
#error ' ' != 32
#endif

#if '\\040' != 32
#error '\\040' != 32
#endif

#if '\\x20' != 32
#error '\\x20' != 32
#endif

#if '\\u0020' != 32
#error '\\u0020' != 32
#endif

#if '\\U00000020' != 32
#error '\\U00000020' != 32
#endif

#if windows != windows
#error windows != windows
#endif

#define OS windows

#if OS != windows
#error OS != windows
#endif

#if 1L != 1uL
#error 1L != 1uL
#endif

#if 1 == 2
#error 1 == 2
#else
#define BAZ 1
#endif

#if !BAZ 
#error !BAZ
#elif BAZ
#undef BAZ
#else
#error BAZ
#endif

#if defined(BAZ) 
#error BAZ
#endif

#define FOO 0

#if (0 != FOO)
#error (0 != FOO)
#endif

#if !(1 == 1 ? 1 == 1 : 1 == 0)
#error !(1 == 1 ? 1 == 1 : 1 == 0)
#endif

#undef FOO

#ifdef FOO
#error FOO
#endif

#if defined(FOO)
#error FOO
#endif

#define FOO

#ifndef FOO
#error FOO
#endif

#if !defined(FOO)
#error FOO
#endif

#define PI 3.14
#define PI2 PI * 2

#if PI != 3.14
#error PI != 3.14
#endif

#if PI2 != 6.28
#error PI2 != 6.28
#endif

#if .1 != .1
#error .1 != .1
#endif

#if .1e10 != .1e10
#error .1e10 != .1e10
#endif

#if .1e-10 != .1e-10
#error .1e-10 != .1e-10
#endif

#if 1.1E+10 != 1.1E+10
#error 1.1E+10 != 1.1E+10
#endif

#if 0x0 != 0x0
#error 0x0 != 0x0
#endif

#if 0x0a != 0x0a
#error 0x0a != 0x0a
#endif

a''';

String text2 = '''
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
1E2 E''';
