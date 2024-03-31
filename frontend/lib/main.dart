//import 'dart:convert';
import 'package:admin/pages/components/dashboard_screen.dart';
import 'package:admin/pages/org_register_page.dart';
import 'package:admin/pages/user_register_page.dart';
import 'package:admin/utils/controllers/MenuAppController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'utils/global_bloc.dart';
import 'utils/persistence/user_data.dart';
import 'utils/formatting/app_theme.dart';
//import 'utils/login_stuff/secure_storage.dart';
import 'pages/login_page.dart';
//import 'pages/password_reset_request_page.dart';
import 'utils/persistence/screen_arguments.dart';
import 'pages/splash_page.dart';
import 'dart:async';
import 'pages/home_page.dart';

int id = 0;

Future<void> main() async {
  runApp(
    MultiProvider(
      providers: [
        BlocProvider<UserCubit>(
          create: (context) => UserCubit(User.defaultUser()),
        ),
        ChangeNotifierProvider(
          create: (context) => MenuAppController(),
        ),
        ChangeNotifierProvider(
          create: (context) => GlobalBloc(),
        ),

        // Add other providers if necessary
      ],
      child: const ProNexus(),
    ),
  );
}

class ProNexus extends StatefulWidget {
  const ProNexus({super.key});

  @override
  _ProNexusState createState() => _ProNexusState();
}

class _ProNexusState extends State<ProNexus> {
  final Map<String, Widget Function(ScreenArguments)> routeBuilders = {
    HomePage.routeName: (args) => HomePage(token: args.token),
    DashboardScreen.routeName: (args) => DashboardScreen(token: args.token),
    UserRegisterPage.routeName: (args) => UserRegisterPage(org: args.token)
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
        '/splash': (context) => SplashPage()
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
      theme: wgerDarkTheme,
    );
  }
}


/*
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Admin Panel',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white),
        canvasColor: secondaryColor,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => MenuAppController(),
          ),
        ],
        child: MainScreen(),
      ),
    );
  }
}
*/