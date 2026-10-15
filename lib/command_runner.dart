import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';

class CommandRunner {
  final StreamQueue _incomingData;
  final Sink<String> _outgoingData;

  var _currentBuffer = '';

  CommandRunner(Stream<String> inputStream, this._outgoingData) : _incomingData = StreamQueue(inputStream);

  void send(String data) {
    print('--> Sending: $data');
    _outgoingData.add(data);
  }

  Future<void> expect(Pattern expectedPattern, {Duration timeout = const Duration(seconds: 5)}) async {
    print('... Waiting for: $expectedPattern');
    final stopwatch = Stopwatch()..start();

    // Check if the pattern is already sitting in the buffer
    if (_checkBufferMatch(expectedPattern)) return;

    // Loop and ingest the stream data chunks sequentially
    while (stopwatch.elapsed < timeout) {
      final remainingTime = timeout - stopwatch.elapsed;

      try {
        // Wait for the next incoming chunk of text from the stream
        if (await _incomingData.hasNext.timeout(remainingTime)) {
          final chunk = await _incomingData.next;
          _currentBuffer += chunk;

          // Print incoming stream to console (like a real minicom terminal session)
          print('<-- $chunk'.trimRight());

          // Check if we hit our expected text match
          if (_checkBufferMatch(expectedPattern)) {
            return;
          }
        }
      } on TimeoutException {
        throw TimeoutException('Timed out waiting for "$expectedPattern"');
      }
    }
    throw TimeoutException('Timed out waiting for "$expectedPattern"');
  }

  bool _checkBufferMatch(Pattern pattern) {
    final match =
        pattern.matchAsPrefix(_currentBuffer) ??
        (pattern is RegExp ? pattern.firstMatch(_currentBuffer) : null) ??
        (_currentBuffer.contains(pattern) ? true : null);

    if (match != null) {
      // Clean or consume the buffer up to the matched sequence if desired
      if (match is Match) {
        _currentBuffer = _currentBuffer.substring(match.end);
      } else if (pattern is String) {
        final index = _currentBuffer.indexOf(pattern);
        _currentBuffer = _currentBuffer.substring(index + pattern.length);
      }
      return true;
    }
    return false;
  }
}

class SocketRunner extends CommandRunner {
  SocketRunner(Socket socket) : super(utf8.decoder.bind(socket), utf8.encoder.startChunkedConversion(socket));
}
