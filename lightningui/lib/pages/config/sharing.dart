import 'package:flutter/material.dart';
import 'package:lightningui/widgets/config_editor.dart';

class SharingConfigPage extends StatelessWidget {
  const SharingConfigPage({Key? key}) : super(key: key);

  static var fields = [
    {
      'name': 'Share All Commands',
      'type': 'switch',
      'jsonQuery': '/Sharing/ShareAll',
      'set': (Map<String, dynamic> config, bool value) {
        config['Sharing']['ShareAll'] = value;
        return config;
      },
      'info':
          'Share all commands with the shared users.\n\nWARNING: Users in the shared users list will be able to run any command in the bot. This means they can execute commands like shutdownpc, hiddeneveryone, etc.',
    },
    {
      'name': 'Shared Users',
      'type': 'user_selection_dialog',
      'jsonQuery': '/Sharing/SharedUsers',
      'set': (Map<String, dynamic> config, List<dynamic> value) {
        config['Sharing']['SharedUsers'] = value;
        return config;
      },
      'info': 'Users to share commands with.',
    },
    {
      'name': 'Shared Categories',
      'type': 'category_selection_dialog',
      'jsonQuery': '/Sharing/SharedCategories',
      'set': (Map<String, dynamic> config, List<dynamic> value) {
        config['Sharing']['SharedCategories'] = value;
        return config;
      },
      'info': 'Command categories that shared users will be able to use.',
    },
    {
      'name': 'Shared Commands',
      'type': 'command_selection_dialog',
      'jsonQuery': '/Sharing/SharedCommands',
      'set': (Map<String, dynamic> config, List<dynamic> value) {
        config['Sharing']['SharedCommands'] = value;
        return config;
      },
      'info': 'Individual commands that shared users will be able to use.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ConfigEditor(fields: fields);
  }
}
