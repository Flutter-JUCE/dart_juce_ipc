import "dart:async";
import "dart:convert";

import "package:juce_ipc/src/child_process_worker.dart";
import "package:juce_ipc/src/interprocess_connection.dart";
import "package:juce_ipc/src/path.dart";
import "package:logging/logging.dart";
import "package:path/path.dart" as p;
import "package:stdlibc/stdlibc.dart";
import "package:test/test.dart";

void main() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print("${record.level.name}: ${record.time}: ${record.message}");
  });

  const pipeName = "p0000000000000000";
  late InterprocessConnectionNamedPipe coordinatorOutPipe;
  late InterprocessConnectionNamedPipe coordinatorInPipe;

  setUp(() async {
    final path = getTemporaryDirectory();

    final coordinatorOutPath = p.join(path, "${pipeName}_out");
    final coordinatorInPath = p.join(path, "${pipeName}_in");

    const rwMode = 6 << 6 | 0 << 3 | 0 << 0;
    mkfifo(coordinatorOutPath, rwMode);
    mkfifo(coordinatorInPath, rwMode);

    coordinatorOutPipe = InterprocessConnectionNamedPipe(
      coordinatorOutPath,
      magic: kConnectionMagic,
    );
    coordinatorInPipe = InterprocessConnectionNamedPipe(
      coordinatorInPath,
      magic: kConnectionMagic,
    );
  });

  tearDown(() async {
    await coordinatorOutPipe.pipe.delete();
    await coordinatorInPipe.pipe.delete();
  });

  test("factory times out if coordinator does not send start message",
      () async {
    final args = <String>["--ID:p0000000000000000"];
    final worker = ChildProcessWorker.fromCommandLineArguments(
      args,
      uniqueId: "ID",
      timeout: const Duration(milliseconds: 100),
    );

    final lateStartMessageSent = Future.microtask(() async {
      coordinatorOutPipe.write.add(
        await Future.delayed(
          const Duration(milliseconds: 200),
          () => utf8.encode(kStartMessage),
        ),
      );
    });

    await expectLater(worker, throwsA(isA<TimeoutException>()));
    await lateStartMessageSent;
    await coordinatorOutPipe.write.close();
  });

  test("factory completes after receiving start message", () async {
    final args = <String>["--ID:p0000000000000000"];
    final worker = ChildProcessWorker.fromCommandLineArguments(
      args,
      uniqueId: "ID",
    );

    coordinatorOutPipe.write.add(utf8.encode(kStartMessage));

    final workerValue = await worker;
    expect(workerValue, isNotNull);

    coordinatorOutPipe.write.add(utf8.encode("hello world"));
    await coordinatorOutPipe.write.flush();
    await coordinatorOutPipe.write.close();

    final data = await workerValue!.read.toList();
    expect(data, hasLength(1));
    expect(utf8.decode(data.first), "hello world");
  });

  test("ping messages are filtered out", () async {
    final args = <String>["--ID:p0000000000000000"];
    final worker = ChildProcessWorker.fromCommandLineArguments(
      args,
      uniqueId: "ID",
      timeout: const Duration(milliseconds: 100),
    );

    coordinatorOutPipe.write.add(utf8.encode(kStartMessage));

    final workerValue = await worker;
    expect(workerValue, isNotNull);

    coordinatorOutPipe.write.add(utf8.encode(kPingMessage));
    await coordinatorOutPipe.write.flush();
    await coordinatorOutPipe.write.close();

    final data = await workerValue!.read.toList();
    expect(data, hasLength(0));
  });

  test("Responds to ping messages", () async {
    final args = <String>["--ID:p0000000000000000"];
    final worker = ChildProcessWorker.fromCommandLineArguments(
      args,
      uniqueId: "ID",
      timeout: const Duration(milliseconds: 100),
    );

    coordinatorOutPipe.write.add(utf8.encode(kStartMessage));
    final childOutput = coordinatorInPipe.read.toList();

    final workerValue = await worker;
    expect(workerValue, isNotNull);

    coordinatorOutPipe.write.add(utf8.encode(kPingMessage));
    await coordinatorOutPipe.write.flush();
    await coordinatorOutPipe.write.close();

    // Time for child to receive the ping message and send the response before
    // its write sink is closed by the test.
    await Future<void>.delayed(const Duration(milliseconds: 50));

    unawaited(workerValue!.write.close());

    expect(await childOutput, [utf8.encode(kPingMessage)]);
  });

  // TODO detect coordinator not responding
}
