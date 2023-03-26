import 'package:flutter/material.dart';
import 'package:lightningui/widgets/config_editor.dart';

class AFKConfigPage extends StatelessWidget {
  const AFKConfigPage({Key? key}) : super(key: key);

  static var fields = [
    {
      'name': 'Enabled',
      'type': 'switch',
      'jsonQuery': '/AFK/Enabled',
      'set': (Map<String, dynamic> config, bool value) {
        config['AFK']['Enabled'] = value;
        return config;
      },
      'info': 'Turn AFK on or off.',
    },
    {
      'name': 'Delay',
      'type': 'number',
      'jsonQuery': '/AFK/Delay',
      'set': (Map<String, dynamic> config, int value) {
        config['AFK']['Delay'] = value;
        return config;
      },
      'info': 'Delay before sending the AFK message.',
    },
    {
      'name': 'On DM',
      'type': 'switch',
      'jsonQuery': '/AFK/OnDM',
      'set': (Map<String, dynamic> config, bool value) {
        config['AFK']['OnDM'] = value;
        return config;
      },
      'info': 'If enabled, the AFK message will be sent when you get a DM.',
    },
    {
      'name': 'On Ping',
      'type': 'switch',
      'jsonQuery': '/AFK/OnPing',
      'set': (Map<String, dynamic> config, bool value) {
        config['AFK']['OnPing'] = value;
        return config;
      },
      'info': 'If enabled, the AFK message will be sent when you get pinged.',
    },
    {
      'name': 'Reply',
      'type': 'switch',
      'jsonQuery': '/AFK/Reply',
      'set': (Map<String, dynamic> config, bool value) {
        config['AFK']['Reply'] = value;
        return config;
      },
      'info':
          'If enabled, the AFK message will be sent in a reply to the message that triggered it.',
    },
    {
      'name': 'Typing',
      'type': 'switch',
      'jsonQuery': '/AFK/Typing',
      'set': (Map<String, dynamic> config, bool value) {
        config['AFK']['Typing'] = value;
        return config;
      },
      'info':
          'If enabled, Discord will display that you are typing for as long as the delay before sending the AFK message.',
    },
    {
      'name': 'Ignored Users',
      'type': 'user_selection_dialog',
      'jsonQuery': '/AFK/IgnoredUsers',
      'set': (Map<String, dynamic> config, List<dynamic> value) {
        config['AFK']['IgnoredUsers'] = value;
        return config;
      },
      'info': 'Messages from these users will be ignored.',
    },
    {
      'name': 'Ignored Servers',
      'type': 'server_selection_dialog',
      'jsonQuery': '/AFK/IgnoredServers',
      'set': (Map<String, dynamic> config, List<dynamic> value) {
        config['AFK']['IgnoredServers'] = value;
        return config;
      },
      'info': 'Messages from these servers will be ignored.',
    },
    {
      'name': 'Message',
      'type': 'text',
      'jsonQuery': '/AFK/Message',
      'set': (Map<String, dynamic> config, String value) {
        config['AFK']['Message'] = value;
        return config;
      },
      'info': 'The message to be sent when a message triggers the AFK bot.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ConfigEditor(fields: fields);
  }
}
