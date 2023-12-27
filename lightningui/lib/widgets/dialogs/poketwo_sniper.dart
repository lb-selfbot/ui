import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightningui/services/config_service.dart';
import 'package:lightningui/main.dart';
import 'package:lightningui/widgets/config_fields.dart';

class PoketwoSniperConfig extends StatefulWidget {
  const PoketwoSniperConfig({
    Key? key,
    required this.poketwoSniper,
    required this.jsonQuery,
    required this.name,
    required this.info,
    required this.setConfig,
  }) : super(key: key);

  final dynamic poketwoSniper;
  final String jsonQuery;
  final String name;
  final String info;
  final Map<String, dynamic> Function(Map<String, dynamic> config, dynamic)
      setConfig;

  @override
  State<PoketwoSniperConfig> createState() => _PoketwoSniperConfigState();
}

class _PoketwoSniperConfigState extends State<PoketwoSniperConfig> {
  dynamic poketwoSniper = {};

  @override
  void initState() {
    super.initState();
    poketwoSniper = widget.poketwoSniper;
  }

  String getLabelText() {
    final enabled = poketwoSniper['Enabled'] ?? false;

    if (!enabled) {
      return 'Disabled';
    }

    final channels = poketwoSniper['Channels'] ?? [];
    if (channels is List) {
      final channelCount = channels.length;

      return channelCount == 1
          ? 'Enabled in 1 channel'
          : 'Enabled in $channelCount channels';
    }

    return 'Enabled';
  }

  void onUpdate(dynamic poketwoSniper) {
    setState(() => this.poketwoSniper = poketwoSniper);
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: getLabelText());
    controller.addListener(() => controller.text = getLabelText());

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
          builder: (context) => PoketwoSniperDialog(
            name: widget.name,
            poketwoSniper: poketwoSniper,
            onUpdate: onUpdate,
            setConfig: widget.setConfig,
          ),
        );
      },
    );
  }
}

class PoketwoSniperDialog extends StatefulWidget {
  const PoketwoSniperDialog({
    Key? key,
    required this.name,
    required this.poketwoSniper,
    required this.onUpdate,
    required this.setConfig,
  }) : super(key: key);

  final String name;
  final dynamic poketwoSniper;
  final void Function(dynamic) onUpdate;
  final Map<String, dynamic> Function(Map<String, dynamic> config, dynamic)
      setConfig;

  @override
  State<PoketwoSniperDialog> createState() => _PoketwoSniperDialogState();
}

class _PoketwoSniperDialogState extends State<PoketwoSniperDialog> {
  dynamic poketwoSniper = {};

  @override
  void initState() {
    super.initState();
    poketwoSniper = widget.poketwoSniper;
  }

  String getLabelText() {
    final channels = poketwoSniper['Channels'] ?? [];
    if (channels is List) {
      final channelCount = channels.length;

      return channelCount == 1
          ? '1 channel selected'
          : '$channelCount channels selected';
    }

    return '0 channels selected';
  }

  Widget buildSwitchesRow1() {
    return SizedBox(
      width: 575,
      height: 70,
      child: Row(children: [
        Expanded(
          child: SwitchConfigCol(
            name: 'Enabled',
            info: 'Turn the PokéTwo sniper on or off.',
            defaultValue: poketwoSniper["Enabled"] ?? false,
            onChanged: (value) {
                poketwoSniper["Enabled"] = value;

                getIt<ConfigService>().config = widget.setConfig(
                    getIt<ConfigService>().config, poketwoSniper);
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFieldConfigCol(
            name: 'Timeout',
            info:
                'The amount of time to wait between catching Pokémon. (in seconds)',
            defaultValue: (poketwoSniper["Timeout"] ?? 0).toString(),
            numeric: true,
            onChanged: (value) {
                poketwoSniper["Timeout"] =
                    int.tryParse(value.isNotEmpty ? value : '0') ?? 0;

                getIt<ConfigService>().config = widget.setConfig(
                    getIt<ConfigService>().config, poketwoSniper);
            },
          ),
        ),
      ]),
    );
  }

  Widget buildSwitchesRow2() {
    return SizedBox(
      width: 575,
      height: 70,
      child: Row(children: [
        Expanded(
          child: TextFieldConfigCol(
            name: 'Sleep',
            info:
                'How long the sniper should wait before catching a Pokémon. (in seconds)',
            defaultValue: (poketwoSniper["Sleep"] ?? 0).toString(),
            numeric: true,
            onChanged: (value) {
                poketwoSniper["Sleep"] =
                    int.tryParse(value.isNotEmpty ? value : '0') ?? 0;

                getIt<ConfigService>().config = widget.setConfig(
                    getIt<ConfigService>().config, poketwoSniper);
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SwitchConfigCol(
            name: 'Random Sleep',
            info:
                'If enabled, the time before catching a Pokémon will be randomized with the maximum sleep time being the value of the sleep field.',
            defaultValue: poketwoSniper["RandomSleep"] ?? false,
            onChanged: (value) {
                poketwoSniper["RandomSleep"] = value;

                getIt<ConfigService>().config = widget.setConfig(
                    getIt<ConfigService>().config, poketwoSniper);
            },
          ),
        ),
      ]),
    );
  }

  Widget buildSwitchesRow3() {
    return SizedBox(
      width: 575,
      height: 70,
      child: Row(children: [
        Expanded(
          child: SwitchConfigCol(
            name: 'Typing',
            info:
                'If enabled, the you will be shown as typing before catching a Pokémon.',
            defaultValue: poketwoSniper["Typing"] ?? false,
            onChanged: (value) {
                poketwoSniper["Typing"] = value;

                getIt<ConfigService>().config = widget.setConfig(
                    getIt<ConfigService>().config, poketwoSniper);
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SwitchConfigCol(
            name: 'Fake Activity',
            info:
                'If enabled, the sniper will occasionally send random PokéTwo commands in the catching channels',
            defaultValue: poketwoSniper["FakeActivity"] ?? false,
            onChanged: (value) {
                poketwoSniper["FakeActivity"] = value;

                getIt<ConfigService>().config = widget.setConfig(
                    getIt<ConfigService>().config, poketwoSniper);
            },
          ),
        ),
      ]),
    );
  }

  Widget buildSwitchesRow4() {
    final controller = TextEditingController(text: getLabelText());
    controller.addListener(() => controller.text = getLabelText());

    return SizedBox(
      width: 575,
      height: 70,
      child: Row(children: [
        Expanded(
          child: TextFieldConfigCol(
            name: 'Catch Rate',
            info:
                'Percentage of Pokémon to catch. (0-100)\n\nIf set to 100, the sniper will try to catch all Pokémon that spawn in the channels you specify.',
            defaultValue: (poketwoSniper["CatchRate"] ?? 0).toString(),
            numeric: true,
            onChanged: (value) {
              poketwoSniper["CatchRate"] =
                  int.tryParse(value.isNotEmpty ? value : '0') ?? 0;

              getIt<ConfigService>().config = widget.setConfig(
                  getIt<ConfigService>().config, poketwoSniper);
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              labelText: "Channels",
              suffix: InfoIconButton(
                info:
                    "The channels that the PokéTwo sniper will try to catch Pokémon in.",
              ),
            ),
            controller: controller,
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
              showDialog(
                context: context,
                builder: (context) => PoketwoSniperChannelsDialog(
                  name: widget.name,
                  poketwoSniper: poketwoSniper,
                  onUpdate: widget.onUpdate,
                  setConfig: widget.setConfig,
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.name),
      content: SizedBox(
        width: 575,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildSwitchesRow1(),
            buildSwitchesRow2(),
            buildSwitchesRow3(),
            buildSwitchesRow4(),
          ],
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

class PoketwoSniperChannelsDialog extends StatefulWidget {
  const PoketwoSniperChannelsDialog({
    Key? key,
    required this.name,
    required this.poketwoSniper,
    required this.onUpdate,
    required this.setConfig,
  }) : super(key: key);

  final String name;
  final dynamic poketwoSniper;
  final void Function(dynamic) onUpdate;
  final Map<String, dynamic> Function(Map<String, dynamic> config, dynamic)
      setConfig;

  @override
  State<PoketwoSniperChannelsDialog> createState() =>
      _PoketwoSniperChannelsDialogState();
}

class _PoketwoSniperChannelsDialogState
    extends State<PoketwoSniperChannelsDialog> {
  dynamic poketwoSniper = {};

  @override
  void initState() {
    super.initState();
    poketwoSniper = widget.poketwoSniper;
  }

  Widget buildChannelListItem(dynamic text) {
    return InputChip(
      label: Text(text.toString()),
      backgroundColor: Colors.grey[700],
      deleteIcon: const Icon(Icons.close),
      onDeleted: () {
        setState(() {
          final channels = poketwoSniper['Channels'] ?? [];
          if (channels is! List) return;

          channels.remove(text);
          poketwoSniper['Channels'] = channels;

          getIt<ConfigService>().config =
              widget.setConfig(getIt<ConfigService>().config, poketwoSniper);
        });
      },
    );
  }

  List<Widget> textListItems() {
    final channels = poketwoSniper['Channels'] ?? [];
    if (channels is! List) return [];

    return channels.map(buildChannelListItem).toList();
  }

  Widget addTextButton(TextEditingController controller) {
    return IconButton(
      icon: Icon(
        Icons.add,
        color: Theme.of(context).colorScheme.primary,
      ),
      splashRadius: 20,
      onPressed: () {
        if (controller.text == '') return;

        setState(() {
          final channels = poketwoSniper['Channels'] ?? [];
          if (channels is! List) return;

          channels.add(controller.text);
          poketwoSniper['Channels'] = channels;

          getIt<ConfigService>().config =
              widget.setConfig(getIt<ConfigService>().config, poketwoSniper);
        });
        controller.clear();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return AlertDialog(
      title: Text(widget.name),
      content: SizedBox(
        width: 575,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Channels",
              style: GoogleFonts.montserrat(
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(spacing: 5, runSpacing: 5, children: textListItems()),
            const Divider(height: 50),
            SizedBox(
              height: 60,
              width: 400,
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Channel ID",
                  suffix: addTextButton(controller),
                ),
                controller: controller,
              ),
            ),
          ],
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
