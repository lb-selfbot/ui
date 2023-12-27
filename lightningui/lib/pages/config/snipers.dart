import 'package:flutter/material.dart';

import 'package:lightningui/widgets/config_editor.dart';

class SnipersConfigPage extends StatelessWidget {
  const SnipersConfigPage({Key? key}) : super(key: key);

  static var fields = [
    {
      'name': 'Nitro Sniper',
      'type': 'switch',
      'jsonQuery': '/Snipers/NitroSniper',
      'set': (Map<String, dynamic> config, bool value) {
        config['Snipers']['NitroSniper'] = value;
        return config;
      },
      'info':
          'Enable or disable the nitro sniper.\n\nThe nitro sniper will try to claim every gift code that is sent in servers that you are in.',
    },
    {
      'name': 'Giveaway Sniper',
      'type': 'switch',
      'jsonQuery': '/Snipers/GiveawaySniper/Enabled',
      'set': (Map<String, dynamic> config, bool value) {
        config['Snipers']['GiveawaySniper']['Enabled'] = value;
        return config;
      },
      'info':
          'Enable or disable the giveaway sniper.\n\nThe giveaway sniper will try to join every giveaway hosted in servers you are in and notify you when you win a giveaway.',
    },
    {
      'name': 'Giveaway Sniper Sleep',
      'type': 'number',
      'jsonQuery': '/Snipers/GiveawaySniper/Sleep',
      'set': (Map<String, dynamic> config, int value) {
        config['Snipers']['GiveawaySniper']['Sleep'] = value;
        return config;
      },
      'info':
          'Time in seconds that the sniper will wait before joining a giveaway after finding it.',
    },
    {
      'name': 'Blacklist',
      'type': 'text_selection_dialog',
      'jsonQuery': '/Snipers/Blacklist',
      'set': (Map<String, dynamic> config, List<dynamic> value) {
        config['Snipers']['Blacklist'] = value;
        return config;
      },
      'info':
          'The giveaway sniper will ignore a giveaway if any of the blacklist entries are found in the prize.',
    },
    {
      'name': 'Server Blacklist',
      'type': 'server_selection_dialog',
      'jsonQuery': '/Snipers/Blacklist',
      'set': (Map<String, dynamic> config, List<dynamic> value) {
        config['Snipers']['Blacklist'] = value;
        return config;
      },
      'info':
          'The giveaway and nitro sniper will ignore the servers in this list. You can only enter the server ID.',
    },
    {
      'name': 'Custom Bots',
      'type': 'user_selection_dialog',
      'jsonQuery': '/Snipers/GiveawaySniper/CustomBots',
      'set': (Map<String, dynamic> config, List<dynamic> value) {
        config['Snipers']['GiveawaySniper']['CustomBots'] = value;
        return config;
      },
      'info':
          'Custom bots for the giveaway sniper.\n\nThe bot will try to enter giveaways hosted using these bots.',
    },
    {
      'name': 'Multi-Token Sniper',
      'type': 'switch',
      'jsonQuery': '/Snipers/MultiTokenSniper',
      'set': (Map<String, dynamic> config, bool value) {
        config['Snipers']['MultiTokenSniper'] = value;
        return config;
      },
      'info':
          'Enable or disable the multi-token sniper.\n\nThe sniper will try to join giveaways and redeem codes using the tokens you provide. The codes will be redeemed on your main account. The selfbot has to be restarted for changes to take effect.',
    },
    {
      'name': 'Tokens',
      'type': 'text_selection_dialog',
      'jsonQuery': '/Snipers/Tokens',
      'set': (Map<String, dynamic> config, List<dynamic> value) {
        config['Snipers']['Tokens'] = value;
        return config;
      },
      'info':
          'Tokens for the multi-token sniper.\n\nThe sniper will try to join giveaways and redeem codes using these tokens.',
    },
    {
      'name': 'Privnote Sniper',
      'type': 'switch',
      'jsonQuery': '/Snipers/PrivnoteSniper',
      'set': (Map<String, dynamic> config, bool value) {
        config['Snipers']['PrivnoteSniper'] = value;
        return config;
      },
      'info':
          'Enable or disable the Privnote sniper.\n\nThe Privnote sniper will try to open every privnote message that is sent in servers so you can read the contents of the message.',
    },
    {
      'name': 'PokéTwo Sniper',
      'type': 'poketwo_sniper_dialog',
      'jsonQuery': '/Snipers/PokeTwoSniper',
      'info':
          'Enable or disable the PokéTwo sniper.\n\nThe PokéTwo sniper will try to catch Pokémon using AI detection that spawns in the channels you specify.',
      'set': (Map<String, dynamic> config, dynamic value) {
        config['Snipers']['PokeTwoSniper'] = value;
        return config;
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ConfigEditor(fields: fields);
  }
}
