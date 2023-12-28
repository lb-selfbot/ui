import 'package:flutter/material.dart';

import 'package:lightningui/widgets/config_editor.dart';

class SelfbotConfigPage extends StatelessWidget {
  const SelfbotConfigPage({Key? key}) : super(key: key);

  static var fields = [
    {
      'name': 'Command Prefix',
      'type': 'text',
      'jsonQuery': '/Selfbot/CommandPrefix',
      'set': (Map<String, dynamic> config, String value) {
        config['Selfbot']['CommandPrefix'] = value;
        return config;
      },
      'info':
          'The prefix that will be used to trigger commands. \nExample: If your command prefix is "!", you can you use "!help" to get a list of commands.',
    },
    {
      'name': 'Command Mode',
      'type': 'dropdown',
      'jsonQuery': '/Selfbot/CommandMode',
      'set': (Map<String, dynamic> config, String value) {
        config['Selfbot']['CommandMode'] = value;
        return config;
      },
      'info':
          'The command mode changes how responses to your commands will be sent.',
      'options': [
        {
          'label': 'Codeblock',
          'value': 'Codeblock',
          'info': 'The bot will respond to commands in codeblocks.',
          'icon': 'code-braces',
        },
        {
          'label': 'Text',
          'value': 'Text',
          'info': 'The bot will respond to commands in normal text.',
          'icon': 'text',
        },
        {
          'label': 'Indent',
          'value': 'Indent',
          'info': 'The bot will respond to commands with indented text.',
          'icon': 'link',
        },
        {
          'label': 'Webhook Embed',
          'value': 'WebhookEmbed',
          'info':
              'The bot will respond to commands with a webhook embed if possible.',
          'icon': 'link',
        },
        {
          'label': 'URL Embed',
          'value': 'URLEmbed',
          'info':
              'The bot will respond to commands with a URL embed.',
          'icon': 'link',
        },
      ],
    },
    {
      'name': 'Title',
      'type': 'text',
      'jsonQuery': '/Selfbot/Title',
      'set': (Map<String, dynamic> config, String value) {
        config['Selfbot']['Title'] = value;
        return config;
      },
      'info':
          'The title of the embed, codeblock or message that the bot will response with.\nThe title is the first line in the message and will be in a different color in codeblock mode.',
    },
    {
      'name': 'Footer',
      'type': 'text',
      'jsonQuery': '/Selfbot/Footer',
      'set': (Map<String, dynamic> config, String value) {
        config['Selfbot']['Footer'] = value;
        return config;
      },
      'info':
          'The footer of the embed, codeblock or message that the bot will response with.\nThe footer is the last line in the message and will be in a different color in codeblock mode.',
    },
    {
      'name': 'Delete Responses',
      'type': 'switch',
      'jsonQuery': '/Selfbot/DeleteResponses',
      'set': (Map<String, dynamic> config, bool value) {
        config['Selfbot']['DeleteResponses'] = value;
        return config;
      },
      'info':
          'If this is enabled, the bot will delete the message that the bot sent in response to the command after waiting for the delay.\nThis is useful to hide the bot from other people.',
    },
    {
      'name': 'Delete Responses Delay',
      'type': 'number',
      'jsonQuery': '/Selfbot/DeleteResponsesDelay',
      'set': (Map<String, dynamic> config, int value) {
        config['Selfbot']['DeleteResponsesDelay'] = value;
        return config;
      },
      'info':
          'If this is enabled, the bot will delete the message that the bot sent in response to the command after waiting for the delay.\nThis is useful to hide the bot from other people.',
    },
    {
      'name': 'Delete Commands',
      'type': 'switch',
      'jsonQuery': '/Selfbot/DeleteCommands',
      'set': (Map<String, dynamic> config, bool value) {
        config['Selfbot']['DeleteCommands'] = value;
        return config;
      },
      'info':
          'If enabled, the bot will delete the message that invoked the command.',
    },
    {
      'name': 'Mobile Friendly',
      'type': 'switch',
      'jsonQuery': '/Selfbot/MobileFriendly',
      'set': (Map<String, dynamic> config, bool value) {
        config['Selfbot']['MobileFriendly'] = value;
        return config;
      },
      'info':
          'If enabled, the bot will not use colored codeblocks to improve readability on mobile.',
    },
    {
      'name': 'Client Spoof',
      'type': 'dropdown',
      'jsonQuery': '/Selfbot/Client',
      'set': (Map<String, dynamic> config, String value) {
        config['Selfbot']['Client'] = value;
        return config;
      },
      'info':
          'The client that the selfbot will show up as for Discord. A restart of the selfbot is required for any changes to take effect.',
      'options': [
        {
          'label': 'Desktop',
          'value': 'Desktop',
          'info': 'The desktop client.',
          'icon': 'code-braces',
        },
        {
          'label': 'Web',
          'value': 'Web',
          'info': 'The web client.',
          'icon': 'text',
        },
        {
          'label': 'Mobile',
          'value': 'Mobile',
          'info': 'The mobile client.',
          'icon': 'link',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ConfigEditor(fields: fields);
  }
}
