import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';


import 'package:flutter/services.dart';
import 'package:juce_ipc/juce_ipc.dart';

void main() async {
  print("demo using File");
  File('/tmp/juce-test-pipe').openRead().transform(utf8.decoder).listen(
        (String character) {
      print(character);
    },
    onDone: () => print('File StreamSubscription closing'),
  );

  IOSink writeSink = File('/tmp/juce-test-pipe').openWrite();

  writeSink.write('File 1');
  writeSink.write('File 2');
  writeSink.write('File 3');
  await writeSink.flush();
  await writeSink.close();

  print("demo using Interprocess");
  final interprocess = JuceInterprocessConnectionNamedPipe('/tmp/pipe');
  interprocess.read.transform(utf8.decoder).listen(
        (String character) {
      print(character);
    },
    onDone: () => print('Interprocess StreamSubscription closing'),
  );

  interprocess.write.write('Interprocess 4');
  interprocess.write.write('Interprocess 5');
  interprocess.write.write('Interprocess 6');
  await interprocess.write.flush();
  await interprocess.write.close();

  runApp(const MyApp());
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
        body: Center(
          child: Text(''),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final count = _juceIpcPlugin.sayHelloAndReturnCount("Hello World");
            count.then((count) => debugPrint('count: $count'));
          },
        ),
      ),
    );
  }
}
