import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:lightningui/api.dart';
import 'package:lightningui/config.dart';
import 'package:lightningui/ipc.dart';
import 'package:lightningui/main.dart';
import 'package:lightningui/paths.dart';
import 'package:lightningui/utils.dart';

class UpdateResult {
  final APIResult? apiResult;
  final Exception? error;
  final bool isLatest;
  final bool success;

  UpdateResult(this.apiResult, this.error, this.isLatest, this.success);
}

class Launching {
  static String executableVersion = "";

  static bool isFirstLaunch = false;
  static bool isDownloading = false;

  static Future<void> init() async {
    ensureLatestSelfbotVersion();

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

    final exists = await File(Paths.executablePath).exists();

    if (!exists) {
      startDownload(notifyOnSuccess: true);
      return "The selfbot executable is missing. It will now start downloading.";
    }

    if (IPC.websocketConnected && !force) {
      return "";
    }

    try {
      await Process.start(Paths.executablePath, ["-l"]);
      return "";
    } catch (e) {
      return "Failed to start the selfbot executable.\n\nError: $e";
    }
  }

  static Future<String> getExecutableVersion() async {
    final exists = await File(Paths.executablePath).exists();

    if (!exists) {
      return "";
    }

    try {
      final result = await Process.run(Paths.executablePath, ["-v"]);

      return result.stdout.toString().trim();
    } catch (e) {
      return "";
    }
  }

  static String getFilename() {
    return Platform.isWindows ? "selfbot.exe" : "selfbot";
  }

  static Future<UpdateResult> ensureLatestSelfbotVersion({
    bool notifyOnSuccess = false,
  }) async {
    executableVersion = await getExecutableVersion();

    final apiResult = await API.checkVersion("selfbot", executableVersion);

    if (!apiResult.success) {
      return UpdateResult(null, apiResult.error, false, false);
    }

    final version = apiResult.json["latest"]["version"] as String;
    final isLatest = apiResult.json["is_latest"] as bool;

    if (!isLatest) {
      if (executableVersion.isNotEmpty) {
        FlutterPlatformAlert.showAlert(
          windowTitle: "LightningBot - Update available",
          text:
              "LightningBot version $version is now available. It will now start downloading in the background.",
          iconStyle: IconStyle.information,
        );
      }

      final response = await startDownload(notifyOnSuccess: notifyOnSuccess);

      return UpdateResult(apiResult, null, isLatest, response != null);
    }

    return UpdateResult(apiResult, null, isLatest, true);
  }

  static Future<Response?> startDownload({bool notifyOnSuccess = false}) async {
    if (isDownloading) {
      return null;
    }

    String downloadUrl = "${API.baseUrl}/static/executables/"
        "${Platform.operatingSystem}/$Paths.architecture/${getFilename()}";

    if (Platform.isMacOS) {
      downloadUrl = "${API.baseUrl}/static/executables/macos/selfbot";
    }

    isDownloading = true;

    Response? response;

    try {
      response = await Utils.downloadFile(
        downloadUrl,
        Paths.executablePath,
      );
    } catch (e) {
      FlutterPlatformAlert.showAlert(
        windowTitle: "LightningBot - Error",
        text: "An error occurred while trying to download the executable. "
            "\n\n  Exception: $e",
        iconStyle: IconStyle.information,
      );

      isDownloading = false;

      return null;
    }

    isDownloading = false;

    if (!Platform.isWindows) {
      try {
        await Process.run("chmod", ["+x", Paths.executablePath]);
      } catch (e) {
        await FlutterPlatformAlert.showAlert(
          windowTitle: "LightningBot - Error",
          text: "An error occurred. "
              "\n\nError data: Failed to set -x flag on executable"
              "\n\n  Exception: $e"
              "\n\n Please run this command in a terminal to fix the issue:"
              "\n\n chmod +x ${Paths.executablePath}",
          iconStyle: IconStyle.information,
        );

        return null;
      }
    }

    executableVersion = await getExecutableVersion();

    if (notifyOnSuccess) {
      FlutterPlatformAlert.showAlert(
        windowTitle: "LightningBot - Update complete",
        text: "LightningBot version $executableVersion has been downloaded.",
        iconStyle: IconStyle.information,
      );
    }

    return response;
  }

  static void onLogin(String username, String password) {
    final config = getIt<Config>().config;
    config["Account"]["LightningBot"]["Username"] = username;
    config["Account"]["LightningBot"]["Password"] = password;
    getIt<Config>().config = config;
  }

  static bool shouldLogin() {
    if (isFirstLaunch) {
      return true;
    }

    if (getIt<Config>().config["Account"]["LightningBot"]["Username"] == "") {
      return true;
    }

    if (getIt<Config>().config["Account"]["LightningBot"]["Password"] == "") {
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
      getIt<Config>().config = config;
    }
  }
}
