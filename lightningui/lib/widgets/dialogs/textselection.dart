import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightningui/services/config_service.dart';
import 'package:lightningui/main.dart';
import 'package:lightningui/widgets/configfields.dart';

class TextSelectionConfig extends StatefulWidget {
  const TextSelectionConfig({
    Key? key,
    required this.selectedTexts,
    required this.jsonQuery,
    required this.name,
    required this.info,
    required this.setConfig,
  }) : super(key: key);

  final List<dynamic> selectedTexts;
  final String jsonQuery;
  final String name;
  final String info;
  final Map<String, dynamic> Function(
      Map<String, dynamic> config, List<dynamic>) setConfig;

  @override
  State<TextSelectionConfig> createState() => _TextSelectionConfigState();
}

class _TextSelectionConfigState extends State<TextSelectionConfig> {
  List<dynamic> selectedTexts = [];

  @override
  void initState() {
    super.initState();
    selectedTexts = widget.selectedTexts;
  }

  String getLabelText() {
    if (selectedTexts.length == 1) {
      return '1 entry selected';
    } else {
      return '${selectedTexts.length} entries selected';
    }
  }

  void onUpdate(selectedTexts) {
    setState(() {
      this.selectedTexts = selectedTexts;
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
          builder: (context) => TextSelectionDialog(
            name: widget.name,
            selectedTexts: selectedTexts,
            onUpdate: onUpdate,
            setConfig: widget.setConfig,
          ),
        );
      },
    );
  }
}

class TextSelectionDialog extends StatefulWidget {
  const TextSelectionDialog({
    Key? key,
    required this.name,
    required this.selectedTexts,
    required this.onUpdate,
    required this.setConfig,
  }) : super(key: key);

  final String name;
  final List<dynamic> selectedTexts;
  final void Function(List<dynamic>) onUpdate;
  final Map<String, dynamic> Function(
      Map<String, dynamic> config, List<dynamic>) setConfig;

  @override
  State<TextSelectionDialog> createState() => _TextSelectionDialogState();
}

class _TextSelectionDialogState extends State<TextSelectionDialog> {
  List<dynamic> selectedTexts = [];

  @override
  void initState() {
    super.initState();
    selectedTexts = widget.selectedTexts;
  }

  Widget buildTextListItem(dynamic text) {
    return Chip(
      label: Text(text.toString()),
      backgroundColor: Colors.grey[700],
      deleteIcon: const Icon(Icons.close),
      onDeleted: () {
        setState(() {
          selectedTexts.remove(text);
          getIt<ConfigService>().config = widget.setConfig(
            getIt<ConfigService>().config,
            selectedTexts,
          );
        });
      },
    );
  }

  List<Widget> textListItems() {
    return selectedTexts.map(buildTextListItem).toList();
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
          selectedTexts.add(controller.text);
          getIt<ConfigService>().config =
              widget.setConfig(getIt<ConfigService>().config, selectedTexts);
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
