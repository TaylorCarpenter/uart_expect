abstract class Command {}

class SendCommand extends Command {
  final String text;
  SendCommand(this.text);
}

class ExpectCommand extends Command {
  final String pattern;
  final bool isRegex;
  ExpectCommand(this.pattern, {this.isRegex = false});
}

class TimeoutCommand extends Command {
  final int seconds;
  TimeoutCommand(this.seconds);
}

class DelayCommand extends Command {
  final int seconds;
  DelayCommand(this.seconds);
}
