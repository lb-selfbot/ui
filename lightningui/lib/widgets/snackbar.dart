import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SnackBarContent extends StatelessWidget {
  const SnackBarContent({
    Key? key,
    required this.title,
    required this.message,
    required this.color,
    required this.icon,
    required this.size,
  }) : super(key: key);

  final String title;
  final String message;
  final Color color;
  final IconData icon;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        height: 70,
        width: 400,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon),
            const Spacer(),
            Expanded(
              flex: 25,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      InkWell(
                        onTap: () =>
                            ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                        child: const Icon(Icons.close, size: 20),
                      )
                    ],
                  ),
                  const Spacer(),
                  Text(
                    message,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorSnackBar extends SnackBar {
  ErrorSnackBar({
    Key? key,
    required this.message,
    required this.theme,
    required this.size,
  }) : super(
          key: key,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: SnackBarContent(
            title: "Error",
            message: message,
            color: theme.errorColor,
            icon: Icons.error_outline_rounded,
            size: size,
          ),
        );

  final String message;
  final ThemeData theme;
  final Size size;
}

class WarningSnackBar extends SnackBar {
  WarningSnackBar({
    Key? key,
    required this.message,
    required this.theme,
    required this.size,
  }) : super(
          key: key,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: SnackBarContent(
            title: "Warning",
            message: message,
            color: const Color(0xFFc07b13),
            icon: Icons.error_outline_rounded,
            size: size,
          ),
        );

  final String message;
  final ThemeData theme;
  final Size size;
}

class SuccessSnackBar extends SnackBar {
  SuccessSnackBar({
    Key? key,
    required this.message,
    required this.theme,
    required this.size,
  }) : super(
          key: key,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: SnackBarContent(
            title: "Success",
            message: message,
            color: const Color(0xFF2D8539),
            icon: Icons.error_outline_rounded,
            size: size,
          ),
        );

  final String message;
  final ThemeData theme;
  final Size size;
}
