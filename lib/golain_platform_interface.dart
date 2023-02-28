import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'golain_method_channel.dart';

abstract class GolainPlatform extends PlatformInterface {
  /// Constructs a GolainPlatform.
  GolainPlatform() : super(token: _token);

  static final Object _token = Object();

  static GolainPlatform _instance = MethodChannelGolain();

  /// The default instance of [GolainPlatform] to use.
  ///
  /// Defaults to [MethodChannelGolain].
  static GolainPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [GolainPlatform] when
  /// they register themselves.
  static set instance(GolainPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
