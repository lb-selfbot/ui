import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';

import '../widgets/infocard.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: ResponsiveGridRow(
        children: [
          InfoCardCol(
            card: const InfoCard(
              title: 'Auth',
              subtitle: 'Online',
              icon: Icons.computer,
            ),
          ),
          InfoCardCol(
            card: const InfoCard(
              title: 'Version',
              subtitle: '4.0.0',
              icon: Icons.device_hub,
            ),
          ),
          InfoCardCol(
            card: const InfoCard(
              title: 'Global Logins',
              subtitle: '6493',
              icon: Icons.login,
            ),
          ),
          InfoCardCol(
            card: const InfoCard(
              title: 'Username',
              subtitle: 'Lightning',
              icon: Icons.account_circle,
            ),
          ),
          InfoCardCol(
            card: const InfoCard(
              title: 'Key',
              subtitle: 'LB-u52x-IRhb-qK3M',
              icon: Icons.key,
            ),
          ),
          InfoCardCol(
            card: const InfoCard(
              title: 'Logins',
              subtitle: '1195',
              icon: Icons.login,
            ),
          ),
        ],
      ),
    );
  }
}
