import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:lightningui/api.dart';
import 'package:lightningui/config.dart';
import 'package:lightningui/ipc.dart';
import 'package:lightningui/paths.dart';
import 'package:lightningui/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:system_info2/system_info2.dart';

class Launching {
  static String pathSeperator = "";

  static String documentsDirectory = "";
  static String applicationDirectory = "";
  static String executableVersion = "";

  static String architecture = SysInfo.kernelArchitecture.toLowerCase();

  static bool isFirstLaunch = false;
  static bool isDownloading = false;

  static Future<void> init() async {
    pathSeperator = Platform.pathSeparator;
    documentsDirectory = (await getApplicationDocumentsDirectory()).path;
    applicationDirectory = (await getApplicationSupportDirectory()).path;

    if (architecture == "x86_64") {
      architecture = "amd64";
    } else if (architecture == "x86") {
      architecture = "386";
    }

    Paths.init();

    executableVersion = await getExecutableVersion();

    await ensureLatestSelfbotVersion();

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

  static Future<String> launch({bool force = false}) async {
    if (isDownloading) {
      return "The selfbot is currently downloading. Please wait a few seconds and try again.";
    }
    if (executableVersion.isEmpty) {
      startDownload();
      return "The selfbot executable is missing. It will be now start downloading.";
    }
    if (!IPC.websocketConnected || force) {
      try {
        await Process.start(Paths.executablePath, ["-l"]);
      } catch (e) {
        return "Failed to start the selfbot executable.\n\nError: $e";
      }
    }
    return "";
  }

  static Future<String> getExecutableVersion() async {
    try {
      final result = await Process.run(Paths.executablePath, ["-v"]);
      final version = result.stdout.toString().trim();
      return version;
    } catch (e) {
      return "";
    }
  }

  static String getFilename() {
    final filename = Platform.isWindows ? "selfbot.exe" : "selfbot";
    return filename;
  }

  static Future<void> ensureLatestSelfbotVersion() async {
    final apiResponse = await API.checkVersion("selfbot", executableVersion);

    if (!apiResponse.success) {
      return;
    }

    final isLatest = apiResponse.json["is_latest"];

    if (!isLatest) {
      startDownload();
    }
  }

  static void startDownload() {
    if (isDownloading) {
      return;
    }

    String downloadUrl = "${API.baseUrl}/static/executables/"
        "${Platform.operatingSystem}/$architecture/${getFilename()}";

    if (Platform.isMacOS) {
      downloadUrl = "${API.baseUrl}/static/executables/macos/selfbot";
    }

    isDownloading = true;
    Utils.downloadFile(downloadUrl, Paths.executablePath).then((_) async {
      if (!Platform.isWindows) {
        // Add executable permissions
        try {
          await Process.run("chmod", ["+x", Paths.executablePath]);
        } catch (e) {
          // TODO: Handle error
          print(e);
        }
      }

      executableVersion = await getExecutableVersion();

      isDownloading = false;
    }).onError((error, stackTrace) {
      isDownloading = false;
    });
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
