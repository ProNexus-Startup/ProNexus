import 'package:admin/pages/components/side_menu.dart';
import 'package:admin/responsive.dart';
import 'package:admin/utils/controllers/MenuAppController.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/constants.dart';
import 'dashboard_visuals/header.dart';

import 'dashboard_visuals/expert_table.dart';

class DashboardScreen extends StatelessWidget {
  final String token; // Username variable
  static const routeName = '/dashboard';

  const DashboardScreen({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menuAppController =
        Provider.of<MenuAppController>(context, listen: false);

    return Scaffold(
      key: menuAppController.scaffoldKey, // Assigning the GlobalKey here
      drawer: SideMenu(),
      body: SafeArea(
        child: SingleChildScrollView(
          primary: false,
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              Header(),
              SizedBox(height: defaultPadding),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        //ProgressSection(),
                        SizedBox(height: defaultPadding),
                        ExpertTable(),
                        if (Responsive.isMobile(context))
                          SizedBox(height: defaultPadding),
                        //if (Responsive.isMobile(context)) RoleTypes(),
                      ],
                    ),
                  ),
                  if (!Responsive.isMobile(context))
                    SizedBox(width: defaultPadding),
                  // On Mobile means if the screen is less than 850 we don't want to show it
                  /*if (!Responsive.isMobile(context))
                    Expanded(
                      flex: 2,
                      child: RoleTypes(),
                    ),*/
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
