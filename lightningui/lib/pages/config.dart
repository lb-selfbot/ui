import 'package:flutter/material.dart';

import 'package:lightningui/pages/config/account.dart';
import 'package:lightningui/pages/config/afk.dart';
import 'package:lightningui/pages/config/events.dart';
import 'package:lightningui/pages/config/notifications.dart';
import 'package:lightningui/pages/config/protections.dart';
import 'package:lightningui/pages/config/selfbot.dart';
import 'package:lightningui/pages/config/sharing.dart';
import 'package:lightningui/pages/config/snipers.dart';
import 'package:lightningui/pages/config/ui.dart';
import 'package:lightningui/pages/config/webhooks.dart';
import 'package:lightningui/ipc.dart';

const tabs = [
  Tab(text: "Account"),
  Tab(text: "Selfbot"),
  Tab(text: "Notifications"),
  Tab(text: "Snipers"),
  Tab(text: "Webhooks"),
  Tab(text: "Events"),
  Tab(text: "UI"),
  Tab(text: "Protections"),
  Tab(text: "AFK"),
  Tab(text: "Sharing"),
];

class ConfigPage extends StatefulWidget {
  const ConfigPage({Key? key}) : super(key: key);

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  // Dummy variable to force a rebuild when the config changes.
  int x = 0;

  @override
  void initState() {
    super.initState();

    IPC.addConfigChangeListener("configPage", onConfigChange);
  }

  void onConfigChange() {
    if (mounted) {
      setState(() => x++);
    } else {
      IPC.removeConfigChangeListener("configPage");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height - 65;
    final width = size.width - 170;

    return DefaultTabController(
      length: 10,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 20, right: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: TabBar(
              isScrollable: true,
              splashBorderRadius: BorderRadius.circular(12),
              indicatorSize: TabBarIndicatorSize.label,
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabs: tabs,
            ),
          ),
          SizedBox(
            width: width,
            height: height - 50,
            child: TabBarView(
              children: [
                AccountConfigPage(x: x),
                const SelfbotConfigPage(),
                const NotificationsConfigPage(),
                const SnipersConfigPage(),
                const WebhooksConfigPage(),
                const EventsConfigPage(),
                const UIConfigPage(),
                const ProtectionsConfigPage(),
                const AFKConfigPage(),
                const SharingConfigPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
