import 'package:flutter/material.dart';

// All of our constant stuff

const kTransparentColor = Colors.transparent;
const kPrimaryColor = Color(0xff232b5a); // 0xFF673AB7
const kPrimaryLightColor = Color(0xff4a5d8c);
const kPrimaryAccentColor = Color(0xff3468ea);
const kLightColor = Color(0xFFFFFFFF);
const kGrayColor = Color(0xFFB1B3B8);
const kTextColor = Color(0xFF757575);
const kBgLightColor = Color(0xFD393636);
const kGrayBlueColor = Color(0xFF8793B2);
const kLightBlueColor = Color(0xFFC5D3F8);
const kWarningColor = Color(0xFFFFA726);
const kOrangeColor = Color(0xFFE65100);
const kGoldColor = Color(0xFFAA7706);
const kSuccessColor = Color(0xFF44CA03);
const kDangerColor = Color(0xFFEE3737);
const kDarkTextColor = Colors.black;
const kDefaultPadding = 20.0;
// const kTitleTextColor = Color(0xFF30384D);

extension DefaultColors on BuildContext {
  ThemeData get ofTheme => Theme.of(this);
  ColorScheme get colorScheme => ofTheme.colorScheme;
  Color get primaryColor => ofTheme.primaryColor;
}

// list of user manual colors
final List<Color> userManualBgColrs = [
  Color(0xFFE57373),
  Color(0xFFF06292),
  Color(0xFFBA68C8),
  Color(0xFF9575CD),
  Color(0xFF7986CB),
  Color(0xFF64B5F6),
  Color(0xFF4FC3F7),
  Color(0xFF4DD0E1),
  Color(0xFF4DB6AC),
  Color(0xFF81C784),
];
