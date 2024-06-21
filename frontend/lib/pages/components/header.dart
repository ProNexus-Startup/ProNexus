import 'package:admin/pages/admin_view.dart';
import 'package:admin/pages/home_page.dart';
import 'package:admin/pages/login_page.dart';
import 'package:admin/pages/project_creation_page.dart';
import 'package:admin/utils/formatting/app_theme.dart';
import 'package:admin/utils/persistence/global_bloc.dart';
import 'package:admin/utils/persistence/screen_arguments.dart';
import 'package:admin/utils/persistence/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _saveContext(String route) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('last_route', route);
  }

  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc =
        Provider.of<GlobalBloc>(context, listen: false);

    return Container(
      height: 80,
      color: primaryBlue,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Row(
              children: [
                /*Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Image.asset('assets/images/logo.png', height: 40),
                ),*/
                TextButton(
                  onPressed: () async {
                    final token = await SecureStorage().read('token');
                    Navigator.pushNamed(
                      context,
                      HomePage.routeName,
                      arguments: ScreenArguments(token!),
                    );
                    _saveContext(HomePage.routeName);
                  },
                  child: const Text('Home', style: customStyle),
                ),
                TextButton(
                  onPressed: () async {
                    final token = await SecureStorage().read('token');
                    Navigator.pushNamed(
                      context,
                      ProjectCreationPage.routeName,
                      arguments: ScreenArguments(token!),
                    );
                    _saveContext(ProjectCreationPage.routeName);
                  },
                  child: const Text('Start new project', style: customStyle),
                ),
                if (globalBloc.currentUser.admin)
                  TextButton(
                    onPressed: () async {
                      final token = await SecureStorage().read('token');
                      Navigator.pushNamed(
                        context,
                        AdminPage.routeName,
                        arguments: ScreenArguments(token!),
                      );
                      _saveContext(AdminPage.routeName);
                    },
                    child: const Text('Admin view', style: customStyle),
                  ),
              ],
            ),
          ),
          TextButton.icon(
              onPressed: () {
                showContactInfoPopup(context);
              },
              label: const Text('Message us', style: customStyle),
              icon: Image.asset('assets/icons/chat_icon.png',
                  height: 24, width: 24)),
          TextButton.icon(
              onPressed: () {
                _logout(context);
              },
              label: const Text('Log out', style: customStyle),
              icon: const Icon(Icons.exit_to_app, color: Colors.white)),
        ],
      ),
    );
  }

  void showContactInfoPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Contact Information',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ContactInfo(
                  name: 'Tom, CEO',
                  phone: '111-111-1111',
                  message: 'Message if you have general product questions',
                  email: 'tommyers330@gmail.com',
                ),
                SizedBox(height: 16.0),
                ContactInfo(
                  name: 'Roberto, CTO',
                  phone: '305-934-3305',
                  message: 'Message if you are having technical issues',
                  email: 'rpupo63@gmail.com',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static const TextStyle customStyle = const TextStyle(
      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500);
}

class ContactInfo extends StatelessWidget {
  final String name;
  final String phone;
  final String message;
  final String email;

  ContactInfo({
    required this.name,
    required this.phone,
    required this.message,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 4.0),
        Row(
          children: <Widget>[
            SelectableText(
              phone,
              style: TextStyle(fontSize: 16),
            ),
            Text(
              ' | ',
              style: TextStyle(fontSize: 16),
            ),
            GestureDetector(
              onTap: () {
                launchUrl(Uri(
                  scheme: 'mailto',
                  path: email,
                ));
              },
              child: Text(
                email,
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.0),
        Text(
          message,
          style: TextStyle(fontSize: 16),
        ),
        Divider(thickness: 1, height: 32),
      ],
    );
  }
}
