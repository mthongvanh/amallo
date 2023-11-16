import 'package:flutter/material.dart';

class ScreenService {
  ScreenType getFormFactor(BuildContext context) {
    // Use .shortestSide to detect device type regardless of orientation
    double deviceWidth = MediaQuery.of(context).size.shortestSide;
    if (deviceWidth > FormFactor.desktop) return ScreenType.desktop;
    if (deviceWidth > FormFactor.tablet) return ScreenType.tablet;
    if (deviceWidth > FormFactor.handset) return ScreenType.handset;
    return ScreenType.watch;
  }

  ScreenSize getSize(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.shortestSide;
    if (deviceWidth > 900) return ScreenSize.extraLarge;
    if (deviceWidth > 600) return ScreenSize.large;
    if (deviceWidth > 300) return ScreenSize.normal;
    return ScreenSize.small;
  }
}

enum ScreenType { desktop, tablet, handset, watch }

class FormFactor {
  static double desktop = 900;
  static double tablet = 600;
  static double handset = 350;
}

enum ScreenSize { small, normal, large, extraLarge }
