import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightningui/config.dart';
import 'package:lightningui/utils.dart';
import 'package:lightningui/widgets/configfields.dart';
import 'package:searchfield/searchfield.dart';

class CommandSelectionConfig extends StatefulWidget {
  const CommandSelectionConfig({
    Key? key,
    required this.selectedCommands,
    required this.jsonQuery,
    required this.name,
    required this.info,
    required this.setConfig,
  }) : super(key: key);

  final List<dynamic> selectedCommands;
  final String jsonQuery;
  final String name;
  final String info;
  final Map<String, dynamic> Function(
      Map<String, dynamic> config, List<dynamic>) setConfig;

  @override
  State<CommandSelectionConfig> createState() => _CommandSelectionConfigState();
}

class _CommandSelectionConfigState extends State<CommandSelectionConfig> {
  List<dynamic> selectedCommands = [];

  @override
  void initState() {
    super.initState();
    selectedCommands = widget.selectedCommands;
  }

  String addS(int number) {
    return number == 1 ? "" : "s";
  }

  String getLabelText() {
    final commandText = selectedCommands.length == 1 ? "command" : "commands";
    return '${selectedCommands.length} $commandText selected';
  }

  void onUpdate(selectedCommands) {
    setState(() {
      this.selectedCommands = selectedCommands;
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
          builder: (context) => CommandSelectionDialog(
            name: widget.name,
            selectedCommands: selectedCommands,
            onUpdate: onUpdate,
            setConfig: widget.setConfig,
          ),
        );
      },
    );
  }
}

class CommandSelectionDialog extends StatefulWidget {
  const CommandSelectionDialog({
    Key? key,
    required this.name,
    required this.selectedCommands,
    required this.onUpdate,
    required this.setConfig,
  }) : super(key: key);

  final String name;
  final List<dynamic> selectedCommands;
  final void Function(List<dynamic>) onUpdate;
  final Map<String, dynamic> Function(
      Map<String, dynamic> config, List<dynamic>) setConfig;

  @override
  State<CommandSelectionDialog> createState() => _CommandSelectionDialogState();
}

class _CommandSelectionDialogState extends State<CommandSelectionDialog> {
  List<dynamic> selectedCommands = [];

  @override
  void initState() {
    super.initState();
    selectedCommands = widget.selectedCommands;
  }

  Widget buildCommandListItem(dynamic command) {
    return Chip(
      label: Text(command.toString()),
      backgroundColor: Colors.grey[700],
      deleteIcon: const Icon(Icons.close),
      onDeleted: () {
        setState(() {
          selectedCommands.remove(command);
          Config.config = widget.setConfig(Config.config, selectedCommands);
        });
      },
    );
  }

  List<Widget> commandListItems() {
    return selectedCommands.map(buildCommandListItem).toList();
  }

  Widget addCommandButton(
      BuildContext contect, TextEditingController controller) {
    return IconButton(
      icon: Icon(
        Icons.add,
        color: Theme.of(context).primaryColorLight,
      ),
      splashRadius: 20,
      onPressed: () {
        if (!Utils.commands.contains(controller.text)) return;

        setState(() {
          selectedCommands.add(controller.text);
          Config.config = widget.setConfig(Config.config, selectedCommands);
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
              "Commands",
              style: GoogleFonts.montserrat(
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(children: commandListItems()),
            const Divider(height: 30),
            Text(
              "Add Command",
              style: GoogleFonts.montserrat(
                fontSize: 20,
              ),
            ),
            SizedBox(
              //height: 60,
              width: 400,
              child: SearchField<String>(
                suggestions: Utils.commands
                    .where((e) => !selectedCommands.contains(e))
                    .map((e) => SearchFieldListItem<String>(e,
                        item: e, child: Text("  $e")))
                    .toList(),
                controller: controller,
                searchInputDecoration: InputDecoration(
                  labelText: "Command",
                  suffix: addCommandButton(context, controller),
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
