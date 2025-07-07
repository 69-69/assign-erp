import 'package:flutter/material.dart';

class RouteObserver extends NavigatorObserver {
  String? _currentRoute;

  String? get currentRoute => _currentRoute;

  @override
  void didPush(Route route, Route? previousRoute) {
    _currentRoute = route.settings.name;
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _currentRoute = previousRoute?.settings.name;
    super.didPop(route, previousRoute);
  }

/*USAGE:
  final RouteObserver routeObserver = RouteObserver();
  * bool isOnOnboardingScreen() {
    return routeObserver.currentRoute == RouteNames.onboarding;
  }*/
}

extension CurrentRoute on BuildContext {
  // Access the current route’s name and compare it with the expected route
  bool isRouteSame(String expectedRoute) {
    final ModalRoute? route = ModalRoute.of(this);
    // debugPrint('steve ${route?.settings.name}===${route?.settings.name == expectedRoute}');
    return route?.settings.name == expectedRoute;
  }
}
