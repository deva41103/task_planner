import 'package:get/get.dart';
import '../views/login_view.dart';
import '../views/dashboard_view.dart';
import '../views/activity_logs_view.dart';

class AppRoutes {
  static const LOGIN = '/login';
  static const DASHBOARD = '/dashboard';
  static const ACTIVITY_LOGS = '/activity-logs';

  static final routes = [
    GetPage(name: LOGIN, page: () => const LoginView()),
    GetPage(name: DASHBOARD, page: () => const DashboardView()),
    GetPage(name: ACTIVITY_LOGS, page: () => const ActivityLogsView()),
  ];
}
