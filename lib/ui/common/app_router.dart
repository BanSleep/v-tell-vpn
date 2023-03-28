import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:wireguard_flutter/ui/feel_safe_screen.dart';
import 'package:wireguard_flutter/ui/home_screen/home_screen.dart';
import 'package:wireguard_flutter/ui/onboarding_page_screen.dart';
import 'package:wireguard_flutter/ui/tunnel_details.dart';

part 'app_router.gr.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route,Screen,Provider',
  routes: <AutoRoute>[
    CupertinoRoute(page: OnBoardingPageScreen, initial: true),
    CupertinoRoute(page: FeelSafeScreen),
    CupertinoRoute(page: HomeScreen),
    CupertinoRoute(page: TunnelDetails),
  ],
)
// extend the generated private router
class AppRouter extends _$AppRouter{}