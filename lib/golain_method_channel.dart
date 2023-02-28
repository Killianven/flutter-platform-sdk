import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'golain_platform_interface.dart';

/// An implementation of [GolainPlatform] that uses method channels.
class MethodChannelGolain extends GolainPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('golain');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
