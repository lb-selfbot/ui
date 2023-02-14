import 'package:flutter/material.dart';
import 'package:lightningui/config.dart';
import 'package:lightningui/main.dart';
import 'package:lightningui/utils.dart';
import 'package:lightningui/widgets/dialogs/categoryselection.dart';
import 'package:lightningui/widgets/dialogs/commandselection.dart';
import 'package:lightningui/widgets/dialogs/serverprotections.dart';
import 'package:lightningui/widgets/dialogs/serverselection.dart';
import 'package:lightningui/widgets/dialogs/textselection.dart';
import 'package:lightningui/widgets/dialogs/userselection.dart';
import 'package:responsive_grid/responsive_grid.dart';

import 'configfields.dart';

class ConfigEditor extends StatelessWidget {
  const ConfigEditor({
    Key? key,
    required this.fields,
    this.fullWidthElements = false,
  }) : super(key: key);

  final List<Map<String, dynamic>> fields;
  final bool fullWidthElements;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: ListView(
        physics: const ClampingScrollPhysics(),
        children: [
          ResponsiveGridRow(
            children: fields.map((f) => fieldToElement(context, f)).toList(),
          ),
        ],
      ),
    );
  }

  ResponsiveGridCol fieldToElement(
    BuildContext context,
    Map<String, dynamic> field,
  ) {
    final type = field['type'] as String;

    Widget? widget;
    switch (type) {
      case 'text':
      case 'url':
        widget = TextFieldConfigCol(
          name: field['name'] as String,
          info: field['info'] as String,
          defaultValue: Utils.getJsonElement(
            field['jsonQuery'],
            getIt<Config>().config,
          ),
          obscure: field['obscure'] != null,
          onChanged: (value) {
            if (field["set"] != null) {
              getIt<Config>().config = field["set"](
                getIt<Config>().config,
                value,
              );
            }
          },
        );
        break;
      case 'switch':
        widget = SwitchConfigCol(
          name: field['name'] as String,
          info: field['info'] as String,
          defaultValue: Utils.getJsonElement(
            field['jsonQuery'],
            getIt<Config>().config,
          ),
          onChanged: (value) {
            if (field["set"] != null) {
              getIt<Config>().config = field["set"](
                getIt<Config>().config,
                value,
              );
            }
          },
        );
        break;
      case 'dropdown':
        widget = DropdownConfigCol(
          name: field['name'] as String,
          info: field['info'] as String,
          options: field['options'] as List<Map<String, dynamic>>,
          defaultValue: Utils.getJsonElement(
            field['jsonQuery'],
            getIt<Config>().config,
          ),
          onChanged: (value) {
            if (field["set"] != null) {
              getIt<Config>().config = field["set"](
                getIt<Config>().config,
                value,
              );
            }
          },
        );
        break;
      case 'number':
        widget = TextFieldConfigCol(
          name: field['name'] as String,
          info: field['info'] as String,
          defaultValue: Utils.getJsonElement(
            field['jsonQuery'],
            getIt<Config>().config,
          ).toString(),
          numeric: true,
          onChanged: (value) {
            if (field["set"] != null) {
              getIt<Config>().config = field["set"](
                getIt<Config>().config,
                int.tryParse(value.isNotEmpty ? value : '0') ?? 0,
              );
            }
          },
        );
        break;
      case 'server_protections_dialog':
        final antiDelete = Utils.getJsonElement(
          "Protections/ServerProtections/AntiDelete",
          getIt<Config>().config,
        );
        final antiInvite = Utils.getJsonElement(
          "Protections/ServerProtections/AntiInvite",
          getIt<Config>().config,
        );
        final antiSpam = Utils.getJsonElement(
          "Protections/ServerProtections/AntiSpam",
          getIt<Config>().config,
        );
        final antiUpper = Utils.getJsonElement(
          "Protections/ServerProtections/AntiUpper",
          getIt<Config>().config,
        );
        final protectedServers = Utils.getJsonElement(
          "Protections/ServerProtections/ProtectedServers",
          getIt<Config>().config,
        ) as List<dynamic>;

        widget = ServerProtectionsConfig(
          antiDelete: antiDelete,
          antiInvite: antiInvite,
          antiSpam: antiSpam,
          antiUpper: antiUpper,
          protectedServers: protectedServers,
        );
        break;
      case 'user_selection_dialog':
        final selectedUsers = Utils.getJsonElement(
          field['jsonQuery'] as String,
          getIt<Config>().config,
        );
        widget = UserSelectionConfig(
          selectedUsers: selectedUsers,
          jsonQuery: field['jsonQuery'] as String,
          name: field['name'] as String,
          info: field['info'] as String,
          setConfig: field['set'] as Map<String, dynamic> Function(
            Map<String, dynamic>,
            List<dynamic>,
          ),
        );
        break;
      case 'server_selection_dialog':
        final selectedServers = Utils.getJsonElement(
          field['jsonQuery'] as String,
          getIt<Config>().config,
        );
        widget = ServerSelectionConfig(
          selectedServers: selectedServers,
          jsonQuery: field['jsonQuery'] as String,
          name: field['name'] as String,
          info: field['info'] as String,
          setConfig: field['set'] as Map<String, dynamic> Function(
            Map<String, dynamic>,
            List<dynamic>,
          ),
        );
        break;
      case 'category_selection_dialog':
        final selectedCategories = Utils.getJsonElement(
          field['jsonQuery'] as String,
          getIt<Config>().config,
        );
        widget = CategorySelectionConfig(
          selectedCategories: selectedCategories,
          jsonQuery: field['jsonQuery'] as String,
          name: field['name'] as String,
          info: field['info'] as String,
          setConfig: field['set'] as Map<String, dynamic> Function(
            Map<String, dynamic>,
            List<dynamic>,
          ),
        );
        break;
      case 'command_selection_dialog':
        final selectedCommands = Utils.getJsonElement(
          field['jsonQuery'] as String,
          getIt<Config>().config,
        );
        widget = CommandSelectionConfig(
          selectedCommands: selectedCommands,
          jsonQuery: field['jsonQuery'] as String,
          name: field['name'] as String,
          info: field['info'] as String,
          setConfig: field['set'] as Map<String, dynamic> Function(
            Map<String, dynamic>,
            List<dynamic>,
          ),
        );
        break;
      case 'text_selection_dialog':
        final selectedTexts = Utils.getJsonElement(
          field['jsonQuery'] as String,
          getIt<Config>().config,
        );
        widget = TextSelectionConfig(
          selectedTexts: selectedTexts,
          jsonQuery: field['jsonQuery'] as String,
          name: field['name'] as String,
          info: field['info'] as String,
          setConfig: field['set'] as Map<String, dynamic> Function(
            Map<String, dynamic>,
            List<dynamic>,
          ),
        );
        break;
    }
    return ResponsiveGridCol(
      xs: 12,
      md: fullWidthElements ? 12 : 6,
      child: Container(
        height: 70,
        alignment: const Alignment(0, 0),
        padding: const EdgeInsets.all(5),
        child: widget,
      ),
    );
  }
}
