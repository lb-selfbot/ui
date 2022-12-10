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

    if (Platform.environment['FLUTTER_ROOT'] != null) {
      // Debugging assets path
      assetsFolder = path.join(Directory.current.path, "assets");
    } else {
      // Release assets path
      assetsFolder = path.join(
        Directory.current.path,
        "data",
        "flutter_assets",
        "assets",
      );
    }

    // Ex: assets/executables/windows/amd64
    executableFolder = path.join(
      assetsFolder,
      "executables",
      Platform.operatingSystem,
    );
    if (!Platform.isMacOS) {
      executableFolder = path.join(executableFolder, Launching.architecture);
    }

    final executableDirectory = Directory(executableFolder);

    if (!executableDirectory.existsSync()) {
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
