import 'package:admin/utils/controllers/MenuAppController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SideMenu extends StatelessWidget {
  final Function(AppPage) onSelectPage;

  const SideMenu({Key? key, required this.onSelectPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/logo.png"),
          ),
          DrawerListTile(
            title: "Available Experts",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () => onSelectPage(AppPage.availableExperts),
          ),
          DrawerListTile(
            title: "Call Tracker",
            svgSrc: "assets/icons/menu_notification.svg",
            press: () => onSelectPage(AppPage.callTracker),
          ),
          // Add more DrawerListTiles as needed for Profile, Settings, etc.
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        height: 16,
        colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
      ),
      title: Text(
        title,
      ),
    );
  }
}
