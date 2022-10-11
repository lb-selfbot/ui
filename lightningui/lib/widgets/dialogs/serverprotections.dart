import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightningui/config.dart';
import 'package:lightningui/widgets/configfields.dart';

class ServerProtectionsConfig extends StatefulWidget {
  const ServerProtectionsConfig({
    Key? key,
    required this.antiDelete,
    required this.antiInvite,
    required this.antiSpam,
    required this.antiUpper,
    required this.protectedServers,
  }) : super(key: key);

  final dynamic antiDelete;
  final dynamic antiInvite;
  final dynamic antiSpam;
  final dynamic antiUpper;
  final List<dynamic> protectedServers;

  @override
  State<ServerProtectionsConfig> createState() =>
      _ServerProtectionsConfigState();
}

class _ServerProtectionsConfigState extends State<ServerProtectionsConfig> {
  bool antiDelete = false;
  bool antiInvite = false;
  bool antiSpam = false;
  bool antiUpper = false;
  List<dynamic> protectedServers = [];

  @override
  void initState() {
    super.initState();
    antiDelete = widget.antiDelete;
    antiInvite = widget.antiInvite;
    antiSpam = widget.antiSpam;
    antiUpper = widget.antiUpper;
    protectedServers = widget.protectedServers;
  }

  String addS(int number) {
    return number == 1 ? "" : "s";
  }

  String getLabelText() {
    int enabledProtections = 0;
    if (antiDelete == true) enabledProtections++;
    if (antiInvite == true) enabledProtections++;
    if (antiSpam == true) enabledProtections++;
    if (antiUpper == true) enabledProtections++;
    int servers = protectedServers.length;
    return '$enabledProtections protection${addS(enabledProtections)} enabled in $servers server${addS(servers)}';
  }

  void onUpdate(antiDelete, antiInvite, antiSpam, antiUpper, protectedServers) {
    setState(() {
      this.antiDelete = antiDelete;
      this.antiInvite = antiInvite;
      this.antiSpam = antiSpam;
      this.antiUpper = antiUpper;
      this.protectedServers = protectedServers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: getLabelText());

    controller.addListener(() {
      controller.text = getLabelText();
    });

    return TextField(
      decoration: const InputDecoration(
        labelText: 'Server Protections',
        suffix: InfoIconButton(
          info: 'Protect your servers from malicious users.',
        ),
      ),
      controller: controller,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        showDialog(
          context: context,
          builder: (context) => ServerProtectionsDialog(
            antiDelete: antiDelete,
            antiInvite: antiInvite,
            antiSpam: antiSpam,
            antiUpper: antiUpper,
            protectedServers: protectedServers,
            onUpdate: onUpdate,
          ),
        );
      },
    );
  }
}

class ServerProtectionsDialog extends StatefulWidget {
  const ServerProtectionsDialog({
    Key? key,
    required this.antiDelete,
    required this.antiInvite,
    required this.antiSpam,
    required this.antiUpper,
    required this.protectedServers,
    required this.onUpdate,
  }) : super(key: key);

  final dynamic antiDelete;
  final dynamic antiInvite;
  final dynamic antiSpam;
  final dynamic antiUpper;
  final List<dynamic> protectedServers;
  final void Function(
    bool antiDelete,
    bool antiInvite,
    bool antiSpam,
    bool antiUpper,
    List<dynamic> protectedServers,
  ) onUpdate;

  @override
  State<ServerProtectionsDialog> createState() =>
      _ServerProtectionsDialogState();
}

class _ServerProtectionsDialogState extends State<ServerProtectionsDialog> {
  bool antiDelete = false;
  bool antiInvite = false;
  bool antiSpam = false;
  bool antiUpper = false;
  List<dynamic> protectedServers = [];

  @override
  void initState() {
    super.initState();
    antiDelete = widget.antiDelete;
    antiInvite = widget.antiInvite;
    antiSpam = widget.antiSpam;
    antiUpper = widget.antiUpper;
    protectedServers = widget.protectedServers;
  }

  Widget buildServerListItem(dynamic server) {
    return Chip(
      label: Text(server.toString()),
      backgroundColor: Colors.grey[700],
      deleteIcon: const Icon(Icons.close),
      onDeleted: () {
        setState(() {
          protectedServers.remove(server);
          final config = Config.config;
          config['Protections']['ServerProtections']['ProtectedServers'] =
              protectedServers;
          Config.config = config;
        });
      },
    );
  }

  List<Widget> serverListItems() {
    return protectedServers.map(buildServerListItem).toList();
  }

  Widget addServerButton(
      BuildContext contect, TextEditingController controller) {
    return IconButton(
      icon: Icon(
        Icons.add,
        color: Theme.of(context).primaryColorLight,
      ),
      splashRadius: 20,
      onPressed: () {
        if (controller.text == '') return;

        setState(() {
          protectedServers.add(controller.text);
          final config = Config.config;
          config['Protections']['ServerProtections']['ProtectedServers'] =
              protectedServers;
          Config.config = config;
        });
        controller.clear();
      },
    );
  }

  Widget buildUpperSwitches() {
    return SizedBox(
      width: 575,
      child: Row(children: [
        Expanded(
          child: SwitchConfigCol(
            name: 'Anti Delete',
            info:
                'Get notified when a message is deleted in protected servers.',
            defaultValue: widget.antiDelete,
            onChanged: (value) {
              setState(() {
                antiDelete = value;
                widget.onUpdate(antiDelete, antiInvite, antiSpam, antiUpper,
                    protectedServers);
              });
              final config = Config.config;
              config['Protections']['ServerProtections']['AntiDelete'] = value;
              Config.config = config;
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SwitchConfigCol(
            name: 'Anti Invite',
            info: 'Deletes invites sent by users in protected servers.',
            defaultValue: widget.antiInvite,
            onChanged: (value) {
              setState(() {
                antiInvite = value;
                widget.onUpdate(antiDelete, antiInvite, antiSpam, antiUpper,
                    protectedServers);
              });
              final config = Config.config;
              config['Protections']['ServerProtections']['AntiInvite'] = value;
              Config.config = config;
            },
          ),
        ),
      ]),
    );
  }

  Widget buildLowerSwitches() {
    return SizedBox(
      width: 575,
      child: Row(children: [
        Expanded(
          child: SwitchConfigCol(
            name: 'Anti Spam',
            info: 'Stops users from spamming messages in protected servers.',
            defaultValue: widget.antiSpam,
            onChanged: (value) {
              setState(() {
                antiSpam = value;
                widget.onUpdate(antiDelete, antiInvite, antiSpam, antiUpper,
                    protectedServers);
              });
              final config = Config.config;
              config['Protections']['ServerProtections']['AntiSpam'] = value;
              Config.config = config;
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SwitchConfigCol(
            name: 'Anti Upper',
            info:
                'Stops users from only using uppercase letters in protected servers.',
            defaultValue: widget.antiUpper,
            onChanged: (value) {
              setState(() {
                antiUpper = value;
                widget.onUpdate(antiDelete, antiInvite, antiSpam, antiUpper,
                    protectedServers);
              });
              final config = Config.config;
              config['Protections']['ServerProtections']['AntiUpper'] = value;
              Config.config = config;
            },
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return AlertDialog(
      title: const Text("Server Protections"),
      content: SizedBox(
        width: 575,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Servers (Name/ID)",
              style: GoogleFonts.montserrat(
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(children: serverListItems()),
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
                  labelText: "Server Name/ID",
                  suffix: addServerButton(context, controller),
                ),
                controller: controller,
              ),
            ),
            const Divider(height: 50),
            buildUpperSwitches(),
            buildLowerSwitches(),
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
