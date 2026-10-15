import 'package:petitparser/petitparser.dart';

import 'command_runner.dart';
import 'dsl/commands.dart';
import 'dsl/grammar.dart';

Future<void> runScript(CommandRunner commandRunner, String script) async {
  final parser = Grammar().build();
  final result = parser.parse(script);

  if (result is Failure) {
    throw FormatException('Failed to parse script: ${result.message}');
  }

  // Filter out comments/empty lines, leaving only executable commands
  final commands = result.value.expand((e) => e is List ? e : [e]).whereType<Command>().toList();

  var currentTimeout = const Duration(seconds: 5);
  for (final command in commands) {
    switch (command) {
      case SendCommand sendCommand:
        commandRunner.send(sendCommand.text);
      case ExpectCommand expectCommand:
        final pattern = expectCommand.isRegex ? RegExp(expectCommand.pattern) : expectCommand.pattern;
        await commandRunner.expect(pattern, timeout: currentTimeout);
      case DelayCommand delayCommand:
        print('... Delaying for ${delayCommand.seconds} seconds');
        await Future.delayed(Duration(seconds: delayCommand.seconds));
      case TimeoutCommand timeoutCommand:
        currentTimeout = Duration(seconds: timeoutCommand.seconds);
        print('... Setting timeout to ${timeoutCommand.seconds} seconds');
    }
  }
}
