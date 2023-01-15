import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:juce_ipc/juce_ipc.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
// TODO move path to the library
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

final _log = Logger('juce_ipc_example');

void main(List<String> args) async {
  // When started by JUCE, the stdout logs are not visible. They can be seen in
  // this file instead.
  final file = File('/tmp/flutter-args').openWrite();

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    final String message =
        "${record.level.name}: ${record.time}: ${record.message}";
    file.writeln(message);
    debugPrint(message);
  });

  runZonedGuarded(
    () async {
      _log.info("=== Starting up at ${DateTime.now()} ===");

      // TODO check for matching UID, dashes at front
      final pipeName = args.first.split(":").last;

      _log.info("args: $args");
      _log.info("pipeName: $pipeName");

      const magicCoordWorkerConnectionHeader = 0x712baf04;
      // TODO:
      // * join with temp path should be done in the library, as it's a
      //   requirement that we must use the same path as JUCE
      // * Add tests for all platforms that JUCE and path_provider return the same
      //   path
      // * Maybe modify JUCE Coordinator to send the absolute path for simplicity.
      //   This would be worse for the users though
      final interprocess = JuceInterprocessConnectionNamedPipe(
          p.join((await getTemporaryDirectory()).path, "${pipeName}_out"),
          magic: magicCoordWorkerConnectionHeader);

      final interprocessDone = interprocess.read.forEach(_log.info);

      // TODO need a second connection for writing back

      runApp(const MyApp());

      _log.info("after run app");
      await interprocessDone;
      await file.flush();
      await file.close();
      _log.info("main done");
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
