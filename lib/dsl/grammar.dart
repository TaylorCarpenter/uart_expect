import 'package:petitparser/petitparser.dart';

import 'commands.dart';

class Grammar extends GrammarDefinition {
  // dart format off
  // region Top Parsers
  @override
  Parser start() => ref0(script).end();

  Parser<List<Command?>> script() => ref0(line).plus();

  Parser<Command?> line() => [
      ref0(comment).map((_) => null),
      ref0(command),
      ref0(empty).map((_) => null),
    ]
    .toChoiceParser()
    .then(pattern(' \t').star())
    .then(ref0(comment).optional())
            .then(char('\n').optional())
        .map((parts) => parts.$1);

  // endregion Top Parsers
  // region Command Parsers

  Parser<Command?> command() => [
      ref0(sendCommand),
      ref0(expectCommand),
      ref0(expectLikeCommand),
      ref0(timeoutCommand),
      ref0(delayCommand),
  ].toChoiceParser();

  Parser<Command> sendCommand() => string('send', ignoreCase: true)
      .then(whitespace().plus())
      .then(ref0(quotedString))
         .map((values) => SendCommand(values.$3));

  Parser<Command> expectCommand() => string('expect', ignoreCase: true)
      .then(whitespace().plus())
      .then(ref0(quotedString))
         .map((values) => ExpectCommand(values.$3));

  Parser<Command> expectLikeCommand() => string('expect_like', ignoreCase: true)
      .then(whitespace().plus())
      .then(ref0(quotedString))
         .map((values) => ExpectCommand(values.$3, isRegex: true));

  Parser<Command> timeoutCommand() => string('timeout', ignoreCase: true)
      .then(whitespace().plus())
      .then(ref0(number))
         .map((values) => TimeoutCommand(values.$3));

  Parser<Command> delayCommand() => string('delay', ignoreCase: true)
      .then(whitespace().plus())
      .then(ref0(number))
         .map((values) => DelayCommand(values.$3));
  // endregion Command Parsers

  // region Basic Parsers
  Parser comment() => char('#')
      .then(any().where((value) => value != '\n').star());

  Parser empty() => whitespace().starLazy(char('\n')).map((_)=>'');

  Parser<String> quotedString() => char('"')
      .then(ref0(character).star())
      .then(char('"'))
        .map((parts) => parts.$2.join());

  Parser<String> character() => [
          ref0(escapedQuote),
          ref0(plainCharacter),
      ].toChoiceParser();

  Parser<String> escapedQuote() => char('\\').then(char('"')).map((_) => '"');
  Parser<String> plainCharacter() => any().where((value) => value != '"');
  Parser<int> number() => digit().plus().flatten().map(int.parse);
  // endregion Basic Parsers

  // dart format on
}
