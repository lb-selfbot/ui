import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightningui/main.dart';
import 'package:window_manager/window_manager.dart';

class LeftNavImage extends StatelessWidget {
  const LeftNavImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Center(
        heightFactor: 1,
        child: Image.asset(
          'assets/Logo.150.png',
          height: 60,
          width: 60,
        ),
      ),
    );
  }
}

class LeftNavContainer extends StatelessWidget {
  const LeftNavContainer({Key? key, this.child}) : super(key: key);

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      width: 150,
      height: MediaQuery.of(context).size.height - 2,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: child,
    );
  }
}

class LeftNavButtons extends ConsumerWidget {
  const LeftNavButtons({Key? key, this.child, required this.navigatorKey})
      : super(key: key);

  final Widget? child;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = ref.watch(currentRouteProvider);
    return Column(
      children: [
        for (final view in views)
          TextButton(
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(const Size(0, 60)),
              foregroundColor: MaterialStateProperty.all(
                _getNavButtonColor(currentRoute == view['route'] as String),
              ),
            ),
            onPressed: () {
              // Only push route if it isnt the current route
              String route = view['route'] as String;
              if (route != currentRoute) {
                ref.read(currentRouteProvider.notifier).state = route;
                navigatorKey.currentState
                    ?.popAndPushNamed(view['route'] as String);
              }
            },
            child: Row(
              children: [
                const SizedBox(width: 8),
                Icon(view['icon'] as IconData),
                const SizedBox(width: 10),
                Text(
                  view['title'] as String,
                  style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _getNavButtonColor(
                          currentRoute == view['route'] as String),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _getNavButtonColor(bool isCurrentRoute) {
    return isCurrentRoute ? const Color(0xFF47A7FF) : const Color(0xFFEEEEEE);
  }
}

class LeftNav extends StatelessWidget {
  const LeftNav({Key? key, required this.navigatorKey}) : super(key: key);

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return LeftNavContainer(
      child: Stack(
        children: [
          const LeftNavImage(),
          GestureDetector(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              width: 150,
              height: 35,
            ),
            onPanStart: (details) {
              if (Platform.isWindows) {
                appWindow.startDragging();
              } else {
                windowManager.startDragging();
              }
            },
          ),
          Column(
            children: [
              const SizedBox(height: 80),
              LeftNavButtons(navigatorKey: navigatorKey),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      "v4.0.0",
                      style: GoogleFonts.montserrat(
                        textStyle: const TextStyle(
                          color: Color(0xFFEEEEEE),
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
