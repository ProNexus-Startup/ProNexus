import 'package:admin/pages/available_experts_dashboard.dart';
import 'package:admin/pages/call_tracker_page.dart';
import 'package:admin/utils/persistence/screen_arguments.dart';
import 'package:admin/utils/persistence/secure_storage.dart';
import 'package:flutter/material.dart';

class SubMenu extends StatelessWidget {
  final Function(String) onItemSelected;
  final String projectName;

  const SubMenu(
      {Key? key, required this.onItemSelected, required this.projectName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white60, // Adjust the background color to match your navbar
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _menuItem(projectName, () {}),
          _menuItem("Draft angle outreach",
              () => onItemSelected("Draft angle outreach")),
          _menuItem(
              "Project dashboard", () => onItemSelected("Project dashboard")),
          _menuItem("Available experts", () async {
            final token = await SecureStorage().read('token');
            Navigator.pushNamed(
              context,
              AvailableExpertsDashboard.routeName,
              arguments: ScreenArguments(token),
            );
          }),
          _menuItem("Call tracker", () async {
            final token = await SecureStorage().read('token');
            Navigator.pushNamed(
              context,
              CallTrackerDashboard.routeName,
              arguments: ScreenArguments(token),
            );
          }),
          _menuItem("Project info", () => onItemSelected("Project info")),
        ],
      ),
    );
  }

  Widget _menuItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(title,
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
