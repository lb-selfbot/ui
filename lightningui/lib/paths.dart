import 'dart:io';

class Paths {
  static String _pathSeperator = "";
  static String _documentsDirectory = "";
  static String _applicationDirectory = "";

  static void init(
    String pathSeperator,
    String documentsDirectory,
    String applicationDirectory,
  ) {
    _pathSeperator = pathSeperator;
    _documentsDirectory = documentsDirectory;
    _applicationDirectory = applicationDirectory;
  }

  static String get mainFolder {
    return "$_documentsDirectory${_pathSeperator}LightningBot";
  }

  static String get configFile {
    return "$mainFolder${_pathSeperator}Config${_pathSeperator}config.json";
  }

  static Set<String> get folders {
    return {
      "$mainFolder${_pathSeperator}Config",
      "$mainFolder${_pathSeperator}Animations",
      "$mainFolder${_pathSeperator}Dumping",
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
