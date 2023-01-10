import 'dart:convert';
import 'dart:io';

import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:lightningui/ipc.dart';
import 'package:lightningui/paths.dart';

class Config {
  static DateTime lastConfigUpdate = DateTime.fromMicrosecondsSinceEpoch(0);

  static Map<String, dynamic> _config = {};

  static Map<String, dynamic> get config {
    if (DateTime.now().difference(lastConfigUpdate).inSeconds < 10) {
      return _config;
    }

    final configFile = File(Paths.configFile);

    if (!configFile.existsSync()) {
      FlutterPlatformAlert.showAlert(
        windowTitle: "LightningBot - Error",
        text: "An error occurred: config.json does not exist.",
        iconStyle: IconStyle.information,
      );
      return {};
    }

    _config = json.decode(configFile.readAsStringSync());

    return _config;
  }

  static set config(Map<String, dynamic> value) {
    _config = value;

    lastConfigUpdate = DateTime.now();

    IPC.send({'op': OP.configUpdate, 'data': value});

    final configFile = File(Paths.configFile);

    final json = const JsonEncoder.withIndent("  ").convert(value);

    configFile.writeAsStringSync(json);
  }
}
