import 'package:flutter/material.dart';

import 'package:lightningui/pages/config/account.dart';
import 'package:lightningui/pages/config/afk.dart';
import 'package:lightningui/pages/config/events.dart';
import 'package:lightningui/pages/config/notifications.dart';
import 'package:lightningui/pages/config/protections.dart';
import 'package:lightningui/pages/config/rpc.dart';
import 'package:lightningui/pages/config/selfbot.dart';
import 'package:lightningui/pages/config/sharing.dart';
import 'package:lightningui/pages/config/snipers.dart';
import 'package:lightningui/pages/config/ui.dart';
import 'package:lightningui/pages/config/webhooks.dart';

import '../ipc.dart';

const tabs = [
  Tab(text: "Account"),
  Tab(text: "Selfbot"),
  Tab(text: "Notifications"),
  Tab(text: "Snipers"),
  Tab(text: "Webhooks"),
  Tab(text: "Events"),
  Tab(text: "RPC"),
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
  @override
  void initState() {
    super.initState();
    void listener() {
      if (mounted) {
        setState(() {});
      } else {
        IPC.removeConfigChangeListener("configPage");
      }
    }

    IPC.addConfigChangeListener("configPage", listener);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height - 65;
    final width = size.width - 170;

    return ListView(
      children: [
        DefaultTabController(
          length: 11,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).primaryColor,
                ),
                child: TabBar(
                  isScrollable: true,
                  splashBorderRadius: BorderRadius.circular(12),
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: const Color(0xFF47A7FF),
                  tabs: tabs,
                ),
              ),
              SizedBox(
                width: width,
                height: height - 50,
                child: const TabBarView(
                  children: [
                    AccountConfigPage(),
                    SelfbotConfigPage(),
                    NotificationsConfigPage(),
                    SnipersConfigPage(),
                    WebhooksConfigPage(),
                    EventsConfigPage(),
                    RPCConfigPage(),
                    UIConfigPage(),
                    ProtectionsConfigPage(),
                    AFKConfigPage(),
                    SharingConfigPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
