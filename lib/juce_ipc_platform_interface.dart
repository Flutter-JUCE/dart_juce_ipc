import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'juce_ipc_method_channel.dart';

abstract class JuceIpcPlatform extends PlatformInterface {
  /// Constructs a JuceIpcPlatform.
  JuceIpcPlatform() : super(token: _token);

  static final Object _token = Object();

  static JuceIpcPlatform _instance = MethodChannelJuceIpc();

  /// The default instance of [JuceIpcPlatform] to use.
  ///
  /// Defaults to [MethodChannelJuceIpc].
  static JuceIpcPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [JuceIpcPlatform] when
  /// they register themselves.
  static set instance(JuceIpcPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion();

  Future<num> sayHelloAndReturnCount(String greeting);
}
