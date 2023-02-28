import 'package:flutter_test/flutter_test.dart';
import 'package:golain/golain.dart';
import 'package:golain/golain_platform_interface.dart';
import 'package:golain/golain_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockGolainPlatform
    with MockPlatformInterfaceMixin
    implements GolainPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final GolainPlatform initialPlatform = GolainPlatform.instance;

  test('$MethodChannelGolain is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelGolain>());
  });

  test('getPlatformVersion', () async {
    Golain golainPlugin = Golain();
    MockGolainPlatform fakePlatform = MockGolainPlatform();
    GolainPlatform.instance = fakePlatform;

    expect(await golainPlugin.getPlatformVersion(), '42');
  });
}
