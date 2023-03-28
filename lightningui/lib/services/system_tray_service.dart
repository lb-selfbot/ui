import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:system_tray/system_tray.dart';
import 'package:path/path.dart' as path;

import 'package:lightningui/utils.dart';

class SystemTrayService {
  SystemTray systemTray = SystemTray();
  String iconPath = "";

  SystemTrayService() {
    iconPath = path.join(Utils.getMainFolder().path, "Logo");

    iconPath += Platform.isWindows ? ".ico" : ".png";

    systemTray.registerSystemTrayEventHandler(systemTrayHandler);
  }

  Future<void> show() async {
    await systemTray.initSystemTray(
      iconPath: iconPath,
      title: "LightningBot",
      toolTip: "LightningBot",
    );
  }

  Future<void> hide() async {
    await systemTray.destroy();
  }

  void systemTrayHandler(String eventName) {
    if (eventName != "click") {
      return;
    }

    hide();
    appWindow.show();
  }
}
