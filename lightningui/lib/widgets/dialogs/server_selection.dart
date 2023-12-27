import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightningui/services/config_service.dart';
import 'package:lightningui/main.dart';
import 'package:lightningui/widgets/config_fields.dart';

class ServerSelectionConfig extends StatefulWidget {
  const ServerSelectionConfig({
    Key? key,
    required this.selectedServers,
    required this.jsonQuery,
    required this.name,
    required this.info,
    required this.setConfig,
  }) : super(key: key);

  final List<dynamic> selectedServers;
  final String jsonQuery;
  final String name;
  final String info;
  final Map<String, dynamic> Function(
      Map<String, dynamic> config, List<dynamic>) setConfig;

  @override
  State<ServerSelectionConfig> createState() => _ServerSelectionConfigState();
}

class _ServerSelectionConfigState extends State<ServerSelectionConfig> {
  List<dynamic> selectedServers = [];

  @override
  void initState() {
    super.initState();
    selectedServers = widget.selectedServers;
  }

  String addS(int number) {
    return number == 1 ? "" : "s";
  }

  String getLabelText() {
    return '${selectedServers.length} server${addS(selectedServers.length)} selected';
  }

  void onUpdate(selectedServers) {
    setState(() {
      this.selectedServers = selectedServers;
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
          builder: (context) => ServerSelectionDialog(
            name: widget.name,
            selectedServers: selectedServers,
            onUpdate: onUpdate,
            setConfig: widget.setConfig,
          ),
        );
      },
    );
  }
}

class ServerSelectionDialog extends StatefulWidget {
  const ServerSelectionDialog({
    Key? key,
    required this.name,
    required this.selectedServers,
    required this.onUpdate,
    required this.setConfig,
  }) : super(key: key);

  final String name;
  final List<dynamic> selectedServers;
  final void Function(List<dynamic>) onUpdate;
  final Map<String, dynamic> Function(
      Map<String, dynamic> config, List<dynamic>) setConfig;

  @override
  State<ServerSelectionDialog> createState() => _ServerSelectionDialogState();
}

class _ServerSelectionDialogState extends State<ServerSelectionDialog> {
  List<dynamic> selectedServers = [];

  @override
  void initState() {
    super.initState();
    selectedServers = widget.selectedServers;
  }

  Widget buildServerListItem(dynamic server) {
    return Chip(
      label: Text(server.toString()),
      backgroundColor: Colors.grey[700],
      deleteIcon: const Icon(Icons.close),
      onDeleted: () {
        setState(() {
          selectedServers.remove(server);
          getIt<ConfigService>().config = widget.setConfig(
            getIt<ConfigService>().config,
            selectedServers,
          );
        });
      },
    );
  }

  List<Widget> serverListItems() {
    return selectedServers.map(buildServerListItem).toList();
  }

  Widget addServerButton(
      BuildContext contect, TextEditingController controller) {
    return IconButton(
      icon: Icon(
        Icons.add,
        color: Theme.of(context).colorScheme.primary,
      ),
      splashRadius: 20,
      onPressed: () {
        if (controller.text == '') return;

        setState(() {
          selectedServers.add(controller.text);
          getIt<ConfigService>().config =
              widget.setConfig(getIt<ConfigService>().config, selectedServers);
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
              "Servers (ID)",
              style: GoogleFonts.montserrat(
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(spacing: 5, runSpacing: 5, children: serverListItems()),
            const Divider(height: 30),
            Text(
              "Add Server",
              style: GoogleFonts.montserrat(
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 60,
              width: 400,
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Server ID",
                  suffix: addServerButton(context, controller),
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
