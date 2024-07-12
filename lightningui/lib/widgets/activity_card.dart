import 'package:flutter/material.dart';
import 'package:lightningui/services/config_service.dart';
import 'package:lightningui/main.dart';
import 'package:lightningui/widgets/activity.dart';

class ActivityCard extends StatefulWidget {
  const ActivityCard({Key? key}) : super(key: key);

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  void onConfigChange() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    getIt<ConfigService>().removeListener(onConfigChange);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getIt<ConfigService>().addListener(onConfigChange);
  }

  Widget buildHeader(ThemeData theme) {
    final borderSide =
        BorderSide(width: 5.0, color: theme.colorScheme.primaryContainer);
    final border = Border(
      top: borderSide,
      left: borderSide,
      right: borderSide,
      bottom: borderSide,
    );

    return Stack(
      children: [
        Container(height: 120),
        Container(
          height: 70,
          color: theme.colorScheme.primaryContainer,
        ),
        Positioned(
          left: 15,
          top: 15,
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withAlpha(200),
              shape: BoxShape.circle,
              border: border,
            ),
            child: Center(
              child: Image.asset(
                'assets/Logo.png',
                height: 85,
                width: 85,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildUsername() {
    return const Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'LightningBot',
            style: TextStyle(fontSize: 20),
          ),
          TextSpan(
            text: '#1234',
            style: TextStyle(
              color: Color(0xFFb0b2b5),
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUserInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "ABOUT ME",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "LightningBot Activity Preview",
          style: TextStyle(
            color: Color(0xFFb0b2b5),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget buildRPCButton(String text) {
    const buttonStyle = ButtonStyle(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
      ),
      backgroundColor: WidgetStatePropertyAll(Color(0xFF14558d)),
    );

    return FractionallySizedBox(
      widthFactor: 1,
      child: FilledButton(
        onPressed: () {},
        style: buttonStyle,
        child: Text(text),
      ),
    );
  }

  List<Widget> buildRPCButtons() {
    final config = getIt<ConfigService>().config;

    final isRPC = config["Activity"]["ActivityType"] == "RPC";
    final isSpotify = !isRPC && config["Activity"]["Type"] == "Spotify";
    final isPlaying = !isRPC && config["Activity"]["Type"] == "Playing";

    if (isRPC && config["Activity"]["Invitable"]) {
      return [];
    }

    if (isSpotify) {
      return [
        const SizedBox(height: 10),
        buildRPCButton("Play on Spotify"),
      ];
    }

    if (isPlaying) {
      switch (config["Activity"]["Platform"]) {
        case "PS4":
        case "PS5":
          return [
            const SizedBox(height: 10),
            buildRPCButton("Connect PlayStation Network"),
          ];
        case "Xbox":
          return [
            const SizedBox(height: 10),
            buildRPCButton("Connect Xbox"),
          ];
        case "Samsung":
          return [];
      }
    }

    List<Widget> buttons = [];

    if (config["Activity"]["Button1Label"] != "") {
      buttons.add(const SizedBox(height: 10));
      buttons.add(buildRPCButton(config["Activity"]["Button1Label"]));
    }

    if (config["Activity"]["Button2Label"] != "") {
      buttons.add(const SizedBox(height: 10));
      buttons.add(buildRPCButton(config["Activity"]["Button2Label"]));
    }

    return buttons;
  }

  String getActivityText() {
    final config = getIt<ConfigService>().config;

    final nameObject = config["Activity"]["Name"];

    if (nameObject is! String) {
      return "PLAYING A GAME";
    }

    final name = nameObject.toUpperCase();

    if (config["Activity"]["ActivityType"] == "RPC") {
      return "PLAYING A GAME";
    }

    return switch (config["Activity"]["Type"]) {
      "Playing" => switch (config["Activity"]["Platform"]) {
          "Default" => "Playing a game",
          "PS4" => "Playing on PS4",
          "PS5" => "Playing on PS5",
          "Xbox" => "Playing on Xbox",
          "Samsung" => "Playing on Samsung Galaxy",
          _ => "Playing a game"
        },
      "Listening" => "Listening to $name",
      "Watching" => "Watching $name",
      "Competing" => "Competing in $name",
      "Streaming" => "Live on Twitch",
      "Spotify" => "Listening to Spotify",
      _ => "Playing a game",
    };
  }

  Widget buildActivity(dynamic activity) {
    final joinButton = [
      const SizedBox(height: 10),
      buildRPCButton("Ask to Join"),
    ];

    final joinable = activity["ActivityType"] == "RPC" && activity["Invitable"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getActivityText(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        const Activity(),
        if (joinable) ...joinButton,
        ...buildRPCButtons(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = getIt<ConfigService>().config;
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          buildHeader(theme),
          Expanded(
            child: Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              margin: const EdgeInsets.all(12),
              color: theme.colorScheme.surface,
              surfaceTintColor: theme.colorScheme.surface,
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(10),
                children: [
                  buildUsername(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                    child: Divider(
                      color: Color(0xFF332F33),
                      thickness: 3,
                    ),
                  ),
                  buildUserInfo(),
                  const SizedBox(height: 20),
                  if (config["Activity"]["Enabled"])
                    buildActivity(config["Activity"]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
