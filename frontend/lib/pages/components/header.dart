import 'package:admin/responsive.dart';
import 'package:admin/utils/cards/user_card.dart';
import 'package:admin/utils/global_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../utils/constants.dart';

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Your existing Row widget...
    return Row(
      children: [
        // This condition checks if it's mobile or not desktop and then shows the menu icon
        if (Responsive.isMobile(context) || !Responsive.isDesktop(context))
          IconButton(
            icon: Icon(Icons.menu), // The three-bar hamburger icon
            onPressed: () {
              // Command to open the drawer
              Scaffold.of(context).openDrawer();
            },
          ),
        Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        ProfileCard(),
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<GlobalBloc>(context).currentUser;

    return Container(
      child: Row(
        children: [
          Image.asset(
            "assets/images/profile_pic.png",
            height: 38,
          ),
          if (!Responsive.isMobile(context))
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              child: Text(user.fullName),
            ),
          Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search",
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: InkWell(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.all(defaultPadding * 0.75),
            margin: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: SvgPicture.asset("assets/icons/Search.svg"),
          ),
        ),
      ),
    );
  }
}
