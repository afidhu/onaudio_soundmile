import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Color bgDark = "#110C0C".toColor();
Color bg =const Color.fromARGB(255, 61, 37, 37); 
Color accentColor = "#490D0D".toColor();
Color textColor = Colors.white;
// ignore: non_constant_identifier_names
Color select_color = "#1FFF9D9D".toColor();
// ignore: non_constant_identifier_names
Color unselect_color = "#211E1E".toColor();
Color dividerColor = "#454545".toColor();
Color secondaryColor ='#A28B55'.toColor();
// Color hintColor = "#DFDFDF".toColor();
Color hintColor = Colors.grey.shade700;
Color lightBg = "#303030".toColor();
Color errorColor = "#FF6565".toColor();
Color searchHint = "#A5A4AA".toColor();
Color containerBg = "1E1E1E".toColor();

extension ColorExtension on String {
  toColor() {
    var hexColor = replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}

setStatusBarColor(Color color) {
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: color));
}

