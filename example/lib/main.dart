import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:juce_ipc/juce_ipc.dart';
import 'package:logging/logging.dart';
import 'package:xml/xml.dart';

final _log = Logger('juce_ipc_example');

void main(List<String> args) async {
  // When started by JUCE, the stdout logs are not visible. They can be seen in
  // this file instead.
  final file = File('/tmp/juce_ipc_logs').openWrite();

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

        await for (final e in worker.read) {
          final document = XmlDocument.parse(utf8.decode(e));
          final count = int.tryParse(document.rootElement.attributes[0].value)!;

          final replyBuilder = XmlBuilder();
          replyBuilder.element("REPLY",
              nest: () => replyBuilder.attribute("countPlusOne", count + 1));

          final reply = replyBuilder.buildDocument().toString();
          worker.write.write(reply);
        }

        worker.write.close();
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
      ),
    );
  }
}
