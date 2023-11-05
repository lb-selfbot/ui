import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightningui/services/config_service.dart';
import 'package:lightningui/main.dart';
import 'package:lightningui/widgets/config_fields.dart';
import 'package:lightningui/widgets/dialogs/server_selection.dart';
import 'package:lightningui/widgets/dialogs/user_selection.dart';

class TriggerListConfig extends StatefulWidget {
  const TriggerListConfig({
    Key? key,
    required this.triggerList,
    required this.jsonQuery,
    required this.name,
    required this.info,
    required this.setConfig,
  }) : super(key: key);

  final Map<String, dynamic> triggerList;
  final String jsonQuery;
  final String name;
  final String info;
  final Map<String, dynamic> Function(
      Map<String, dynamic> config, Map<String, dynamic>) setConfig;

  @override
  State<TriggerListConfig> createState() => _TriggerListConfigState();
}

class _TriggerListConfigState extends State<TriggerListConfig> {
  Map<String, dynamic> triggerList = {};

  @override
  void initState() {
    super.initState();
    triggerList = widget.triggerList;
  }

  String getLabelText() {
    return "Type: ${triggerList['Type'] ?? 'Unknown'}";
  }

  void onUpdate(triggerList) {
    setState(() {
      this.triggerList = triggerList;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: getLabelText());

    controller.addListener(() {
      controller.text = getLabelText();
    });

    return TextField(
      decoration: InputDecoration(
        labelText: widget.name,
        suffix: InfoIconButton(
          info: widget.info,
        ),
      ),
      controller: controller,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        showDialog(
          context: context,
          builder: (context) => TriggerListDialog(
            name: widget.name,
            triggerList: triggerList,
            onUpdate: onUpdate,
            setConfig: widget.setConfig,
          ),
        );
      },
    );
  }
}

class TriggerListDialog extends StatefulWidget {
  const TriggerListDialog({
    Key? key,
    required this.name,
    required this.triggerList,
    required this.onUpdate,
    required this.setConfig,
  }) : super(key: key);

  final String name;
  final Map<String, dynamic> triggerList;
  final void Function(List<dynamic>) onUpdate;
  final Map<String, dynamic> Function(
      Map<String, dynamic> config, Map<String, dynamic>) setConfig;

  @override
  State<TriggerListDialog> createState() => _TriggerListDialogState();
}

class _TriggerListDialogState extends State<TriggerListDialog> {
  Map<String, dynamic> triggerList = {};

  @override
  void initState() {
    super.initState();
    triggerList = widget.triggerList;
  }

  List<Widget> getDialogContent() {
    List<Widget> typeConfig = [
      SizedBox(
        height: 70,
        width: 400,
        child: DropdownConfigCol(
          name: "Trigger List Type",
          info: "The type of trigger list to use.",
          options: const [
            {
              'label': 'Global',
              'value': 'Global',
            },
            {
              'label': 'Whitelist',
              'value': 'Whitelist',
            },
            {
              'label': 'Blacklist',
              'value': 'Blacklist',
            }
          ],
          defaultValue: triggerList['Type'],
          onChanged: (newType) {
            setState(() {
              triggerList['Type'] = newType;
              getIt<ConfigService>().config = widget.setConfig(
                getIt<ConfigService>().config,
                triggerList,
              );
            });
          },
        ),
      ),
      const Divider(height: 30),
    ];

    switch (triggerList['Type']) {
      case 'Global':
        return [
          ...typeConfig,
          Text(
            'Every message or event will trigger in global mode. There are no configuration options for this trigger type.',
            style: GoogleFonts.montserrat(fontSize: 14),
          ),
        ];
      case 'Whitelist':
        return [
          ...typeConfig,
          SizedBox(
            height: 70,
            width: 400,
            child: UserSelectionConfig(
              selectedUsers: triggerList["Users"],
              jsonQuery: "/AFK/TriggerList/Users",
              name: "Allowed Users",
              info: "",
              setConfig: (config, newUsers) {
                triggerList["Users"] = newUsers;
                return widget.setConfig(config, triggerList);
              },
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 70,
            width: 400,
            child: ServerSelectionConfig(
              selectedServers: triggerList["Servers"],
              jsonQuery: "/AFK/TriggerList/Servers",
              name: "Allowed Servers",
              info: "",
              setConfig: (config, newUsers) {
                triggerList["Servers"] = newUsers;
                return widget.setConfig(config, triggerList);
              },
            ),
          ),
        ];
      case 'Blacklist':
        return [
          ...typeConfig,
          SizedBox(
            height: 70,
            width: 400,
            child: UserSelectionConfig(
              selectedUsers: triggerList["Users"],
              jsonQuery: "/AFK/TriggerList/Users",
              name: "Ignored Users",
              info: "",
              setConfig: (config, newUsers) {
                triggerList["Users"] = newUsers;
                return widget.setConfig(config, triggerList);
              },
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 70,
            width: 400,
            child: ServerSelectionConfig(
              selectedServers: triggerList["Servers"],
              jsonQuery: "/AFK/TriggerList/Servers",
              name: "Ignored Servers",
              info: "",
              setConfig: (config, newUsers) {
                triggerList["Servers"] = newUsers;
                return widget.setConfig(config, triggerList);
              },
            ),
          ),
        ];
      default:
        return [
          ...typeConfig,
          Text(
            'Unknown trigger type: ${triggerList['Type']}',
            style: GoogleFonts.montserrat(fontSize: 16),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.name),
      content: SizedBox(
        width: 575,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: getDialogContent(),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      actions: [
        TextButton(
          child: const Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
