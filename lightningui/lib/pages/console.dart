import 'package:flutter/material.dart';
import 'package:lightningui/paths.dart';

import 'package:responsive_grid/responsive_grid.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lightningui/api.dart';
import 'package:lightningui/services/config_service.dart';
import 'package:lightningui/ipc.dart';
import 'package:lightningui/main.dart';
import 'package:lightningui/utils.dart';
import 'package:lightningui/launching.dart';
import 'package:lightningui/widgets/info_card.dart';

class Console extends StatelessWidget {
  const Console({Key? key, required this.consoleText}) : super(key: key);

  final String consoleText;

  @override
  Widget build(BuildContext context) {
    final font = GoogleFonts.robotoMono();

    return Html(
      data: "<pre>$consoleText</pre>",
      style: {
        "*": Style(
          fontFamily: font.fontFamily,
          fontWeight: FontWeight.w400,
        ),
      },
    );
  }
}

class ConsoleButton extends StatelessWidget {
  const ConsoleButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.loading = false,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String text;
  final bool loading;

  Widget loadingIcon() {
    return Container(
      width: 24,
      height: 24,
      padding: const EdgeInsets.all(2.0),
      child: const CircularProgressIndicator(strokeWidth: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.all(
        Theme.of(context).colorScheme.inversePrimary,
      ),
    );

    if (loading) {
      return ElevatedButton.icon(
        onPressed: null,
        style: buttonStyle,
        icon: loadingIcon(),
        label: Text(text),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: Text(text),
    );
  }
}

class ConsolePage extends StatefulWidget {
  const ConsolePage({Key? key}) : super(key: key);

  @override
  State<ConsolePage> createState() => _ConsolePageState();
}

class _ConsolePageState extends State<ConsolePage> {
  String changeListenerName = "";
  bool isLaunching = false;
  bool isUpdating = false;
  bool firstBuild = true;

  ScrollController controller = ScrollController();

  void changeListener() {
    if (!mounted) return;

    // Update console text and set isLaunching
    setState(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.jumpTo(controller.position.maxScrollExtent);
      });

      if (IPC.websocketConnected) {
        isLaunching = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    changeListenerName = "consolePage-${DateTime.now().millisecondsSinceEpoch}";

    IPC.addChangeListener(changeListenerName, changeListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.jumpTo(controller.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    super.dispose();
    IPC.removeChangeListener(changeListenerName);
  }

  void onLaunchPress() async {
    // Check if Discord token has been set in config
    if (getIt<ConfigService>().config["Account"]["Discord"]["Token"] == "") {
      Utils.showErrorDialog(
        context,
        "You haven't set your Discord token yet! Please set it in the config tab before launching LightningBot.",
      );
      return;
    }

    setState(() => isLaunching = true);

    final error = await Launching.launch();

    // Check if the page is still mounted before showing the error dialog
    if (error.isNotEmpty && mounted) {
      Utils.showErrorDialog(context, error);

      setState(() => isLaunching = false);
    }
  }

  void onCheckForUpdatesPress() async {
    setState(() => isUpdating = true);

    final result = await Launching.ensureLatestSelfbotVersion(
      notifyOnSuccess: true,
    );

    if (result.isLatest && mounted) {
      Utils.showAlertDialog(
        context,
        "No updates found",
        "You're already on the latest version of LightningBot!",
      );
    }

    setState(() => isUpdating = false);
  }

  void onExitPress() {
    IPC.send({"op": OP.exit, "data": {}});
  }

  void onRestartPress() async {
    IPC.send({"op": OP.exit, "data": {}});

    final error = await Launching.launch(force: true);

    // Check if the page is still mounted before showing the error dialog
    if (error.isNotEmpty && mounted) {
      Utils.showErrorDialog(context, error);
    }
  }

  void onOpenFolderPress() => Paths.openFolder();

  List<Widget> _getConsoleButtons() {
    final connectedButtons = [
      ConsoleButton(
        onPressed: onExitPress,
        text: "Exit",
      ),
      const SizedBox(width: 5),
      ConsoleButton(
        onPressed: onRestartPress,
        text: "Restart",
      ),
      Expanded(child: Container()),
      ConsoleButton(
        onPressed: onOpenFolderPress,
        text: "Open folder",
      ),
    ];

    final disconnectedButtons = [
      ConsoleButton(
        onPressed: onLaunchPress,
        loading: isLaunching,
        text: "Launch",
      ),
      const SizedBox(width: 5),
      ConsoleButton(
        onPressed: onCheckForUpdatesPress,
        loading: isUpdating,
        text: "Check for updates",
      ),
      Expanded(child: Container()),
      ConsoleButton(
        onPressed: onOpenFolderPress,
        text: "Open folder",
      ),
    ];

    return IPC.websocketConnected ? connectedButtons : disconnectedButtons;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height - 65;
    final consoleHeight = height - 140;
    final consoleCached = Utils.isConsoleCached();

    if (!consoleCached || firstBuild) {
      // Scroll all the way down
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.jumpTo(controller.position.maxScrollExtent);
      });
      firstBuild = false;
    }

    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      height: height,
      child: ListView(
        children: [
          Container(
            height: consoleHeight,
            alignment: const Alignment(0, 0),
            padding: const EdgeInsets.all(5),
            child: Card(
              child: ListView(
                children: [
                  Container(
                    height: consoleHeight - 90,
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.only(
                        left: 20, right: 20, top: 20, bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0x33000000),
                    ),
                    child: SelectionArea(
                      child: ListView(
                        controller: controller,
                        children: [
                          const Center(
                            child: Image(
                              image: AssetImage("assets/Banner.png"),
                              width: 650,
                              height: 150,
                            ),
                          ),
                          Console(consoleText: IPC.consoleString),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 20),
                      ..._getConsoleButtons(),
                      const SizedBox(width: 20),
                    ],
                  )
                ],
              ),
            ),
          ),
          ResponsiveGridRow(
            children: [
              InfoCardCol(
                card: InfoCard(
                  title: 'Status',
                  subtitle:
                      IPC.websocketConnected ? 'Connected' : 'Disconnected',
                  icon: Icons.computer,
                ),
                cardAmount: 3,
              ),
              InfoCardCol(
                card: InfoCard(
                  title: 'Version',
                  subtitle: API.stats?.version ?? 'Unknown',
                  icon: Icons.device_hub,
                ),
                cardAmount: 3,
              ),
              InfoCardCol(
                card: InfoCard(
                  title: 'Login Time',
                  subtitle: Utils.parseSeconds(API.userData?.loginTime ?? 0),
                  icon: Icons.access_time,
                ),
                cardAmount: 3,
              ),
            ],
          )
        ],
      ),
    );
  }
}
