import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightningui/config.dart';
import 'package:lightningui/main.dart';
import 'package:lightningui/widgets/configfields.dart';

class UserSelectionConfig extends StatefulWidget {
  const UserSelectionConfig({
    Key? key,
    required this.selectedUsers,
    required this.jsonQuery,
    required this.name,
    required this.info,
    required this.setConfig,
  }) : super(key: key);

  final List<dynamic> selectedUsers;
  final String jsonQuery;
  final String name;
  final String info;
  final Map<String, dynamic> Function(
      Map<String, dynamic> config, List<dynamic>) setConfig;

  @override
  State<UserSelectionConfig> createState() => _UserSelectionConfigState();
}

class _UserSelectionConfigState extends State<UserSelectionConfig> {
  List<dynamic> selectedUsers = [];

  @override
  void initState() {
    super.initState();
    selectedUsers = widget.selectedUsers;
  }

  String addS(int number) {
    return number == 1 ? "" : "s";
  }

  String getLabelText() {
    return '${selectedUsers.length} user${addS(selectedUsers.length)} selected';
  }

  void onUpdate(selectedUsers) {
    setState(() {
      this.selectedUsers = selectedUsers;
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
          builder: (context) => UserSelectionDialog(
            name: widget.name,
            selectedUsers: selectedUsers,
            onUpdate: onUpdate,
            setConfig: widget.setConfig,
          ),
        );
      },
    );
  }
}

class UserSelectionDialog extends StatefulWidget {
  const UserSelectionDialog({
    Key? key,
    required this.name,
    required this.selectedUsers,
    required this.onUpdate,
    required this.setConfig,
  }) : super(key: key);

  final String name;
  final List<dynamic> selectedUsers;
  final void Function(List<dynamic>) onUpdate;
  final Map<String, dynamic> Function(
      Map<String, dynamic> config, List<dynamic>) setConfig;

  @override
  State<UserSelectionDialog> createState() => _UserSelectionDialogState();
}

class _UserSelectionDialogState extends State<UserSelectionDialog> {
  List<dynamic> selectedUsers = [];

  @override
  void initState() {
    super.initState();
    selectedUsers = widget.selectedUsers;
  }

  Widget buildUserListItem(dynamic user) {
    return Chip(
      label: Text(user.toString()),
      backgroundColor: Colors.grey[700],
      deleteIcon: const Icon(Icons.close),
      onDeleted: () {
        setState(() {
          selectedUsers.remove(user);
          getIt<Config>().config = widget.setConfig(
            getIt<Config>().config,
            selectedUsers,
          );
        });
      },
    );
  }

  List<Widget> userListItems() {
    return selectedUsers.map(buildUserListItem).toList();
  }

  Widget addUserButton(BuildContext contect, TextEditingController controller) {
    return IconButton(
      icon: Icon(
        Icons.add,
        color: Theme.of(context).primaryColorLight,
      ),
      splashRadius: 20,
      onPressed: () {
        if (controller.text == '') return;

        setState(() {
          selectedUsers.add(controller.text);
          getIt<Config>().config =
              widget.setConfig(getIt<Config>().config, selectedUsers);
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
              "Users (Name/ID)",
              style: GoogleFonts.montserrat(
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(children: userListItems()),
            const Divider(height: 30),
            Text(
              "Add User",
              style: GoogleFonts.montserrat(
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 60,
              width: 400,
              child: TextField(
                decoration: InputDecoration(
                  labelText: "User Name/ID",
                  suffix: addUserButton(context, controller),
                ),
                controller: controller,
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
