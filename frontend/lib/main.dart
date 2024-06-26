import 'dart:convert';
import 'package:admin/pages/ai_match_page.dart';
import 'package:admin/pages/available_experts_page.dart';
import 'package:admin/pages/budget_inputs_page.dart';
import 'package:admin/pages/call_tracker_page.dart';
import 'package:admin/pages/expert_specific_page.dart';
import 'package:admin/pages/forgot_password_page.dart';
import 'package:admin/pages/home_page.dart';
import 'package:admin/pages/org_register_page.dart';
import 'package:admin/pages/admin_view.dart';
import 'package:admin/pages/project_creation_page.dart';
import 'package:admin/pages/project_dashboard_page.dart';
import 'package:admin/pages/reset_password_page.dart';
import 'package:admin/pages/user_register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'utils/models/user.dart';
import 'utils/persistence/global_bloc.dart';
import 'utils/BaseAPI.dart';
import 'utils/formatting/app_theme.dart';
import 'pages/login_page.dart';
import 'utils/persistence/screen_arguments.dart';
import 'pages/splash_page.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';

int id = 0;

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(
      MultiProvider(
        providers: [
          BlocProvider<UserCubit>(
            create: (context) => UserCubit(User.defaultUser()),
          ),
          ChangeNotifierProvider(
            create: (context) => GlobalBloc(),
          ),
          ChangeNotifierProvider(create: (_) => ExpensesProvider()),
          ChangeNotifierProvider<ProjectDetails>(
            create: (_) => ProjectDetails(),
          ),
        ],
        child: const ProNexus(),
      ),
    );
  }, (error, stack) {
    print('Caught Flutter error in my root zone: $error');
    print(stack);
  });
}

class ProNexus extends StatefulWidget {
  const ProNexus({super.key});

  @override
  _ProNexusState createState() => _ProNexusState();
}

class _ProNexusState extends State<ProNexus> {
  final Map<String, Widget Function(ScreenArguments)> routeBuilders = {
    AvailableExpertsDashboard.routeName: (args) =>
        AvailableExpertsDashboard(token: args.token),
    CallTrackerDashboard.routeName: (args) =>
        CallTrackerDashboard(token: args.token),
    UserRegisterPage.routeName: (args) => UserRegisterPage(token: args.token),
    ProjectDashboard.routeName: (args) => ProjectDashboard(token: args.token),
    BudgetInputsPage.routeName: (args) => BudgetInputsPage(token: args.token),
    AiMatchPage.routeName: (args) => AiMatchPage(token: args.token),
    ProjectCreationPage.routeName: (args) =>
        ProjectCreationPage(token: args.token),
    ExpertSpecificPage.routeName: (args) =>
        ExpertSpecificPage(token: args.token),
  };

  Key key = UniqueKey();

  void resetGlobalBloc() {
    setState(() {
      key = UniqueKey(); // Changing the key rebuilds the widget
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //key: key,
      title: 'ProNexus',
      routes: {
        '/login': (context) => const LoginPage(),
        '/': (context) => SplashPage(),
        '/org-registration': (context) => OrgRegisterPage(),
        '/splash': (context) => SplashPage(),
        ForgotPasswordPage.routeName: (context) => ForgotPasswordPage(),
        HomePage.routeName: (args) => HomePage(),
        AdminPage.routeName: (args) => AdminPage(),
        '/reset-password': (context) {
          final uri = Uri.base;
          final email = uri.queryParameters['email'] ?? '';
          return email.isNotEmpty
              ? ResetPasswordPage(email: email)
              : Scaffold(
                  appBar: AppBar(
                    title: Text('Password Reset'),
                  ),
                  body: Center(
                    child: Text('Invalid or missing email.'),
                  ),
                );
        },
        // Add other routes here as needed
      },
      onGenerateRoute: (settings) {
        if (routeBuilders.containsKey(settings.name)) {
          final args = settings.arguments as ScreenArguments;
          return MaterialPageRoute(
            builder: (context) => routeBuilders[settings.name]!(args),
          );
        }
        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
      theme: wgerLightTheme,
    );
  }
}
