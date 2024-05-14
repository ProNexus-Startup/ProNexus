import 'dart:async';

import 'package:admin/pages/admin_view.dart';
import 'package:admin/pages/home_page.dart';
import 'package:admin/utils/global_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/login_page.dart'; // Ensure this path is correct
import '../utils/persistence/secure_storage.dart';
import '../utils/persistence/screen_arguments.dart'; // Ensure this is the correct import

class SplashPage extends StatefulWidget {
  static const String routeName =
      '/splash'; // Add a route name if you're using named routes

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                "assets/images/logo.png"), // Make sure the path is correct
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  void startTimer() {
    Timer(Duration(seconds: 1),
        navigateUser); // Updated to 2 seconds for better UX
  }

  void navigateUser() async {
    // Initialize SecureStorage
    SecureStorage secureStorage = SecureStorage();
    // Attempt to read the token from secure storage
    String? token = await secureStorage.read('token');
    final GlobalBloc globalBloc =
        Provider.of<GlobalBloc>(context, listen: false);

    await globalBloc.onUserLogin(token!);

    if (token != 'No data found!' && token.isNotEmpty) {
      if (globalBloc.currentUser.admin) {
        Navigator.pushReplacementNamed(context, AdminPage.routeName,
            arguments: ScreenArguments(token));
      } else {
        Navigator.pushReplacementNamed(context, HomePage.routeName,
            arguments: ScreenArguments(token));
      }
    } else {
      Navigator.pushReplacementNamed(context, LoginPage.routeName);
    }
  }
}
