import 'package:flutter/material.dart';
import 'package:lightningui/widgets/config_editor.dart';

class UIConfigPage extends StatelessWidget {
  const UIConfigPage({Key? key}) : super(key: key);

  static var fields = [
    {
      'name': 'Theme',
      'type': 'dropdown',
      'jsonQuery': '/UI/Theme',
      'set': (Map<String, dynamic> config, String value) {
        config['UI']['Theme'] = value;
        return config;
      },
      'info': 'The theme of the UI.',
      'options': [
        {
          'label': 'Dark',
          'value': 'Dark',
          'info': 'Dark Theme',
        },
        {
          'label': 'Light',
          'value': 'Light',
          'info': 'Light Theme',
        },
      ],
    },
    {
      'name': 'Hide To System Tray',
      'type': 'switch',
      'jsonQuery': '/UI/HideToSystemTray',
      'set': (Map<String, dynamic> config, bool value) {
        config['UI']['HideToSystemTray'] = value;
        return config;
      },
      'info':
          'If enabled, the UI will be hidden to the system tray when you minimize it.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ConfigEditor(fields: fields);
  }
}
