import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart' as crypto;
import 'package:google_fonts/google_fonts.dart';
import 'package:lightningui/ipc.dart';

class Utils {
  static RegExp indexPattern = RegExp(r'\[(.*?)\]');
  static List<String> categories = [
    "Text",
    "Image",
    "Video",
    "Audio",
    "Other",
    "Texta",
    "Imagea",
    "Videoa",
    "Audioa",
    "Othera",
    "Textb",
    "Imageb",
    "Videob",
    "Audiob",
    "Otherb",
  ];
  static List<String> commands = [
    "Text",
    "Image",
    "Video",
    "Audio",
    "Other",
    "Texta",
    "Imagea",
    "Videoa",
    "Audioa",
    "Othera",
    "Textb",
    "Imageb",
    "Videob",
    "Audiob",
    "Otherb",
  ];

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
        final index =
            int.tryParse(matchString.replaceAll("[", "").replaceAll("]", ""));
        if (index != null) {
          currentElement =
              currentElement != null ? currentElement[index] : json[query];
        }
      }
    }
    return currentElement;
  }

  static dynamic setJsonElement(String jsonQuery, dynamic json, dynamic value) {
    // iterate over jsonQuery in reverse, setting newJson to the value of the last element in jsonQuery, then second to last, etc.
    // then update the json with newJson and return the updated json
    final path = jsonQuery.split('/');
    dynamic newJson = {};

    for (String query in path.reversed) {
      if (query.isEmpty) {
        continue;
      }

      if (query != path.last) {
        newJson = {query: newJson};
        continue;
      }
      newJson[stripIndex(query)] =
          _setWithIndex(json, newJson, query, path, value);
    }
    return newJson;
  }

  static dynamic _setWithIndex(dynamic json, dynamic newJson, String query,
      List<String> path, dynamic value) {
    var matches = indexPattern.allMatches(query);

    if (matches.isNotEmpty) {
      List<String> newPath = List.from(path);
      newPath.removeLast();
      newPath.add(stripIndex(path.last));
      newJson[newPath.last] = getJsonElement(newPath.join('/'), json);
      for (Match match in matches) {
        String matchString = match.group(0) ?? '';
        final index =
            int.tryParse(matchString.replaceAll("[", "").replaceAll("]", ""));
        if (index != null) {
          if (matches.length == 1 || match == matches.last) {
            try {
              newJson = List.from(newJson[newPath.last]);
            } catch (_) {
              newJson = Map.from(newJson[newPath.last]);
            }
            newJson[index] = value;
          } else {
            newJson = newJson[index];
          }
        }
      }
    } else {
      newJson[query] = value;
    }

    return newJson;
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
          color: fromHex(textColor),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
    if (centered) {
      return Center(child: textWidget);
    }
    return textWidget;
  }

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static dynamic tryDecode(String source) {
    try {
      return jsonDecode(source);
    } catch (e) {
      return <String, dynamic>{};
    }
  }

  static Future<bool> downloadFile(
    String uri,
    String path, {
    void Function(int, int)? onProgress,
  }) async {
    final dio = Dio();
    try {
      await dio.download(uri, path, onReceiveProgress: onProgress);
      return true;
    } on DioError catch (e) {
      print(e);
      return false;
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

  static Future<void> showErrorDialog(BuildContext context, String text) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(text),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
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
