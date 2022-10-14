import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:lightningui/config.dart';
import 'package:lightningui/ipc.dart';
import 'package:lightningui/paths.dart';
import 'package:path_provider/path_provider.dart';

class Launching {
  static String pathSeperator = "";

  static String documentsDirectory = "";
  static String applicationDirectory = "";
  static String assetsDirectory = "";
  static String executableDirectory = "";

  static bool isFirstLaunch = false;

  static Future<void> init() async {
    pathSeperator = Platform.pathSeparator;
    documentsDirectory = (await getApplicationDocumentsDirectory()).path;
    applicationDirectory = (await getApplicationSupportDirectory()).path;
    assetsDirectory =
        "${Directory.current.path}${pathSeperator}data${pathSeperator}flutter_assets${pathSeperator}assets";

    if (!await Directory(assetsDirectory).exists()) {
      assetsDirectory =
          "${Directory.current.path}${pathSeperator}build${pathSeperator}windows${pathSeperator}runner${pathSeperator}Debug${pathSeperator}data${pathSeperator}flutter_assets${pathSeperator}assets";
    }
    executableDirectory = "$assetsDirectory${pathSeperator}main.exe";

    Paths.init(pathSeperator, documentsDirectory, applicationDirectory);
    Paths.createDirectories();

    isFirstLaunch = await checkIsFirstLaunch();

    if (isFirstLaunch) {
      await createConfig();
    } else {
      await checkConfig();
    }
  }

  static Future<bool> checkIsFirstLaunch() async {
    final configFileExists = await File(Paths.configFile).exists();
    return !configFileExists;
  }

  static void launch({bool force = false}) async {
    if (!IPC.websocketConnected || force) {
      await Process.start(executableDirectory, ["-l"]);
    }
  }

  static void onLogin(String username, String password) {
    final config = Config.config;
    config["Account"]["LightningBot"]["Username"] = username;
    config["Account"]["LightningBot"]["Password"] = password;
    Config.config = config;
  }

  static bool shouldLogin() {
    if (isFirstLaunch) {
      return true;
    }

    if (Config.config["Account"]["LightningBot"]["Username"] == "") {
      return true;
    }

    if (Config.config["Account"]["LightningBot"]["Password"] == "") {
      return true;
    }

    return false;
  }

  static Future<void> createConfig() async {
    final config = await rootBundle.loadString("assets/defaultConfig.json");
    await File(Paths.configFile).writeAsString(config);
  }

  static Future<void> checkConfig() async {
    // Load the default and current config
    final defaultConfigText = await rootBundle.loadString(
      "assets/defaultConfig.json",
    );
    final configText = await File(Paths.configFile).readAsString();

    final defaultConfig = jsonDecode(defaultConfigText) as Map<String, dynamic>;
    final config = jsonDecode(configText) as Map<String, dynamic>;

    bool changed = false;

    for (final key in defaultConfig.keys) {
      // Check if all keys in defaultConfig also exist in config
      // If not, copy from defaultConfig to config
      if (!config.containsKey(key)) {
        config[key] = defaultConfig[key];
        changed = true;
      }
      // If the key is a map, also check the subkeys
      if (defaultConfig[key] is Map<String, dynamic>) {
        for (final subKey in defaultConfig[key].keys) {
          // Check if all keys in defaultConfig[key] also exist in config
          // If not, copy from defaultConfig to config
          if (!config[key].containsKey(subKey)) {
            config[key][subKey] = defaultConfig[key][subKey];
            changed = true;
          }
        }
      }
    }

    if (changed) {
      // Save config using Config class so we don't have to read it again
      Config.config = config;
    }
  }
}
