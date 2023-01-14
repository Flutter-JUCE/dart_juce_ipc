import 'dart:async';
import 'dart:ffi';

import 'juce_ipc_platform_interface.dart';

// The proposed high level API to be consumed by users, and designed only for
// usability, not convenience in the internal low levels
/*

// TODO is it a good idea to implement Pipe, when the semantics are different?
abstract class JuceIpcUserInterface implements Pipe {
  JuceIpcUserInterface({required this.pipeName});

  final String pipeName;

  // Read messages from JUCE
  ReadPipe read;

  // Send messages to JUCE
  WritePipe write;
}
 */

class JuceIpc {
  Future<String?> getPlatformVersion() {
    return JuceIpcPlatform.instance.getPlatformVersion();
  }

  Future<num> sayHelloAndReturnCount(String greeting) async {
    return JuceIpcPlatform.instance.sayHelloAndReturnCount(greeting);
  }
}
