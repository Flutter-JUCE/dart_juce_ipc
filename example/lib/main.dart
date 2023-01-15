import 'dart:io';

import 'package:flutter/material.dart';
import 'package:juce_ipc/juce_ipc.dart';

void main(List<String> args) async {
  debugPrint(args.toString());
  // TODO check for matching UID, dashes at front
  final pipeName = args.first.split(":").last;

  final file = File('/tmp/flutter-args').openWrite();
  file.write("=== Starting up at ${DateTime.now()} ===");
  file.write("\n");
  file.writeAll(args, "<|>");
  file.write("\n");
  file.write(pipeName);
  file.write("\n");
  final interprocess = JuceInterprocessConnectionNamedPipe(pipeName);
  final interprocessDone = file.addStream(interprocess.read);

  runApp(const MyApp());

  debugPrint("after run app");
  await interprocessDone;
  await file.flush();
  await file.close();
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
