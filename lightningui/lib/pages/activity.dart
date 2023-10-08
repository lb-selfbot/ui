import 'package:flutter/material.dart';
import 'package:lightningui/services/config_service.dart';
import 'package:lightningui/main.dart';
import 'package:lightningui/widgets/activity_card.dart';
import 'package:lightningui/widgets/config_editor.dart';
import 'package:responsive_grid/responsive_grid.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String activityType = 'RPC';

  void onConfigChange() {
    if (!mounted) return;

    if (activityType ==
        getIt<ConfigService>().config['Activity']['ActivityType']) {
      return;
    }

    setState(() {
      activityType = getIt<ConfigService>().config['Activity']['ActivityType'];
    });
  }

  @override
  void dispose() {
    getIt<ConfigService>().removeListener(onConfigChange);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    activityType = getIt<ConfigService>().config['Activity']['ActivityType'];
    getIt<ConfigService>().addListener(onConfigChange);
  }

  List<Map<String, Object>> getFields() {
    final config = getIt<ConfigService>().config;

    final isRPC = config['Activity']['ActivityType'] == 'RPC';
    final isCustom = config['Activity']['ActivityType'] == 'CustomActivity';
    final isStreaming = config['Activity']['Type'] == 'Streaming';

    return [
      {
        'name': 'Enabled',
        'type': 'switch',
        'jsonQuery': '/Activity/Enabled',
        'set': (Map<String, dynamic> config, bool value) {
          config['Activity']['Enabled'] = value;
          return config;
        },
        'info': 'Turn Discord activity on or off.',
      },
      {
        'name': 'Activity Type',
        'type': 'dropdown',
        'jsonQuery': '/Activity/ActivityType',
        'set': (Map<String, dynamic> config, String value) {
          config['Activity']['ActivityType'] = value;
          return config;
        },
        'info':
            'The type of activity the bot will display. The Discord client must be running to use RPC.',
        'options': [
          {
            'label': 'RPC',
            'value': 'RPC',
            'info': 'Rich Presence',
            'icon': 'code-braces',
          },
          {
            'label': 'Custom Activity',
            'value': 'CustomActivity',
            'info': 'Custom Activity',
            'icon': 'text',
          },
        ],
      },
      if (isCustom)
        {
          'name': 'Type',
          'type': 'dropdown',
          'jsonQuery': '/Activity/Type',
          'set': (Map<String, dynamic> config, String value) {
            config['Activity']['Type'] = value;
            return config;
          },
          'info': 'Playing, listening, watching, streaming or competing.',
          'options': [
            {
              'label': 'Playing',
              'value': 'Playing',
              'info': 'Playing activity',
              'icon': 'code-braces',
            },
            {
              'label': 'Listening',
              'value': 'Listening',
              'info': 'Listening activity',
              'icon': 'code-braces',
            },
            {
              'label': 'Watching',
              'value': 'Watching',
              'info': 'Watching activity',
              'icon': 'code-braces',
            },
            {
              'label': 'Streaming',
              'value': 'Streaming',
              'info': 'Streaming activity',
              'icon': 'code-braces',
            },
            {
              'label': 'Competing',
              'value': 'Competing',
              'info': 'Competing activity',
              'icon': 'code-braces',
            },
          ],
        },
      if (isRPC)
        {
          'name': 'Client ID',
          'type': 'text',
          'jsonQuery': '/Activity/ClientID',
          'set': (Map<String, dynamic> config, String value) {
            config['Activity']['ClientID'] = value;
            return config;
          },
          'info': 'The Discord client ID for the RPC application.',
        },
      if (isCustom)
        {
          'name': 'Name',
          'type': 'text',
          'jsonQuery': '/Activity/Name',
          'set': (Map<String, dynamic> config, String value) {
            config['Activity']['Name'] = value;
            return config;
          },
          'info': 'The name of the activity.',
        },
      {
        'name': 'State',
        'type': 'text',
        'jsonQuery': '/Activity/State',
        'set': (Map<String, dynamic> config, String value) {
          config['Activity']['State'] = value;
          return config;
        },
        'info': 'The state text for the activity.',
      },
      {
        'name': 'Details',
        'type': 'text',
        'jsonQuery': '/Activity/Details',
        'set': (Map<String, dynamic> config, String value) {
          config['Activity']['Details'] = value;
          return config;
        },
        'info': 'The details text for the activity.',
      },
      {
        'name': 'Large Image',
        'type': 'text',
        'jsonQuery': '/Activity/LargeImage',
        'set': (Map<String, dynamic> config, String value) {
          config['Activity']['LargeImage'] = value;
          return config;
        },
        'info':
            'The large image key for the activity.\n\nUse the [p]cacreateimagekey command to create an image key.',
      },
      {
        'name': 'Large Image Text',
        'type': 'text',
        'jsonQuery': '/Activity/LargeImageText',
        'set': (Map<String, dynamic> config, String value) {
          config['Activity']['LargeImageText'] = value;
          return config;
        },
        'info': 'Tooltip text for the large image.',
      },
      {
        'name': 'Small Image',
        'type': 'text',
        'jsonQuery': '/Activity/SmallImage',
        'set': (Map<String, dynamic> config, String value) {
          config['Activity']['SmallImage'] = value;
          return config;
        },
        'info':
            'The small image key for the activity.\n\nUse the [p]cacreateimagekey command to create an image key.',
      },
      {
        'name': 'Small Image Text',
        'type': 'text',
        'jsonQuery': '/Activity/SmallImageText',
        'set': (Map<String, dynamic> config, String value) {
          config['Activity']['SmallImageText'] = value;
          return config;
        },
        'info': 'Tooltip text for the small image.',
      },
      if (isRPC)
        {
          'name': 'Invitable',
          'type': 'switch',
          'jsonQuery': '/Activity/Invitable',
          'set': (Map<String, dynamic> config, bool value) {
            config['Activity']['Invitable'] = value;
            return config;
          },
          'info': 'If enabled, you can send fake game invites to other people.',
        },
      {
        'name': 'Time',
        'type': 'switch',
        'jsonQuery': '/Activity/Time',
        'set': (Map<String, dynamic> config, bool value) {
          config['Activity']['Time'] = value;
          return config;
        },
        'info':
            'If enabled, your Rich Presence will show how much time has elapsed.',
      },
      if (isStreaming)
        {
          'name': 'Streaming URL',
          'type': 'url',
          'jsonQuery': '/Activity/StreamingURL',
          'set': (Map<String, dynamic> config, String value) {
            config['Activity']['StreamingURL'] = value;
            return config;
          },
          'info': 'The URL for the streaming activity.',
        },
      {
        'name': 'Button 1 Label',
        'type': 'text',
        'jsonQuery': '/Activity/Button1Label',
        'set': (Map<String, dynamic> config, String value) {
          config['Activity']['Button1Label'] = value;
          return config;
        },
        'info': 'The label for the first button.',
      },
      {
        'name': 'Button 1 URL',
        'type': 'url',
        'jsonQuery': '/Activity/Button1URL',
        'set': (Map<String, dynamic> config, String value) {
          config['Activity']['Button1URL'] = value;
          return config;
        },
        'info': 'The URL for the first button.',
      },
      {
        'name': 'Button 2 Label',
        'type': 'text',
        'jsonQuery': '/Activity/Button2Label',
        'set': (Map<String, dynamic> config, String value) {
          config['Activity']['Button2Label'] = value;
          return config;
        },
        'info': 'The label for the second button.',
      },
      {
        'name': 'Button 2 URL',
        'type': 'url',
        'jsonQuery': '/Activity/Button2URL',
        'set': (Map<String, dynamic> config, String value) {
          config['Activity']['Button2URL'] = value;
          return config;
        },
        'info': 'The URL for the second button.',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final columns = [
      ResponsiveGridCol(
        xs: 12,
        md: 6,
        child: SizedBox(
          height: 500,
          child: ConfigEditor(
            fields: getFields(),
            fullWidthElements: true,
          ),
        ),
      ),
      ResponsiveGridCol(
        xs: 12,
        md: 6,
        child: const SizedBox(
          height: 500,
          child: ActivityCard(),
        ),
      )
    ];

    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: Center(child: ResponsiveGridRow(children: columns)),
    );
  }
}
