import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:system_tray/system_tray.dart' as system_tray;
import 'package:path/path.dart' as path;

import 'package:lightningui/utils.dart';

class SystemTray {
  static system_tray.SystemTray systemTray = system_tray.SystemTray();
  static String iconPath = "";

  static Future<void> init() async {
    iconPath = path.join(Utils.getMainFolder().path, "Logo");

    if (Platform.isWindows) {
      iconPath += ".ico";
    } else {
      iconPath += ".png";
    }

    systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == "click") {
        hide();
        appWindow.show();
      }
    });
  }

  static Future<void> show() async {
    await systemTray.initSystemTray(
      iconPath: iconPath,
      title: "LightningBot",
      toolTip: "LightningBot",
    );
  }

  static Future<void> hide() async {
    await systemTray.destroy();
  }
}
