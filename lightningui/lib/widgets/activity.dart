import 'package:flutter/material.dart';
import 'package:lightningui/services/config_service.dart';
import 'package:lightningui/main.dart';
import 'package:lightningui/widgets/activity_image.dart';

class Activity extends StatefulWidget {
  const Activity({Key? key}) : super(key: key);

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  String getTitle() {
    final config = getIt<ConfigService>().config;

    if (config["Activity"]["ActivityType"] == "RPC") {
      return "RPC Application";
    }

    if (config["Activity"]["Type"] == "Playing") {
      return config["Activity"]["Name"];
    } else {
      return config["Activity"]["Details"];
    }

    // else {
    //   return config["Activity"]["Name"];
    // }
  }

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

  List<Widget> getActivityText(dynamic activity) {
    List<Widget> widgets = [];

    if (activity["ActivityType"] == "RPC" || activity["Type"] == "Playing") {
      if (activity["Details"] != "") {
        widgets.add(Text(activity["Details"]));
      }

      if (activity["State"] != "") {
        widgets.add(Text(activity["State"]));
      }

      return widgets;
    }

    if (activity["State"] != "") {
      widgets.add(Text(activity["State"]));
    }

    if (activity["LargeImageText"] != "") {
      widgets.add(Text(activity["LargeImageText"]));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final config = getIt<ConfigService>().config;

    final activity = config["Activity"];

    final time = activity["ActivityType"] == "RPC" && activity["Time"];

    return Row(
      children: [
        Tooltip(
          preferBelow: false,
          message: activity["LargeImageText"],
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ActivityImage(
              activityType: activity["ActivityType"],
              clientId: activity["ClientID"],
              image: activity["LargeImage"],
            ),
          ),
        ),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getTitle(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ...getActivityText(activity),
            // if (config["Activity"]["Details"] != "")
            //   Text(config["Activity"]["Details"]),
            // if (config["Activity"]["State"] != "")
            //   Text(config["Activity"]["State"]),
            time ? const Text("00:00 elapsed") : Container(),
          ],
        ),
      ],
    );
  }
}
