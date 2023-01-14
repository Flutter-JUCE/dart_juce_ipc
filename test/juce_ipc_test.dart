import 'dart:async';

import 'package:dcli_core/dcli_core.dart';
import 'package:juce_ipc/juce_ipc.dart';
import 'package:stdlibc/stdlibc.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;
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
  test('InterprocessConnection using named pipe', () async {
    await withTempDir((dir) async {
      final pipePath = p.join(dir, "test-named-pipe");
      mkfifo(pipePath, (6 << 6) | (0 << 3) | 0);
      final interprocess = JuceInterprocessConnectionNamedPipe(pipePath);
      await performTest(interprocess);
    });
  });
}
