import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lightningui/utils/color.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart' as crypto;
import 'package:google_fonts/google_fonts.dart';
import 'package:lightningui/ipc.dart';

class Utils {
  static RegExp indexPattern = RegExp(r'\[(.*?)\]');

  static dynamic getJsonElement(String jsonQuery, dynamic json) {
    final path = jsonQuery.split('/');
    dynamic currentElement;
    for (String query in path) {
      if (query.isEmpty) {
        continue;
      }

      var matches = indexPattern.allMatches(query);
      query = query.replaceAll(indexPattern, '');

      currentElement =
          currentElement != null ? currentElement[query] : json[query];

      for (Match match in matches) {
        String matchString = match.group(0) ?? '';
        matchString = matchString.replaceAll(RegExp(r"[^\w\s]"), "");

        final index = int.tryParse(matchString);
        if (index == null) {
          continue;
        }

        currentElement =
            currentElement != null ? currentElement[index] : json[query];
      }
    }
    return currentElement;
  }

  static String stripIndex(String jsonQuery) =>
      jsonQuery.replaceAll(indexPattern, '');

  static RegExp imageRegex = RegExp('<image(.*?)/>');

  static RegExp textRegex = RegExp('<text(.*?)>(.*?)</text>');

  static Map<String, List<Widget>> renderConsoleCache = {};

  static bool isConsoleCached() {
    return renderConsoleCache.containsKey(
      crypto.sha1.convert(utf8.encode(IPC.consoleString)).toString(),
    );
  }

  static List<Widget> renderConsole() {
    final consoleStringHash =
        crypto.sha1.convert(utf8.encode(IPC.consoleString)).toString();
    if (renderConsoleCache.containsKey(consoleStringHash)) {
      return renderConsoleCache[consoleStringHash]!;
    }

    final content = IPC.consoleString.split('\n');

    List<Widget> widgets = [];

    // iterate over each line in the console
    for (String line in content) {
      final images = imageRegex.allMatches(line).toList();
      final texts = textRegex.allMatches(line).toList();

      for (RegExpMatch image in images) {
        widgets.add(renderImage(image));
      }
      if (texts.length > 1) {
        widgets.add(Row(
          children: [
            for (RegExpMatch text in texts) renderText(text),
          ],
        ));
      } else if (texts.length == 1) {
        widgets.add(renderText(texts.first));
      }
      if (images.isEmpty && texts.isEmpty) {
        widgets.add(
          Text(
            line,
            style: GoogleFonts.robotoMono(
              textStyle: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        );
      }
    }

    renderConsoleCache[consoleStringHash] = widgets;
    return widgets;
  }

  static RegExp imageSrcRegex = RegExp('Source="(.*?)"');
  static RegExp imageWidthRegex = RegExp('Width="(.*?)"');
  static RegExp imageHeightRegex = RegExp('Height="(.*?)"');

  static Widget renderImage(RegExpMatch image) {
    final imageString = image.group(0) ?? '';
    final imageSource = imageSrcRegex.firstMatch(imageString)?.group(1) ?? '';
    final rawWidth = imageWidthRegex.firstMatch(imageString)?.group(1) ?? '';
    final rawHeight = imageHeightRegex.firstMatch(imageString)?.group(1) ?? '';
    final intWidth = double.tryParse(rawWidth) ?? 0;
    final intHeight = double.tryParse(rawHeight) ?? 0;
    final centered = imageString.contains('Centered');
    final imageWidget = Image(
      image: AssetImage(imageSource),
      width: intWidth,
      height: intHeight,
    );
    if (centered) {
      return Center(child: imageWidget);
    }
    return imageWidget;
  }

  static RegExp textColorRegex = RegExp('Color="(.*?)"');

  static Widget renderText(RegExpMatch text) {
    final textString = text.group(1) ?? '';
    final textColor = textColorRegex.firstMatch(textString)?.group(1) ?? '';
    final centered = textString.contains('Centered');
    final content = text.group(2) ?? '';
    final textWidget = Text(
      content,
      style: GoogleFonts.robotoMono(
        textStyle: TextStyle(
          color: Colors.transparent.fromString(textColor),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
    if (centered) {
      return Center(child: textWidget);
    }
    return textWidget;
  }

  static dynamic tryDecode(String source) {
    try {
      return jsonDecode(source);
    } catch (e) {
      return {};
    }
  }

  static String getUserConfigDir() {
    // Replicate os.UserConfigDir in Golang

    if (Platform.isWindows) {
      // If Windows, return %AppData%
      final appData = Platform.environment["AppData"] ?? "";
      return appData;
    } else if (Platform.isMacOS || Platform.isIOS) {
      // If macOS or iOS, return ~/Library/Application Support
      final home = Platform.environment["HOME"] ?? "";
      return path.join(home, "Library", "Application Support");
    } else {
      // If Unix, return %XDG_CONFIG_HOME% or ~/.config
      final xdgConfigHome = Platform.environment["XDG_CONFIG_HOME"] ?? "";
      if (xdgConfigHome.isNotEmpty) {
        return xdgConfigHome;
      }
      final home = Platform.environment["HOME"] ?? "";
      if (home.isNotEmpty) {
        return path.join(home, ".config");
      }
      return "";
    }
  }

  static Directory getMainFolder() {
    return Directory(
      path.join(getUserConfigDir(), 'LightningBot'),
    );
  }

  static Future<void> showAlertDialog(
    BuildContext context,
    String title,
    String text, {
    List<Widget>? actions,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(text),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          if (actions != null) ...actions,
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  static Future<void> showErrorDialog(
    BuildContext context,
    String text, {
    List<Widget>? actions,
  }) async {
    return await showAlertDialog(context, "Error", text, actions: actions);
  }

  static String parseSeconds(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secondsLeft = seconds % 60;

    String parsed = "";

    if (hours > 0) {
      parsed += "${hours}h ";
    }

    if (minutes > 0) {
      parsed += "${minutes}m ";
    }

    if (secondsLeft > 0) {
      parsed += "${secondsLeft}s";
    }

    return parsed;
  }
}
