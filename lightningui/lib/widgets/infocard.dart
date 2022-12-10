import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        color: Colors.transparent,
        alignment: Alignment.center,
        child: ListTile(
          tileColor: Colors.transparent,
          leading: Icon(icon),
          title: Text(title, style: const TextStyle(fontSize: 16)),
          subtitle: Text(subtitle),
        ),
      ),
    );
  }
}

class InfoCardCol extends ResponsiveGridCol {
  InfoCardCol({
    Key? key,
    int cardAmount = 6,
    required this.card,
  }) : super(
          key: key,
          xs: _getXs(cardAmount),
          md: _getMd(cardAmount),
          lg: _getLg(cardAmount),
          child: Container(
            height: 100,
            alignment: const Alignment(0, 0),
            padding: const EdgeInsets.all(5),
            child: card,
          ),
        );

  final Widget card;

  static int _getXs(int cardAmount) {
    if (cardAmount > 1) {
      return 6;
    }
    return 12;
  }

  static int _getMd(int cardAmount) {
    if (cardAmount > 2) {
      return 4;
    }
    return 6;
  }

  static int _getLg(int cardAmount) {
    if (cardAmount > 3) {
      return 3;
    }
    return 4;
  }
}
