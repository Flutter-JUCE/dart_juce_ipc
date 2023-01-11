import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juce_ipc/juce_ipc_method_channel.dart';

void main() {
  MethodChannelJuceIpc platform = MethodChannelJuceIpc();
  const MethodChannel channel = MethodChannel('juce_ipc');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
