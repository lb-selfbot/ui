import 'package:flutter/material.dart';
import 'package:lightningui/widgets/config_editor.dart';

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
      'name': 'Anti Phishing',
      'type': 'switch',
      'jsonQuery': '/Protections/AntiPhishing',
      'set': (Map<String, dynamic> config, bool value) {
        config['Protections']['AntiPhishing'] = value;
        return config;
      },
      'info': 'If enabled, the bot will warn you against phishing links.',
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
