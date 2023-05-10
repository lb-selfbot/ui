import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightningui/services/config_service.dart';
import 'package:lightningui/main.dart';
import 'package:lightningui/widgets/config_fields.dart';

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
      Map<String, dynamic> config, List<dynamic>) setConfig;

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
    return triggerList['Type'] ?? 'Unknown';
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
      Map<String, dynamic> config, List<dynamic>) setConfig;

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

  Widget buildTextListItem(dynamic text) {
    return Chip(
      label: Text(text.toString()),
      backgroundColor: Colors.grey[700],
      deleteIcon: const Icon(Icons.close),
      onDeleted: () {
        setState(() {
          // triggerList.remove(text);
          // getIt<ConfigService>().config = widget.setConfig(
          //   getIt<ConfigService>().config,
          //   selectedTexts,
          // );
        });
      },
    );
  }

  List<Widget> textListItems() {
    return [];
    // return selectedTexts.map(buildTextListItem).toList();
  }

  Widget addTextButton(BuildContext contect, TextEditingController controller) {
    return IconButton(
      icon: Icon(
        Icons.add,
        color: Theme.of(context).colorScheme.primary,
      ),
      splashRadius: 20,
      onPressed: () {
        if (controller.text == '') return;

        setState(() {
          // selectedTexts.add(controller.text);
          // getIt<ConfigService>().config =
          //     widget.setConfig(getIt<ConfigService>().config, selectedTexts);
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
              "Entries",
              style: GoogleFonts.montserrat(
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(children: textListItems()),
            const Divider(height: 30),
            Text(
              "Add Entry",
              style: GoogleFonts.montserrat(
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 60,
              width: 400,
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Text",
                  suffix: addTextButton(context, controller),
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
