
import 'juce_ipc_platform_interface.dart';

class JuceIpc {
  Future<String?> getPlatformVersion() {
    return JuceIpcPlatform.instance.getPlatformVersion();
  }

  Future<num> sayHelloAndReturnCount(String greeting) async {
    return JuceIpcPlatform.instance.sayHelloAndReturnCount(greeting);
  }
}
