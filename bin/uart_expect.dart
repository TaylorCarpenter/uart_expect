import 'package:uart_expect/command_runner.dart';

import 'dart:io';

import 'package:uart_expect/uart_expect.dart';

void main(List<String> arguments) async {
  final uartSocket = await Socket.connect('localhost', 12345);
  final commandRunner = SocketRunner(uartSocket);

  const script = '''
#EXPECT_LIKE "Dispensing Cabinet Controller firmware v\\d+.\\d+.\\d+"
#EXPECT "Type HELP for a list of commands."

SEND "HELP\n"
EXPECT "HELP"
EXPECT "Commands:\r
  HELP - list available commands\r
  STAT - device status summary\r
  BIN - LIST | GET <id> | LOCK <id>\r
  DISPENSE - <bin_id> <qty> [operator] - dispense from a bin\r
  RESTOCK - <bin_id> <qty> [operator] - add stock to a bin\r
  LOG - [count] - recent dispense/restock events\r
  CFG - GET | SET <param> <value> - cabinet configuration\r
  DIAG - [filter] - diagnostic log, includes low-stock bins\r
  RESET - relock all bins\r
  SELFTEST - run device self-test\r
  THRESHOLD - SET <bin> <level> | GET <bin> - restock alert threshold\r"

SEND "STAT\n"
EXPECT_LIKE "ATmodel=Dispensing Cabinet Controller fw=\\d+.\\d+.\\d+ uptime_s=\\d+ unlocked_bins=\\d+"

SEND "BIN LIST\n"
EXPECT_LIKE "(\\w\\d - \\w+ \\d+[mg/l]+ count=\\d+ par=\\d+ max=\\d+ lock=LOCKED|UNLOCKED\r\n)+"

SEND "BIN GET A1\n"
EXPECT_LIKE "A1 - \\w+ \\d+[mg/l]+ count=\\d+ par=\\d+ max=\\d+ lock=LOCKED|UNLOCKED"

SEND "BIN LOCK A1\n"
EXPECT "OK"

SEND "DISPENSE A1 10\n"
EXPECT "OK dispensed"

SEND "NOT_A_COMMAND\n"
EXPECT "ERR unknown command"

SEND "RESTOCK A1 10\n"
EXPECT "OK restocked"

SEND "LOG 2\n"
EXPECT_LIKE "t_ms=\\d+ bin=\\w\\d action=\\w+ qty=\\d+ operator=\\w* count=\\d+"

SEND "CFG GET\n"
EXPECT_LIKE "low_stock_pct=\\d+ door_auto_relock_s=\\d+"

SEND "CFG SET door_auto_relock_s 30\n"
EXPECT "OK"

SEND "CFG GET\n"
EXPECT_LIKE "low_stock_pct=\\d+ door_auto_relock_s=30"

SEND "DIAG\n"
EXPECT_LIKE "uart0 status=\\w+\r
systick status=\\w+\r
config store status=\\w+\r
log capacity=\\d+\r
watchdog=\\w+"

SEND "RESET\n"
EXPECT "OK reset"

SEND "SELFTEST\n"
EXPECT "uart=PASS systick=PASS config=PASS log=PASS"

SEND "THRESHOLD GET A1\n"
EXPECT_LIKE "threshold=\\d+"

SEND "THRESHOLD SET A1 50\n"
EXPECT "OK"

SEND "THRESHOLD GET A1\n"
EXPECT_LIKE "threshold=50"

SEND "THRESHOLD SET\n"
EXPECT "ERR missing bin_id or level"

SEND "THRESHOLD SET A9 10\n"
EXPECT "ERR unknown bin"

SEND "THRESHOLD BLAH\n"
EXPECT "unknown THRESHOLD subcommand (SET <bin> <level> | GET <bin>)"
''';

  await runScript(commandRunner, script);
  print('Script execution completed.');

  uartSocket.destroy();
}
