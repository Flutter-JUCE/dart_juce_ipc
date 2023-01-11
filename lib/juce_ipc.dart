
import 'juce_ipc_platform_interface.dart';

class JuceIpc {
  Future<String?> getPlatformVersion() {
    return JuceIpcPlatform.instance.getPlatformVersion();
  }
}
