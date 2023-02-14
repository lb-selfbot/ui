import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightningui/config.dart';
import 'package:lightningui/main.dart';
import 'package:lightningui/systemtray.dart';

class WindowTitleBar extends StatelessWidget {
  const WindowTitleBar({
    Key? key,
    required this.dark,
    this.fullWidth = false,
  }) : super(key: key);

  final bool dark;
  final bool fullWidth;

  Widget buildTitleBar(BuildContext context, double width) {
    return Container(
      width: fullWidth ? width : width - 150,
      height: 32.0,
      color: Colors.transparent,
      child: MoveWindow(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: fullWidth
                      ? appWindow.titleBarButtonSize.width * 3
                      : appWindow.titleBarButtonSize.width * 1,
                ),
                child: Center(
                  child: Text(
                    "LightningBot",
                    style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            MinimizeWindowButton(
              onPressed: () {
                bool hideToSystemTray =
                    getIt<Config>().config["UI"]["HideToSystemTray"];

                if (hideToSystemTray) {
                  appWindow.hide();
                  SystemTray.show();
                } else {
                  appWindow.minimize();
                }
              },
              colors: WindowButtonColors(
                iconNormal: !dark ? Colors.black : Colors.white,
                iconMouseDown: !dark ? Colors.black : Colors.white,
                iconMouseOver: !dark ? Colors.black : Colors.white,
                normal: Colors.transparent,
                mouseOver: !dark
                    ? Colors.black.withOpacity(0.04)
                    : Colors.white.withOpacity(0.04),
                mouseDown: !dark
                    ? Colors.black.withOpacity(0.08)
                    : Colors.white.withOpacity(0.08),
              ),
            ),
            MaximizeWindowButton(
              colors: WindowButtonColors(
                iconNormal: !dark ? Colors.black : Colors.white,
                iconMouseDown: !dark ? Colors.black : Colors.white,
                iconMouseOver: !dark ? Colors.black : Colors.white,
                normal: Colors.transparent,
                mouseOver: !dark
                    ? Colors.black.withOpacity(0.04)
                    : Colors.white.withOpacity(0.04),
                mouseDown: !dark
                    ? Colors.black.withOpacity(0.08)
                    : Colors.white.withOpacity(0.08),
              ),
            ),
            CloseWindowButton(
              colors: WindowButtonColors(
                iconNormal: !dark ? Colors.black : Colors.white,
                iconMouseDown: !dark ? Colors.black : Colors.white,
                iconMouseOver: !dark ? Colors.black : Colors.white,
                normal: Colors.transparent,
                mouseOver: !dark
                    ? Colors.black.withOpacity(0.04)
                    : Colors.white.withOpacity(0.04),
                mouseDown: !dark
                    ? Colors.black.withOpacity(0.08)
                    : Colors.white.withOpacity(0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Platform.isWindows ? buildTitleBar(context, width) : Container();
  }
}
