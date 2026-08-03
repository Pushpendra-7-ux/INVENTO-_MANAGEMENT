import 'package:flutter/material.dart';

class NavigationService {
  NavigationService._();
  static final instance = NavigationService._();

  final navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> pushNamed(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushReplacementNamed(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushAndClearStack(String routeName) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(routeName, (_) => false);
  }

  void pop([dynamic result]) => navigatorKey.currentState!.pop(result);
  bool canPop() => navigatorKey.currentState!.canPop();
}
