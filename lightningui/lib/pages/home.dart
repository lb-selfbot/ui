import 'package:flutter/material.dart';
import 'package:lightningui/api.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:lightningui/widgets/infocard.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: ResponsiveGridRow(
        children: [
          InfoCardCol(
            card: InfoCard(
              title: 'Auth',
              subtitle: API.stats?.auth ?? 'Unknown',
              icon: Icons.computer,
            ),
          ),
          InfoCardCol(
            card: InfoCard(
              title: 'Version',
              subtitle: API.stats?.version ?? 'Unknown',
              icon: Icons.device_hub,
            ),
          ),
          InfoCardCol(
            card: InfoCard(
              title: 'Global Logins',
              subtitle: API.stats?.logins.toString() ?? 'Unknown',
              icon: Icons.login,
            ),
          ),
          InfoCardCol(
            card: InfoCard(
              title: 'Username',
              subtitle: API.userData?.username ?? 'Unknown',
              icon: Icons.account_circle,
            ),
          ),
          InfoCardCol(
            card: InfoCard(
              title: 'Key',
              subtitle: API.userData?.key ?? 'Unknown',
              icon: Icons.key,
            ),
          ),
          InfoCardCol(
            card: InfoCard(
              title: 'Logins',
              subtitle: API.userData?.logins.toString() ?? 'Unknown',
              icon: Icons.login,
            ),
          ),
        ],
      ),
    );
  }
}
