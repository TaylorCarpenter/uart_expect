import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';
import 'package:uart_expect/dsl/commands.dart';
import 'package:uart_expect/dsl/grammar.dart';

void dslTests() {
  group('Number Grammar', tags: ['basic_grammar'], () {
    test('parses a single digit', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.number());
      final result = parser.parse('5');
      expect(result, isA<Success>().having((s) => s.value, 'value', 5));
    });

    test('parses multiple digits', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.number());
      final result = parser.parse('42');
      expect(result, isA<Success>().having((s) => s.value, 'value', 42));
    });

    test('parses a number with leading zeros', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.number());
      final result = parser.parse('007');
      expect(result, isA<Success>().having((s) => s.value, 'value', 7));
    });

    test('fails to parse a non-numeric string', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.number());
      final result = parser.parse('abc');
      expect(result, isA<Failure>());
    });
  });

  group('Plain Character Grammar', tags: ['basic_grammar'], () {
    test('parses a plain character', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.plainCharacter());
      final result = parser.parse('a');
      expect(result, isA<Success>().having((s) => s.value, 'value', 'a'));
    });

    test('fails to parse a double quote', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.plainCharacter());
      final result = parser.parse('"');
      expect(result, isA<Failure>());
    });
  });

  group('Escaped Quote Grammar', tags: ['basic_grammar'], () {
    test('parses an escaped double quote', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.escapedQuote());
      final result = parser.parse('\\"');
      expect(result, isA<Success>().having((s) => s.value, 'value', '"'));
    });

    test('fails to parse a non-escaped double quote', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.escapedQuote());
      final result = parser.parse('"');
      expect(result, isA<Failure>());
    });

    test('fails to parse a non-escaped character', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.escapedQuote());
      final result = parser.parse('a');
      expect(result, isA<Failure>());
    });

    test('fails to parse an escaped single quote', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.escapedQuote());
      final result = parser.parse("\\'");
      expect(result, isA<Failure>());
    });
  });

  group('Character Grammar', tags: ['basic_grammar'], () {
    test('parses a character', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.character());
      final result = parser.parse('a');
      expect(result, isA<Success>().having((s) => s.value, 'value', 'a'));
    });

    test('parses an escaped quote as a character', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.character());
      final result = parser.parse('\\"');
      expect(result, isA<Success>().having((s) => s.value, 'value', '"'));
    });

    test('fails to parse an invalid character', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.character());
      final result = parser.parse('"');
      expect(result, isA<Failure>());
    });
  });
  group('Quoted String Grammar', tags: ['basic_grammar'], () {
    test('parses a quoted string', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.quotedString());
      final result = parser.parse('"hello"');
      expect(result, isA<Success>().having((s) => s.value, 'value', 'hello'));
    });

    test('parses a quoted string with an escaped quote', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.quotedString());
      final result = parser.parse('"he\\"llo"');
      expect(result, isA<Success>().having((s) => s.value, 'value', 'he"llo'));
    });

    test('fails to parse an unquoted string', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.quotedString());
      final result = parser.parse('hello');
      expect(result, isA<Failure>());
    });

    test('fails to parse a string without closing quotes', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.quotedString());
      final result = parser.parse('"he');
      expect(result, isA<Failure>());
    });
  });

  group('Empty String Grammar', tags: ['basic_grammar'], () {
    test('parses new line as empty string', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.empty());
      final result = parser.parse('\n');
      expect(result, isA<Success>().having((s) => s.value, 'value', ''));
    });

    test('parses whitespace followed by a new line as empty string', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.empty());
      final result = parser.parse('   \n');
      expect(result, isA<Success>().having((s) => s.value, 'value', ''));
    });

    test('fails to parse a string without a new line', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.empty());
      final result = parser.parse(' ');
      expect(result, isA<Failure>());
    });
  });

  group('Comment Grammar', tags: ['basic_grammar'], () {
    test('parses a standalone comment', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.comment());
      final result = parser.parse('# this is a comment\n');
      expect(result, isA<Success>());
    });

    test('parses trailing comments', () {
      const script = 'send "AT" # trailing comment';

      final result = Grammar().build().parse(script);

      expect(result, isA<Success>());
      expect(result.value.whereType<SendCommand>(), hasLength(1));
    });

    test('fails to parse a string without a comment', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.comment());
      final result = parser.parse('this is not a comment\n');
      expect(result, isA<Failure>());
    });
  });

  group('Delay Command Grammar', tags: ['command_grammar'], () {
    test('parses a delay command', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.delayCommand());
      final result = parser.parse('delay 100');
      expect(result, isA<Success>().having((s) => s.value, 'value', isA<DelayCommand>().having((c) => c.seconds, 'seconds', 100)));
    });

    test('parses a DELAY command', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.delayCommand());
      final result = parser.parse('DELAY 100');
      expect(result, isA<Success>().having((s) => s.value, 'value', isA<DelayCommand>().having((c) => c.seconds, 'seconds', 100)));
    });

    test('fails to parse a delay command without the "delay" keyword', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.delayCommand());
      final result = parser.parse('100');
      expect(result, isA<Failure>());
    });

    test('fails to parse a delay command without a number', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.delayCommand());
      final result = parser.parse('delay');
      expect(result, isA<Failure>());
    });
  });

  group('Timeout Command Grammar', tags: ['command_grammar'], () {
    test('parses a timeout command', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.timeoutCommand());
      final result = parser.parse('timeout 100');
      expect(result, isA<Success>().having((s) => s.value, 'value', isA<TimeoutCommand>().having((c) => c.seconds, 'seconds', 100)));
    });

    test('parses a TIMEOUT command', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.timeoutCommand());
      final result = parser.parse('TIMEOUT 100');
      expect(result, isA<Success>().having((s) => s.value, 'value', isA<TimeoutCommand>().having((c) => c.seconds, 'seconds', 100)));
    });

    test('fails to parse a timeout command without the "timeout" keyword', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.timeoutCommand());
      final result = parser.parse('100');
      expect(result, isA<Failure>());
    });

    test('fails to parse a timeout command without a number', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.timeoutCommand());
      final result = parser.parse('timeout ');
      expect(result, isA<Failure>());
    });
  });

  group('Expect Like Command Grammar', tags: ['command_grammar'], () {
    test('parses an expect like command', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.expectLikeCommand());
      final result = parser.parse('expect_like "pattern"');
      expect(
        result,
        isA<Success>().having(
          (s) => s.value,
          'value',
          isA<ExpectCommand>().having((c) => c.pattern, 'pattern', 'pattern').having((c) => c.isRegex, 'isRegex', true),
        ),
      );
    });

    test('parses an EXPECT_LIKE command', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.expectLikeCommand());
      final result = parser.parse('EXPECT_LIKE "pattern"');
      expect(
        result,
        isA<Success>().having(
          (s) => s.value,
          'value',
          isA<ExpectCommand>().having((c) => c.pattern, 'pattern', 'pattern').having((c) => c.isRegex, 'isRegex', true),
        ),
      );
    });

    test('parses an expect like command with escaped quotes', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.expectLikeCommand());
      final result = parser.parse('expect_like "pattern with \\"escaped quotes\\""');
      expect(
        result,
        isA<Success>().having(
          (s) => s.value,
          'value',
          isA<ExpectCommand>().having((c) => c.pattern, 'pattern', 'pattern with "escaped quotes"').having((c) => c.isRegex, 'isRegex', true),
        ),
      );
    });

    test('parses an expect_like command with escaped non-quotes', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.expectLikeCommand());
      final result = parser.parse('expect_like "pattern with \\\\escaped backslash"');
      expect(
        result,
        isA<Success>().having(
          (s) => s.value,
          'value',
          isA<ExpectCommand>().having((c) => c.pattern, 'pattern', 'pattern with \\\\escaped backslash').having((c) => c.isRegex, 'isRegex', true),
        ),
      );
    });

    test('fails to parse an expect like command without the "expect_like" keyword', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.expectLikeCommand());
      final result = parser.parse('"pattern"');
      expect(result, isA<Failure>());
    });

    test('fails to parse an expect like command without a pattern', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.expectLikeCommand());
      final result = parser.parse('expect_like');
      expect(result, isA<Failure>());
    });

    test('fails to parse an expect_like command with an unquoted pattern', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.expectLikeCommand());
      final result = parser.parse('expect_like pattern');
      expect(result, isA<Failure>());
    });
  });

  group('Expect Command Grammar', tags: ['command_grammar'], () {
    test('parses an expect command', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.expectCommand());
      final result = parser.parse('expect "pattern"');
      expect(
        result,
        isA<Success>().having(
          (s) => s.value,
          'value',
          isA<ExpectCommand>().having((c) => c.pattern, 'pattern', 'pattern').having((c) => c.isRegex, 'isRegex', false),
        ),
      );
    });

    test('parses an EXPECT command', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.expectCommand());
      final result = parser.parse('EXPECT "pattern"');
      expect(
        result,
        isA<Success>().having(
          (s) => s.value,
          'value',
          isA<ExpectCommand>().having((c) => c.pattern, 'pattern', 'pattern').having((c) => c.isRegex, 'isRegex', false),
        ),
      );
    });

    test('parses expected command with escaped quotes', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.expectCommand());
      final result = parser.parse('expect "pattern with \\"escaped quotes\\""');
      expect(
        result,
        isA<Success>().having(
          (s) => s.value,
          'value',
          isA<ExpectCommand>().having((c) => c.pattern, 'pattern', 'pattern with "escaped quotes"').having((c) => c.isRegex, 'isRegex', false),
        ),
      );
    });

    test('fails to parse an expect command without the "expect" keyword', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.expectCommand());
      final result = parser.parse('"pattern"');
      expect(result, isA<Failure>());
    });

    test('fails to parse an expect command without a pattern', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.expectCommand());
      final result = parser.parse('expect ');
      expect(result, isA<Failure>());
    });

    test('fails to parse an expect command with an unquoted pattern', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.expectCommand());
      final result = parser.parse('expect pattern');
      expect(result, isA<Failure>());
    });
  });

  group('Send Command Grammar', tags: ['command_grammar'], () {
    test('parses a send command', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.sendCommand());
      final result = parser.parse('send "message"');
      expect(result, isA<Success>().having((s) => s.value, 'value', isA<SendCommand>().having((c) => c.text, 'text', 'message')));
    });

    test('parses a send command with an empty message', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.sendCommand());
      final result = parser.parse('send ""');
      expect(result, isA<Success>().having((s) => s.value, 'value', isA<SendCommand>().having((c) => c.text, 'text', '')));
    });

    test('parses a SEND command', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.sendCommand());
      final result = parser.parse('SEND "message"');
      expect(result, isA<Success>().having((s) => s.value, 'value', isA<SendCommand>().having((c) => c.text, 'text', 'message')));
    });

    test('parses a send command with escaped quotes', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.sendCommand());
      final result = parser.parse('send "message with \\"escaped quotes\\""');
      expect(result, isA<Success>().having((s) => s.value, 'value', isA<SendCommand>().having((c) => c.text, 'text', 'message with "escaped quotes"')));
    });

    test('fails to parse a send command without the "send" keyword', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.sendCommand());
      final result = parser.parse('"message"');
      expect(result, isA<Failure>());
    });

    test('fails to parse a send command without a message', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.sendCommand());
      final result = parser.parse('send ');
      expect(result, isA<Failure>());
    });
  });

  group('Command Grammar', tags: ['command_grammar'], () {
    test('parses send command', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.command());
      final result = parser.parse('send "message"');
      expect(result, isA<Success>().having((s) => s.value, 'value', isA<SendCommand>().having((c) => c.text, 'text', 'message')));
    });

    test('parses an expect command', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.command());
      final result = parser.parse('expect "message"');
      expect(
        result,
        isA<Success>().having(
          (s) => s.value,
          'value',
          isA<ExpectCommand>().having((c) => c.pattern, 'pattern', 'message').having((c) => c.isRegex, 'isRegex', false),
        ),
      );
    });

    test('parses an expect_like command', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.command());
      final result = parser.parse('expect_like "message"');
      expect(
        result,
        isA<Success>().having(
          (s) => s.value,
          'value',
          isA<ExpectCommand>().having((c) => c.pattern, 'pattern', 'message').having((c) => c.isRegex, 'isRegex', true),
        ),
      );
    });

    test('parses a timeout command', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.command());
      final result = parser.parse('timeout 1000');
      expect(result, isA<Success>().having((s) => s.value, 'value', isA<TimeoutCommand>().having((c) => c.seconds, 'seconds', 1000)));
    });

    test('parses a delay command', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.command());
      final result = parser.parse('delay 500');
      expect(result, isA<Success>().having((s) => s.value, 'value', isA<DelayCommand>().having((c) => c.seconds, 'seconds', 500)));
    });

    test('fails to parse an invalid command', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.command());
      final result = parser.parse('invalid "command"');
      expect(result, isA<Failure>());
    });
  });

  group('Line Grammar', tags: ['top_grammar'], () {
    test('parses a line with a single send command', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.line());
      final result = parser.parse('send "message"');
      expect(result, isA<Success>().having((s) => s.value, 'value', isA<SendCommand>().having((c) => c.text, 'text', 'message')));
    });

    test('parses a line with a single expect command', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.line());
      final result = parser.parse('expect "message"');
      expect(
        result,
        isA<Success>().having(
          (s) => s.value,
          'value',
          isA<ExpectCommand>().having((c) => c.pattern, 'pattern', 'message').having((c) => c.isRegex, 'isRegex', false),
        ),
      );
    });

    test('parses a line with a single expect_like command', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.line());
      final result = parser.parse('expect_like "message"');
      expect(
        result,
        isA<Success>().having(
          (s) => s.value,
          'value',
          isA<ExpectCommand>().having((c) => c.pattern, 'pattern', 'message').having((c) => c.isRegex, 'isRegex', true),
        ),
      );
    });

    test('parses a line with a single timeout command', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.line());
      final result = parser.parse('timeout 1000');
      expect(result, isA<Success>().having((s) => s.value, 'value', isA<TimeoutCommand>().having((c) => c.seconds, 'seconds', 1000)));
    });

    test('parses a line with a single delay command', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.line());
      final result = parser.parse('delay 500');
      expect(result, isA<Success>().having((s) => s.value, 'value', isA<DelayCommand>().having((c) => c.seconds, 'seconds', 500)));
    });

    test('parses a line with a comment', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.line());
      final result = parser.parse('# this is a comment');
      expect(result, isA<Success>().having((s) => s.value, 'value', isA<void>()));
    });

    test('parses a line with a comment and a newline', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.line());
      final result = parser.parse('# this is a comment\n');
      expect(result, isA<Success>().having((s) => s.value, 'value', isA<void>()));
    });

    test('parses an empty line', () {
      final grammar = Grammar();
      final parser = grammar.buildFrom(grammar.line());
      final result = parser.parse('\n');
      expect(result, isA<Success>().having((s) => s.value, 'value', isA<void>()));
    });
  });

  group('Script Parser', () {
    test('parses a script with a single line', () {
      final grammar = Grammar();
      final parser = grammar.build();
      final result = parser.parse('send "hello"\n');
      expect(
        result,
        isA<Success>()
            .having((s) => s.value, 'value', isA<List<Command?>>())
            .having((s) => s.value.length, 'length', 1)
            .having((s) => s.value[0], 'first command', isA<SendCommand>()),
      );
    });

    test('parses a script with multiple lines', () {
      final grammar = Grammar();
      final parser = grammar.build();
      final result = parser.parse('send "hello"\nexpect "world"\n');
      expect(
        result,
        isA<Success>()
            .having((s) => s.value, 'value', isA<List<Command?>>())
            .having((s) => s.value.length, 'length', 2)
            .having((s) => s.value[0], 'first command', isA<SendCommand>())
            .having((s) => s.value[1], 'second command', isA<ExpectCommand>()),
      );
    });

    test('parses a script only containing empty lines', () {
      final grammar = Grammar();
      final parser = grammar.build();
      final result = parser.parse('\n\n');
      expect(result, isA<Success>().having((s) => s.value, 'value', isA<List<Command?>>()).having((s) => s.value.length, 'length', 2));
    });

    test('parses a script with empty lines and commands', () {
      final grammar = Grammar();
      final parser = grammar.build();
      final result = parser.parse('\nsend "hello"\n\nexpect "world"\n');
      expect(
        result,
        isA<Success>()
            .having((s) => s.value, 'value', isA<List<Command?>>())
            .having((s) => s.value.length, 'length', 4)
            .having((s) => s.value[0], 'first command', isA<void>())
            .having((s) => s.value[1], 'second command', isA<SendCommand>())
            .having((s) => s.value[2], 'third command', isA<void>())
            .having((s) => s.value[3], 'fourth command', isA<ExpectCommand>()),
      );
    });

    test('parses a script with a trailing empty line', () {
      final grammar = Grammar();
      final parser = grammar.build();
      final result = parser.parse('send "hello"\nexpect "world"\n\n');
      expect(
        result,
        isA<Success>()
            .having((s) => s.value, 'value', isA<List<Command?>>())
            .having((s) => s.value.length, 'length', 3)
            .having((s) => s.value[0], 'first command', isA<SendCommand>())
            .having((s) => s.value[1], 'second command', isA<ExpectCommand>())
            .having((s) => s.value[2], 'third command', isA<void>()),
      );
    });

    test('parses a script with comments', () {
      final grammar = Grammar();
      final parser = grammar.build();
      final result = parser.parse('send "hello" \n# this is a comment\nexpect "world" \n# another comment\n');
      expect(
        result,
        isA<Success>()
            .having((s) => s.value, 'value', isA<List<Command?>>())
            .having((s) => s.value.length, 'length', 4)
            .having((s) => s.value[0], 'first command', isA<SendCommand>())
            .having((s) => s.value[1], 'second command', isA<void>())
            .having((s) => s.value[2], 'third command', isA<ExpectCommand>())
            .having((s) => s.value[3], 'fourth command', isA<void>()),
      );
    });
  });
}
