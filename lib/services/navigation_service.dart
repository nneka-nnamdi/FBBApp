import 'package:flutter/material.dart';

class ScreenArguments {
  final String email;
  final String oobCode;

  ScreenArguments(this.email, this.oobCode);
}

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName) {
    return navigatorKey.currentState!.pushNamed(routeName);
  }

  Future<dynamic> navigateReplacementTo(String routeName) {
    return navigatorKey.currentState!.pushReplacementNamed(routeName);
  }

  Future<dynamic> navigateWith(String routeName, ScreenArguments arguments) {
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }
  Future<dynamic> navigateToDetail(String routeName, int propertyId) {
    return navigatorKey.currentState!.pushNamed(routeName,arguments: propertyId);
  }
}
