import 'package:flutter/material.dart';

class CountingNavigatorObserver extends NavigatorObserver {
  int pushCount = 0;
  int pagePushCount = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushCount += 1;
    if (route is PageRoute<dynamic>) pagePushCount += 1;
    super.didPush(route, previousRoute);
  }
}
