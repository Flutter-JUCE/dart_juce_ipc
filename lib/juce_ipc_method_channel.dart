import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'juce_ipc_platform_interface.dart';

/// An implementation of [JuceIpcPlatform] that uses method channels.
class MethodChannelJuceIpc extends JuceIpcPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('juce_ipc');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<num> sayHelloAndReturnCount(String greeting) async {
    final count = await methodChannel.invokeMethod<num>('sayHelloAndReturnCount');
    return count!;
  }
}
