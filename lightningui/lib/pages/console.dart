import 'package:flutter/material.dart';
import 'package:lightningui/api.dart';
import 'package:lightningui/config.dart';
import 'package:lightningui/ipc.dart';
import 'package:lightningui/utils.dart';
import 'package:lightningui/launching.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:lightningui/widgets/infocard.dart';

class ConsoleButton extends StatelessWidget {
  const ConsoleButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          Theme.of(context).primaryColorDark,
        ),
      ),
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
  bool firstBuild = true;

  void changeListener() {
    if (mounted) {
      // Update Console
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    changeListenerName = "consolePage-${DateTime.now().millisecondsSinceEpoch}";

    IPC.addChangeListener(changeListenerName, changeListener);
  }

  @override
  void dispose() {
    super.dispose();
    IPC.removeChangeListener(changeListenerName);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height - 65;
    final consoleHeight = height - 140;
    final controller = ScrollController();
    final consoleCached = Utils.isConsoleCached();
    final console = Utils.renderConsole();

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
                        children: console,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 20),
                      ..._getConsoleButtons(),
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
                  subtitle: API.userData?.loginTime.toString() ?? 'Unknown',
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

  List<Widget> _getConsoleButtons() {
    if (IPC.websocketConnected) {
      return [
        ConsoleButton(
          onPressed: () => IPC.send({"op": OP.exit, "data": {}}),
          text: "Exit",
        ),
        const SizedBox(width: 5),
        ConsoleButton(
          onPressed: () {
            IPC.send({"op": OP.exit, "data": {}});
            Launching.launch(force: true);
          },
          text: "Restart",
        ),
      ];
    } else {
      return [
        ConsoleButton(
          onPressed: () {
            // Check if Discord token has been set in config
            final token = Config.config["Account"]["Discord"]["Token"];
            if (token == "") {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Error"),
                  content: const Text(
                      "You haven't set your Discord token yet! Please set it in the config tab before launching LightningBot."),
                  actions: [
                    TextButton(
                      child: const Text('Close'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            } else {
              Launching.launch();
            }
          },
          text: "Launch",
        ),
      ];
    }
  }
}
