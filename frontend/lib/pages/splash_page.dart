import 'dart:async';

import 'package:admin/pages/home_page.dart';
import 'package:admin/utils/persistence/global_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/login_page.dart';
import '../utils/persistence/secure_storage.dart';
import '../utils/persistence/screen_arguments.dart';

class SplashPage extends StatefulWidget {
  static const String routeName = '/splash';
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
            image: AssetImage("images/logo.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  void startTimer() {
    Timer(Duration(seconds: 1), navigateUser);
  }

  void navigateUser() async {
    SecureStorage secureStorage = SecureStorage();
    String? token = await secureStorage.read('token');
    final GlobalBloc globalBloc =
        Provider.of<GlobalBloc>(context, listen: false);

    await globalBloc.onUserLogin();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String last_route = prefs.getString('last_route') ?? HomePage.routeName;

    if (token != 'No data found!' && token!.isNotEmpty) {
      if (globalBloc.currentUser.admin) {
        Navigator.pushReplacementNamed(context, last_route,
            arguments: ScreenArguments(token));
      } else {
        Navigator.pushReplacementNamed(context, last_route,
            arguments: ScreenArguments(token));
      }
    } else {
      Navigator.pushReplacementNamed(context, LoginPage.routeName);
    }
  }
}
