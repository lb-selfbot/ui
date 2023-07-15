import 'package:flutter/material.dart';
import 'package:lightningui/widgets/config_editor.dart';

class AccountConfigPage extends StatelessWidget {
  const AccountConfigPage({Key? key}) : super(key: key);

  static var fields = [
    {
      'name': 'Username',
      'type': 'text',
      'jsonQuery': '/Account/LightningBot/Username',
      'set': (Map<String, dynamic> config, String value) {
        config['Account']['LightningBot']['Username'] = value;
        return config;
      },
      'info':
          'Your LightningBot username is used to log you in. This is the same username as on the website.',
    },
    {
      'name': 'Password',
      'type': 'text',
      'obscure': true,
      'jsonQuery': '/Account/LightningBot/Password',
      'set': (Map<String, dynamic> config, String value) {
        config['Account']['LightningBot']['Password'] = value;
        return config;
      },
      'info':
          'Your LightningBot password is used to log you in. This is the same password as on the website.',
    },
    {
      'name': 'Discord Token',
      'type': 'text',
      'obscure': true,
      'jsonQuery': '/Account/Discord/Token',
      'set': (Map<String, dynamic> config, String value) {
        config['Account']['Discord']['Token'] = value;
        return config;
      },
      'info':
          'Your Discord token is used to log in to your Discord account. Your token is only saved locally and will always be safe.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ConfigEditor(fields: fields);
  }
}
