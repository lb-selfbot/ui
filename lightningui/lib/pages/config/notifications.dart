import 'package:flutter/material.dart';

import 'package:lightningui/widgets/config_editor.dart';

class NotificationsConfigPage extends StatelessWidget {
  const NotificationsConfigPage({super.key});

  static var fields = [
    {
      'name': 'Enabled',
      'type': 'switch',
      'jsonQuery': '/Notifications/Enabled',
      'set': (Map<String, dynamic> config, bool value) {
        config['Notifications']['Enabled'] = value;
        return config;
      },
      'info': 'Turn notifications on or off.',
    }
  ];

  @override
  Widget build(BuildContext context) {
    return ConfigEditor(fields: fields);
  }
}
