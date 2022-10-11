import 'package:flutter/material.dart';
import 'package:lightningui/widgets/configeditor.dart';

class ProtectionsConfigPage extends StatelessWidget {
  const ProtectionsConfigPage({Key? key}) : super(key: key);

  static var fields = [
    {
      'name': 'Anti Friend Request',
      'type': 'switch',
      'jsonQuery': '/Protections/AntiFriendRequest',
      'set': (Map<String, dynamic> config, bool value) {
        config['Protections']['AntiFriendRequest'] = value;
        return config;
      },
      'info':
          'If enabled, the bot will protect you against friend request spam.',
    },
    {
      'name': 'Anti Mass DM',
      'type': 'switch',
      'jsonQuery': '/Protections/AntiMassDM',
      'set': (Map<String, dynamic> config, bool value) {
        config['Protections']['AntiMassDM'] = value;
        return config;
      },
      'info': 'If enabled, the bot will protect you against DM spam.',
    },
    {
      'name': 'Anti Phising',
      'type': 'switch',
      'jsonQuery': '/Protections/AntiPhising',
      'set': (Map<String, dynamic> config, bool value) {
        config['Protections']['AntiPhising'] = value;
        return config;
      },
      'info': 'If enabled, the bot will warn you against phising links.',
    },
    {
      'name': 'Server Protections',
      'type': 'server_protections_dialog',
      'jsonQuery': '/Protections/ServerProtections',
      'info': 'Protect your servers from malicious users.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ConfigEditor(fields: fields);
  }
}
