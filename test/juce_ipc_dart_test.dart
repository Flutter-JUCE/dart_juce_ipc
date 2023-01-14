@Timeout(const Duration(seconds: 1))
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:juce_ipc/juce_ipc.dart';
import 'package:test/test.dart';
import 'dart:convert';

Future<void> performTest(JuceInterprocessConnection interprocess) async {
  final receivedMessages = interprocess.read.transform(utf8.decoder).toList();

  interprocess.write.write('1');
  interprocess.write.write('2');
  interprocess.write.write('3');

  await interprocess.write.flush();
  await interprocess.write.close();

  expect(await receivedMessages, ['1', '2', '3']);
}

void main() {
  setUp(() {});

  tearDown(() {});

  test('InterprocessConnection using named pipe', () async {
    final interprocess = JuceInterprocessConnectionNamedPipe("test-pipe");
    await performTest(interprocess);
  });
}
