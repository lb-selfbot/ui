import 'package:flutter/material.dart';
import 'package:lightningui/widgets/configeditor.dart';

class RPCConfigPage extends StatelessWidget {
  const RPCConfigPage({Key? key}) : super(key: key);

  static var fields = [
    {
      'name': 'Enabled',
      'type': 'switch',
      'jsonQuery': '/RPC/Enabled',
      'set': (Map<String, dynamic> config, bool value) {
        config['RPC']['Enabled'] = value;
        return config;
      },
      'info': 'Turn Rich Presence on or off.',
    },
    {
      'name': 'Client ID',
      'type': 'text',
      'jsonQuery': '/RPC/ClientID',
      'set': (Map<String, dynamic> config, String value) {
        config['RPC']['ClientID'] = value;
        return config;
      },
      'info':
          'The Client ID for your Rich Presence application. You can find it in the Discord Developers site.',
    },
    {
      'name': 'Invitable',
      'type': 'switch',
      'jsonQuery': '/RPC/Invitable',
      'set': (Map<String, dynamic> config, bool value) {
        config['RPC']['Invitable'] = value;
        return config;
      },
      'info': 'If enabled, you can send fake game invites to other people.',
    },
    {
      'name': 'Time',
      'type': 'switch',
      'jsonQuery': '/RPC/Time',
      'set': (Map<String, dynamic> config, bool value) {
        config['RPC']['Time'] = value;
        return config;
      },
      'info':
          'If enabled, your Rich Presence will show how much time has elapsed.',
    },
    {
      'name': 'Large Image ID',
      'type': 'text',
      'jsonQuery': '/RPC/LargeImage',
      'set': (Map<String, dynamic> config, String value) {
        config['RPC']['LargeImage'] = value;
        return config;
      },
      'info': 'The ID for the large image.',
    },
    {
      'name': 'Large Image Text',
      'type': 'text',
      'jsonQuery': '/RPC/LargeText',
      'set': (Map<String, dynamic> config, String value) {
        config['RPC']['LargeText'] = value;
        return config;
      },
      'info': 'The text for the large image.',
    },
    {
      'name': 'Small Image ID',
      'type': 'text',
      'jsonQuery': '/RPC/SmallImage',
      'set': (Map<String, dynamic> config, String value) {
        config['RPC']['SmallImage'] = value;
        return config;
      },
      'info': 'The ID for the small image.',
    },
    {
      'name': 'Small Image Text',
      'type': 'text',
      'jsonQuery': '/RPC/SmallText',
      'set': (Map<String, dynamic> config, String value) {
        config['RPC']['SmallText'] = value;
        return config;
      },
      'info': 'The text for the small image.',
    },
    {
      'name': 'Details',
      'type': 'text',
      'jsonQuery': '/RPC/Details',
      'set': (Map<String, dynamic> config, String value) {
        config['RPC']['Details'] = value;
        return config;
      },
      'info': 'The details text for the Rich Presence.',
    },
    {
      'name': 'State',
      'type': 'text',
      'jsonQuery': '/RPC/State',
      'set': (Map<String, dynamic> config, String value) {
        config['RPC']['State'] = value;
        return config;
      },
      'info': 'The state text for the Rich Presence.',
    },
    {
      'name': 'Button 1 Label',
      'type': 'text',
      'jsonQuery': '/RPC/Buttons[0]/Label',
      'set': (Map<String, dynamic> config, String value) {
        config['RPC']['Buttons'][0]['Label'] = value;
        return config;
      },
      'info': 'The label for the first button.',
    },
    {
      'name': 'Button 1 URL',
      'type': 'url',
      'jsonQuery': '/RPC/Buttons[0]/URL',
      'set': (Map<String, dynamic> config, String value) {
        config['RPC']['Buttons'][0]['URL'] = value;
        return config;
      },
      'info': 'The URL for the first button.',
    },
    {
      'name': 'Button 2 Label',
      'type': 'text',
      'jsonQuery': '/RPC/Buttons[1]/Label',
      'set': (Map<String, dynamic> config, String value) {
        config['RPC']['Buttons'][1]['Label'] = value;
        return config;
      },
      'info': 'The label for the second button.',
    },
    {
      'name': 'Button 2 URL',
      'type': 'url',
      'jsonQuery': '/RPC/Buttons[1]/URL',
      'set': (Map<String, dynamic> config, String value) {
        config['RPC']['Buttons'][1]['URL'] = value;
        return config;
      },
      'info': 'The URL for the second button.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ConfigEditor(fields: fields);
  }
}
