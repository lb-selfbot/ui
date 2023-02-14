import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:lightningui/ipc.dart';
import 'package:lightningui/paths.dart';

class Config extends ChangeNotifier {
  DateTime lastUpdate = DateTime.fromMicrosecondsSinceEpoch(0);

  Map<String, dynamic> cachedConfig = {};

  Map<String, dynamic> get config {
    if (DateTime.now().difference(lastUpdate).inSeconds < 10) {
      return cachedConfig;
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

    cachedConfig = json.decode(configFile.readAsStringSync());

    lastUpdate = DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    return cachedConfig;
  }

  set config(Map<String, dynamic> value) {
    cachedConfig = value;

    lastUpdate = DateTime.now();

    IPC.send({'op': OP.configUpdate, 'data': value});

    final configFile = File(Paths.configFile);

    final json = const JsonEncoder.withIndent("  ").convert(value);

    configFile.writeAsStringSync(json);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
