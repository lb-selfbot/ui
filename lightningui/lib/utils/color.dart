import 'package:flutter/material.dart';

extension ColorExtension on Color {
  Color fromString(String color) {
    color = color.replaceAll('#', '');

    if (color.length == 6) {
      color = 'FF$color';
    } else if (color.length == 8) {
      // do nothing
    } else {
      return this;
    }

    final colorInt = int.tryParse(color, radix: 16);

    if (colorInt == null) {
      return this;
    }

    return Color(colorInt);
  }

  String toHex() {
    return '#${value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}
