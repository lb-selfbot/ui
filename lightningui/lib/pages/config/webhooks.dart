import 'package:flutter/material.dart';

import 'package:lightningui/widgets/config_editor.dart';

class WebhooksConfigPage extends StatelessWidget {
  const WebhooksConfigPage({Key? key}) : super(key: key);

  static var fields = [
    {
      'name': 'Nitro Sniper Webhook',
      'type': 'url',
      'jsonQuery': '/Webhooks/NitroSniper',
      'set': (Map<String, dynamic> config, String value) {
        config['Webhooks']['NitroSniper'] = value;
        return config;
      },
      'info':
          'The webhook URL to send nitro sniper notifications to. Leave blank to disable.\n\nYou can create a webhook by going to Channel Settings > Integrations > Webhooks > Create Webhook.',
    },
    {
      'name': 'Giveaway Sniper Webhook',
      'type': 'url',
      'jsonQuery': '/Webhooks/GiveawaySniper',
      'set': (Map<String, dynamic> config, String value) {
        config['Webhooks']['GiveawaySniper'] = value;
        return config;
      },
      'info':
          'The webhook URL to send giveaway sniper notifications to. Leave blank to disable.\n\nYou can create a webhook by going to Channel Settings > Integrations > Webhooks > Create Webhook.',
    },
    {
      'name': 'Selfbot Detection Webhook',
      'type': 'url',
      'jsonQuery': '/Webhooks/SelfbotDetection',
      'set': (Map<String, dynamic> config, String value) {
        config['Webhooks']['SelfbotDetection'] = value;
        return config;
      },
      'info':
          'The webhook URL to send selfbot detection notifications to. Leave blank to disable.\n\nYou can create a webhook by going to Channel Settings > Integrations > Webhooks > Create Webhook.',
    },
    {
      'name': 'Staff Detection Webhook',
      'type': 'url',
      'jsonQuery': '/Webhooks/StaffDetection',
      'set': (Map<String, dynamic> config, String value) {
        config['Webhooks']['StaffDetection'] = value;
        return config;
      },
      'info':
          'The webhook URL to send staff detection notifications to. Leave blank to disable.\n\nYou can create a webhook by going to Channel Settings > Integrations > Webhooks > Create Webhook.',
    },
    {
      'name': 'Notifiers Webhook',
      'type': 'url',
      'jsonQuery': '/Webhooks/Notifiers',
      'set': (Map<String, dynamic> config, String value) {
        config['Webhooks']['Notifiers'] = value;
        return config;
      },
      'info':
          'The webhook URL to send notifier notifications to. Leave blank to disable.\n\nYou can create a webhook by going to Channel Settings > Integrations > Webhooks > Create Webhook.',
    },
    {
      'name': 'Ping Detection Webhook',
      'type': 'url',
      'jsonQuery': '/Webhooks/PingDetection',
      'set': (Map<String, dynamic> config, String value) {
        config['Webhooks']['PingDetection'] = value;
        return config;
      },
      'info':
          'The webhook URL to send ping detection notifications to. Leave blank to disable.\n\nYou can create a webhook by going to Channel Settings > Integrations > Webhooks > Create Webhook.',
    },
    {
      'name': 'Misc Webhook',
      'type': 'url',
      'jsonQuery': '/Webhooks/Misc',
      'set': (Map<String, dynamic> config, String value) {
        config['Webhooks']['Misc'] = value;
        return config;
      },
      'info':
          'The webhook URL to send miscellaneous notifications to. Leave blank to disable.\n\nYou can create a webhook by going to Channel Settings > Integrations > Webhooks > Create Webhook.',
    },
    {
      'name': 'Sessions Webhook',
      'type': 'url',
      'jsonQuery': '/Webhooks/Sessions',
      'set': (Map<String, dynamic> config, String value) {
        config['Webhooks']['Sessions'] = value;
        return config;
      },
      'info':
          'The webhook URL to send sessions notifications to. Leave blank to disable.\n\nYou can create a webhook by going to Channel Settings > Integrations > Webhooks > Create Webhook.',
    },
    {
      'name': 'Ping Self',
      'type': 'switch',
      'jsonQuery': '/Webhooks/PingSelf',
      'set': (Map<String, dynamic> config, bool value) {
        config['Webhooks']['PingSelf'] = value;
        return config;
      },
      'info':
          'If enabled, you will be pinged when a webhook notification is sent.',
    },
    {
      'name': 'Ping Everyone',
      'type': 'switch',
      'jsonQuery': '/Webhooks/PingEveryone',
      'set': (Map<String, dynamic> config, bool value) {
        config['Webhooks']['PingEveryone'] = value;
        return config;
      },
      'info':
          'If enabled, @everyone will be pinged when a webhook notification is sent.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ConfigEditor(fields: fields);
  }
}
