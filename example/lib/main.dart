import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:juce_ipc/juce_ipc.dart';
import 'package:logging/logging.dart';

final _log = Logger('juce_ipc_example');

void main(List<String> args) async {
  // When started by JUCE, the stdout logs are not visible. They can be seen in
  // this file instead.
  final file = File('/tmp/flutter-args').openWrite();

  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen((record) {
    final String message =
        "${record.loggerName}: ${record.level.name}: ${record.time}: ${record.message}";
    file.writeln(message);
    debugPrint(message);
  });

  runZonedGuarded(
    () async {
      _log.info("=== Starting up at ${DateTime.now()} ===");
      _log.info("args: $args");

      final coordinatorDone = Future.microtask(() async {
        final worker = await ChildProcessWorker.fromCommandLineArguments(
            uniqueId: "demoUID", args);
        if (worker == null) {
          _log.info("Failed to create worker from command line");
          return;
        }

        // TODO implement the same behaviour as the original JUCE example
        worker.write.write("hello world");
        await worker.read.transform(utf8.decoder).forEach(_log.info);
      });

      runApp(const MyApp());

      await coordinatorDone;
      await file.flush();
      await file.close();
    },
    (error, stack) => _log.severe("Unhandled Exception: $error\n$stack"),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: const Center(
          child: Text(''),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
        ),
      ),
    );
  }
}
