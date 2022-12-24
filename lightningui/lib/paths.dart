import 'dart:io';

import 'package:lightningui/launching.dart';
import 'package:path/path.dart' as path;

import 'package:lightningui/utils.dart';

class Paths {
  static String mainFolder = "";
  static String assetsFolder = "";
  static String executableFolder = "";

  static String executablePath = "";

  static void init() {
    mainFolder = Utils.getMainFolder().path;

    createDirectories();

    final executablesFolder = path.join(mainFolder, "Executables");

    // Ex: assets/executables/windows/amd64
    executableFolder = path.join(
      executablesFolder,
      Platform.operatingSystem,
    );

    if (!Platform.isMacOS) {
      executableFolder = path.join(executableFolder, Launching.architecture);
    }

    if (!Directory(executableFolder).existsSync()) {
      // TODO: error, unsupported os/architecture
      return;
    }

    executablePath = path.join(executableFolder, Launching.getFilename());
  }

  static String get configFile {
    return path.join(mainFolder, "Config", "config.json");
  }

  static Set<String> get folders {
    return {
      path.join(mainFolder, "Config"),
      path.join(mainFolder, "Animations"),
      path.join(mainFolder, "Dumping"),
      path.join(mainFolder, "Downloads"),
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

  static bool createDirectories() {
    try {
      Directory(mainFolder).createSync(recursive: true);

      for (final folder in folders) {
        Directory(folder).createSync(recursive: true);
      }
    } catch (e) {
      // TODO: Handle error
      return false;
    }
    return true;
  }
}
