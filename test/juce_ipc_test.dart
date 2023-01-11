import 'package:flutter_test/flutter_test.dart';
import 'package:juce_ipc/juce_ipc.dart';
import 'package:juce_ipc/juce_ipc_platform_interface.dart';
import 'package:juce_ipc/juce_ipc_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockJuceIpcPlatform
    with MockPlatformInterfaceMixin
    implements JuceIpcPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final JuceIpcPlatform initialPlatform = JuceIpcPlatform.instance;

  test('$MethodChannelJuceIpc is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelJuceIpc>());
  });

  test('getPlatformVersion', () async {
    JuceIpc juceIpcPlugin = JuceIpc();
    MockJuceIpcPlatform fakePlatform = MockJuceIpcPlatform();
    JuceIpcPlatform.instance = fakePlatform;

    expect(await juceIpcPlugin.getPlatformVersion(), '42');
  });
}
