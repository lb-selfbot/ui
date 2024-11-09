import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightningui/services/config_service.dart';
import 'package:lightningui/main.dart';
import 'package:lightningui/services/system_tray_service.dart';

class WindowTitleBar extends StatelessWidget {
  const WindowTitleBar({
    super.key,
    this.fullWidth = false,
  });

  final bool fullWidth;

  void minimize() {
    bool hideToSystemTray =
        getIt<ConfigService>().config["UI"]["HideToSystemTray"];

    if (hideToSystemTray) {
      getIt<SystemTrayService>().show();
      appWindow.hide();
    } else {
      appWindow.minimize();
    }
  }

  Widget buildTitleBar(BuildContext context, double width) {
    final theme = Theme.of(context);

    final dark = theme.brightness == Brightness.dark;

    final weight = dark ? FontWeight.w200 : FontWeight.w500;

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
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: weight,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            MinimizeWindowButton(
              onPressed: minimize,
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
