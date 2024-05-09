import 'package:admin/pages/admin_view.dart';
import 'package:admin/pages/home_page.dart';
import 'package:admin/pages/login_page.dart';
import 'package:admin/utils/global_bloc.dart';
import 'package:admin/utils/persistence/screen_arguments.dart';
import 'package:admin/utils/persistence/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopMenu extends StatelessWidget {
  TopMenu({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    // Ensure token is read at the appropriate time within method scope
    await SecureStorage().delete('token');

    if (!context.mounted) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", false);

    if (!context.mounted) return;

    // Accessing GlobalBloc instance
    Provider.of<GlobalBloc>(context, listen: false).onUserLogout();

    // Navigate to login page after logout
    Navigator.pushReplacementNamed(context, LoginPage.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue[800],
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Align items to start
        children: <Widget>[
          TextButton(
            onPressed: () async {
              final token = await SecureStorage().read('token');
              Navigator.pushNamed(
                context,
                HomePage.routeName,
                arguments: ScreenArguments(token),
              );
            },
            child: const Text('Home', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              // Retrieve token when needed and navigate
              final token = await SecureStorage().read('token');
              Navigator.pushNamed(
                context,
                AdminPage.routeName,
                arguments: ScreenArguments(token),
              );
            },
            child:
                const Text('Admin view', style: TextStyle(color: Colors.white)),
          ),
          const Spacer(), // Pushes following items to the right
          const Text('Chat with live support',
              style: TextStyle(color: Colors.white)),
          IconButton(
              icon: const Icon(Icons.chat, color: Colors.white),
              onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            color: Colors.white,
            onPressed: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
