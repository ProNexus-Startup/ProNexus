import 'package:admin/pages/available_experts_dashboard.dart';
import 'package:admin/pages/call_tracker_page.dart';
import 'package:admin/pages/login_page.dart';
import 'package:admin/responsive.dart';
import 'package:admin/utils/global_bloc.dart';
import 'package:admin/utils/persistence/secure_storage.dart';
//import 'package:admin/utils/persistence/user_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'side_menu.dart';
import 'package:admin/utils/controllers/MenuAppController.dart';

class HomePage extends StatefulWidget {
  final String token;
  static const routeName = '/wrapper';

  const HomePage({Key? key, required this.token}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AppPage _currentPage = AppPage.availableExperts; // Default page

  void _navigateTo(AppPage page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final GlobalBloc globalBloc =
        Provider.of<GlobalBloc>(context, listen: false);
    globalBloc.onUserLogin(widget.token);
  }

  Future<void> _logout(BuildContext context) async {
    //AuthAPI _authAPI = AuthAPI();
    //var req = await _authAPI.logout(widget.token);
    //print(req.statusCode);
    //if (req.statusCode == 200) {
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
    //} else {
    //print("failed to log out");
    //}
  }

  @override
  Widget build(BuildContext context) {
    // Accessing currentUser from GlobalBloc
    final menuAppController =
        Provider.of<MenuAppController>(context, listen: false);

    // Dynamically set the content based on the current page
    Widget content;
    switch (_currentPage) {
      case AppPage.availableExperts:
        content = AvailableExpertsDashboard(token: widget.token);
        break;
      case AppPage.callTracker:
        content = CallTrackerDashboard(token: widget.token);
        break;
    }

    // Adjusted layout for responsiveness
    return Scaffold(
      key: menuAppController.scaffoldKey,
      drawer: Responsive.isDesktop(context)
          ? null
          : SideMenu(
              onSelectPage: (page) {
                _navigateTo(page);
              },
            ),
      body: SafeArea(
        child: Responsive.isDesktop(context)
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    // For desktop layout, include both side menu and content
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2, // Adjust flex ratio based on your UI needs
                          child: SideMenu(
                            onSelectPage: (page) {
                              _navigateTo(page);
                            },
                          ),
                        ),
                        Expanded(
                          flex: 8,
                          child: content,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : content, // For non-desktop layouts, just show the content
      ),
      appBar: AppBar(
        automaticallyImplyLeading: !Responsive.isDesktop(
            context), // Show menu button on smaller screens
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
