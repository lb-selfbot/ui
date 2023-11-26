import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:lightningui/launching.dart';
import 'package:path/path.dart' as path;

import 'package:lightningui/utils.dart';
import 'package:system_info2/system_info2.dart';

class Paths {
  static String mainFolder = "";
  static String assetsFolder = "";
  static String executableFolder = "";

  static String executablePath = "";

  static String architecture = SysInfo.kernelArchitecture.toLowerCase();

  static Future<void> init() async {
    mainFolder = Utils.getMainFolder().path;

    if (architecture == "x86_64") {
      architecture = "amd64";
    } else if (architecture == "x86") {
      architecture = "386";
    }

    try {
      await createDirectories();
    } catch (e) {
      await FlutterPlatformAlert.showAlert(
        windowTitle: "LightningBot - Error",
        text: "An error occurred.  \n\nError data: ERR_CREATE_DIRS: $e",
        iconStyle: IconStyle.information,
      );
      exit(1);
    }

    final executablesFolder = path.join(mainFolder, "Executables");

    // Ex: assets/executables/windows/amd64
    executableFolder = path.join(
      executablesFolder,
      Platform.operatingSystem,
    );

    if (!Platform.isMacOS) {
      executableFolder = path.join(executableFolder, architecture);
    }

    if (!Directory(executableFolder).existsSync()) {
      await FlutterPlatformAlert.showAlert(
        windowTitle: "LightningBot - Error",
        text: "An error occurred. "
            "\n\nError data: ERR_UNSUPPORTED: $executableFolder",
        iconStyle: IconStyle.information,
      );
      exit(1);
    }

    executablePath = path.join(executableFolder, Launching.getFilename());

    // Load icons
    final logoPNGFile = await File(
      path.join(mainFolder, 'Logo.png'),
    ).create(recursive: true);

    final logoICOFile = await File(
      path.join(mainFolder, 'Logo.ico'),
    ).create(recursive: true);

    final logoPNG = await rootBundle.load('assets/Logo.png');
    final logoICO = await rootBundle.load('assets/Logo.ico');

    await logoPNGFile.writeAsBytes(logoPNG.buffer.asUint8List());
    await logoICOFile.writeAsBytes(logoICO.buffer.asUint8List());
  }

  static String get configFile {
    return path.join(mainFolder, "Config", "config.json");
  }

  static Set<String> get folders {
    return {
      path.join(mainFolder, "Config"),
      path.join(mainFolder, "Animations"),
      path.join(mainFolder, "Dumping"),
      path.join(mainFolder, "Backups"),
      path.join(mainFolder, "Downloads"),
      path.join(mainFolder, "Extensions"),
      path.join(mainFolder, "Executables"),
      path.join(mainFolder, "Executables", "windows"),
      path.join(mainFolder, "Executables", "windows", "amd64"),
      path.join(mainFolder, "Executables", "windows", "386"),
      path.join(mainFolder, "Executables", "linux"),
      path.join(mainFolder, "Executables", "linux", "amd64"),
      path.join(mainFolder, "Executables", "linux", "386"),
      path.join(mainFolder, "Executables", "linux", "arm64"),
      path.join(mainFolder, "Executables", "linux", "arm"),
      path.join(mainFolder, "Executables", "macos"),
    };
  }

  static Future<void> createDirectories() async {
    await Directory(mainFolder).create(recursive: true);

    for (final folder in folders) {
      await Directory(folder).create(recursive: true);
    }
  }

  static void openFolder() {
    if (Platform.isWindows) {
      Process.run("explorer.exe", [mainFolder]);
    } else if (Platform.isLinux) {
      Process.run("xdg-open", [mainFolder]);
    } else if (Platform.isMacOS) {
      Process.run("open", [mainFolder]);
    }
  }
}
