import 'package:admin/pages/login_page.dart';
import 'package:admin/responsive.dart';
import 'package:admin/pages/components/dashboard_screen.dart';
import 'package:admin/utils/global_bloc.dart';
import 'package:admin/utils/persistence/secure_storage.dart';
import 'package:admin/utils/persistence/user_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/side_menu.dart';

class HomePage extends StatefulWidget {
  final String token;
  static const routeName = '/home';

  const HomePage({Key? key, required this.token}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Assuming you have a method to retrieve the stored token
    //String token =
    //    await getToken(); // Implement getToken to get the token from storage
    //if (token != null) {
    //  await onUserLogin(token);
  }

  Future<void> _logout(BuildContext context) async {
    AuthAPI _authAPI = AuthAPI();
    var req = await _authAPI.logout(widget.token);
    print(req.statusCode);
    if (req.statusCode == 200) {
      await SecureStorage().delete('token');
      if (!context.mounted) {
        return;
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("isLoggedIn", false);
      if (!context.mounted) {
        return;
      }
      // Accessing  instance
      Provider.of<GlobalBloc>(context, listen: false).onUserLogout();

      Navigator.pushNamed(
        context,
        LoginPage.routeName,
      );
    } else {
      print("failed to log out");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Accessing currentUser from GlobalBloc

    // Checking if the user is not null to build the UI
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              Expanded(
                child: SideMenu(), // Optionally pass user data to SideMenu
              ),
            Expanded(
              flex: 5,
              child: DashboardScreen(
                  token: widget
                      .token), // Optionally pass user data to DashboardScreen
            ),
          ],
        ),
      ),
    );
  }
}
