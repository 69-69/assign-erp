import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

/*import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
PackageInfo packageInfo = await PackageInfo.fromPlatform();*/

extension SizeConfig on BuildContext {
  MediaQueryData get mediaQueryData => MediaQuery.of(this);

  double get bottomInsetPadding => mediaQueryData.viewInsets.bottom;

  /// Get Device OS: Operating-System type [deviceOSType]
  ({
    bool android,
    bool ios,
    bool isWin,
    bool isMac,
    bool isLinux,
    bool isFuchsia,
  })
  get deviceOSType => (
    android: Platform.isAndroid,
    ios: Platform.isIOS,
    isWin: Platform.isWindows,
    isMac: Platform.isMacOS,
    isLinux: Platform.isLinux,
    isFuchsia: Platform.isFuchsia,
  );

  /// Get screen size [mediaSize]
  Size get mediaSize => mediaQueryData.size;

  /// Check for darkMode Appearance [isDarkMode]
  bool get isDarkMode => mediaQueryData.platformBrightness == Brightness.dark;

  /// Get screen width [screenWidth]
  double get screenWidth => mediaSize.width;

  /// Get screen height [screenHeight]
  double get screenHeight => mediaSize.height;

  /// Large screens >=1100 (desktop, TV) [isDesktop]
  bool get isDesktop => screenWidth >= 1100;

  /// Large screens >=650 <1100 (tablet on landscape mode, mini laptop) [isTablet]
  bool get isTablet => screenWidth >= 650 && screenWidth < 1100;

  /// Get screen mobile-width [isMobile]
  bool get isMobile => screenWidth <= 650;

  /// Get screen min-mobile-width [isMiniMobile]
  bool get isMiniMobile => screenWidth <= 330;

  /// Is a large screen or tablet [isLargeScreen]
  bool get isLargeScreen => screenWidth >= 650;

  /// Responsive Text-Size: Change size based on ScreenSize [textScaleFactor]
  double get textScaleFactor => max(1, min((screenWidth / 1400) * 2.0, 2.0));

  /// Get Screen/Device Orientation either in Landscape or portrait mode [orientation]
  Orientation get orientation => mediaQueryData.orientation;

  /// Screen/Device Orientation is in Landscape mode [isLandscapeMode]
  bool get isLandscapeMode =>
      mediaQueryData.orientation == Orientation.landscape;

  /// Screen/Device Orientation is in portrait mode [isPortraitMode]
  bool get isPortraitMode => mediaQueryData.orientation == Orientation.portrait;

  /// Get magnitudes of the Screen/Device width and the height [mediaLongSize]
  double get mediaLongSize => mediaSize.longestSide;

  /// Get magnitudes of the Screen/Device width and the height [mediaShortSize]
  double get mediaShortSize => mediaSize.shortestSide;

  /// Check if its the Longest Screen/Device width [isMediaLongSize]
  bool get isMediaLongSize => orientation == Orientation.landscape;

  /// Check if its the Shortest Screen/Device width [isMediaShortSize]
  bool get isMediaShortSize => orientation == Orientation.portrait;
}
