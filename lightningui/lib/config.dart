import 'dart:convert';
import 'dart:io';

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
      // TODO: error
      return {};
    }
    _config = json.decode(configFile.readAsStringSync());
    return _config;
  }

  static set config(Map<String, dynamic> value) {
    final configFile = File(Paths.configFile);
    configFile
        .writeAsStringSync(const JsonEncoder.withIndent("  ").convert(value));
    _config = value;
    lastConfigUpdate = DateTime.now();
    IPC.send({'op': OP.configUpdate, 'data': value});
  }
}
