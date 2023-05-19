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
      'info': 'Delay before sending the AFK message in seconds.',
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
      'name': 'Must Be Inactive',
      'type': 'switch',
      'jsonQuery': '/AFK/MustBeInactive',
      'set': (Map<String, dynamic> config, bool value) {
        config['AFK']['MustBeInactive'] = value;
        return config;
      },
      'info':
          'If enabled, the AFK message will be only be sent if your computer has not been used for the specified timeout.',
    },
    {
      'name': 'Inactive Timeout',
      'type': 'number',
      'jsonQuery': '/AFK/InactiveTimeout',
      'set': (Map<String, dynamic> config, int value) {
        config['AFK']['InactiveTimeout'] = value;
        return config;
      },
      'info': 'Delay before considering your computer inactive in seconds.',
    },
    {
      'name': 'Reply To Message',
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
      'name': 'Type Before Sending',
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
      'name': 'Trigger List',
      'type': 'trigger_list_dialog',
      'jsonQuery': '/AFK/TriggerList',
      'set': (Map<String, dynamic> config, Map<String, dynamic> value) {
        config['AFK']['TriggerList'] = value;
        return config;
      },
      'info': 'The trigger list will be used to check if the AFK message should be sent. If any of the triggers are found, '
          'the AFK message will be sent. If the trigger list is empty, the AFK message will be sent for any DM or ping. '
          'You can choose between the types whitelist, blacklist, and global. In whitelist mode, you can select users or '
          'servers where the AFK message will be sent. In blacklist mode, you can select users or servers where the AFK '
          'message will not be sent. In global mode, the AFK message will be sent for any DM or ping.',
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
