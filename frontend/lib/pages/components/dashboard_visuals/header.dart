import 'package:admin/responsive.dart';
import 'package:admin/utils/global_bloc.dart';
import 'package:admin/utils/persistence/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../utils/constants.dart';

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key); // Removed the User parameter

  @override
  Widget build(BuildContext context) {
    // Removed User from arguments and fetch it from GlobalBloc
    return Row(
      children: [
        // Your existing code...
        Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        ProfileCard() // Removed the user parameter
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({Key? key}) : super(key: key); // Removed the User parameter

  @override
  Widget build(BuildContext context) {
    // Fetch user information from GlobalBloc
    final User user = Provider.of<GlobalBloc>(context).currentUser;

    return Container(
      // Your existing ProfileCard code...
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
              // Use user's fullName from the GlobalBloc
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
