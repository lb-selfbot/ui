import 'package:flutter/material.dart';

import 'package:lightningui/widgets/configeditor.dart';

class NotificationsConfigPage extends StatelessWidget {
  const NotificationsConfigPage({Key? key}) : super(key: key);

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
