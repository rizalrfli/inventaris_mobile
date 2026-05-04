import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/chatbot/screens/chatbot_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/tracking/screens/tracking_screen.dart';
import '../../features/transactions/screens/add_transaction_screen.dart';
import '../../shared/widgets/app_layout.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tracking',
              builder: (context, state) => const TrackingScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chatbot',
              builder: (context, state) => const ChatbotScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/add-transaction',
      builder: (context, state) => const AddTransactionScreen(),
    ),
  ],
);
