import 'package:admin/pages/ai_match_page.dart';
import 'package:admin/pages/available_experts_page.dart';
import 'package:admin/pages/budget_inputs_page.dart';
import 'package:admin/pages/call_tracker_page.dart';
import 'package:admin/pages/project_dashboard_page.dart';
import 'package:admin/utils/formatting/app_theme.dart';
import 'package:admin/utils/models/project.dart';
import 'package:admin/utils/persistence/screen_arguments.dart';
import 'package:admin/utils/persistence/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/persistence/global_bloc.dart';

class SubMenu extends StatefulWidget {
  final String token;

  const SubMenu({Key? key, required this.token}) : super(key: key);

  @override
  _SubMenuState createState() => _SubMenuState();
}

class _SubMenuState extends State<SubMenu> {
  bool isProjectInfoSelected = false;
  bool isDraftAngleOutreachSelected = false;
  late String projectName = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    Project? project = await findProjectById();
    if (project != null) {
      setState(() {
        projectName = project.name;
      });
    }
  }

  Future<Project?> findProjectById() async {
    final GlobalBloc globalBloc =
        Provider.of<GlobalBloc>(context, listen: false);
    List<Project> projects = globalBloc.projectList;

    SecureStorage secureStorage = SecureStorage();
    String? projectId = await secureStorage.read('projectId');

    if (projectId == null) return null;

    return projects.firstWhere((project) => project.projectId == projectId);
  }

  Future<void> _saveContext(String route) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('last_route', route);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.white60, // Adjust the background color to match your navbar
      child: Row(
        children: [
          SizedBox(
            width: 365,
            child: Row(
              children: <Widget>[
                const SizedBox(width: 30),
                _menuItem(projectName, () {}),
              ],
            ),
          ),
          Expanded(
            child: Consumer<GlobalBloc>(builder: (context, globalBloc, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _dropdownMenuItem("Draft angle outreach", () {
                    setState(() {
                      isDraftAngleOutreachSelected =
                          !isDraftAngleOutreachSelected;
                    });
                  }, isDraftAngleOutreachSelected, [
                    PopupMenuItem<int>(
                      value: 1,
                      child: Text('Draft an outreach for a specific angle'),
                    ),
                    PopupMenuItem<int>(
                      value: 2,
                      child: Text('Add angles'),
                    ),
                  ]),
                  _menuItem(
                    "Project dashboard",
                    () {
                      _saveContext(ProjectDashboard.routeName);
                      Navigator.pushNamed(context, ProjectDashboard.routeName,
                          arguments: ScreenArguments(widget.token));
                    },
                  ),
                  _menuItem("Available experts", () async {
                    _saveContext(AvailableExpertsDashboard.routeName);
                    Navigator.pushNamed(
                        context, AvailableExpertsDashboard.routeName,
                        arguments: ScreenArguments(widget.token));
                  },
                      countValue: globalBloc.unfilteredExpertList.length,
                      isSelected: ModalRoute.of(context)!.settings.name ==
                          '/available-expert'),
                  _menuItem("Call tracker", () async {
                    _saveContext(CallTrackerDashboard.routeName);
                    Navigator.pushNamed(context, CallTrackerDashboard.routeName,
                        arguments: ScreenArguments(widget.token));
                  },
                      countValue: globalBloc.unfilteredCallList.length,
                      isSelected: ModalRoute.of(context)!.settings.name ==
                          '/call-tracker'),
                  _dropdownMenuItem("Project info", () {
                    setState(() {
                      isProjectInfoSelected = !isProjectInfoSelected;
                    });
                  }, isProjectInfoSelected, [
                    PopupMenuItem<int>(
                      value: 1,
                      child: Text('AI match adjustment'),
                      onTap: () async {
                        _saveContext(AiMatchPage.routeName);
                        Navigator.pushNamed(context, AiMatchPage.routeName,
                            arguments: ScreenArguments(widget.token));
                      },
                    ),
                    PopupMenuItem<int>(
                      value: 2,
                      child: Text('Call invite format'),
                    ),
                  ]),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(String title, VoidCallback onTap,
      {bool isDropdown = false, int? countValue, bool isSelected = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Text(title, style: isSelected ? customSelectedStyle : customStyle),
            if (isDropdown)
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Icon(Icons.keyboard_arrow_down,
                    color: isSelected ? primaryBlue : darkGrey),
              ),
            if (countValue != null)
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: isSelected ? primaryBlue : darkGrey,
                  child: Text(
                    countValue.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dropdownMenuItem(String title, VoidCallback onTap, bool isSelected,
      List<PopupMenuEntry<int>> items) {
    return Builder(
      builder: (context) {
        return InkWell(
          onTap: () {
            onTap();
            final RenderBox button = context.findRenderObject() as RenderBox;
            final RenderBox overlay =
                Overlay.of(context).context.findRenderObject() as RenderBox;
            final Offset position =
                button.localToGlobal(Offset.zero, ancestor: overlay);
            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(
                position.dx,
                position.dy + button.size.height,
                position.dx + button.size.width,
                position.dy,
              ),
              items: items,
            ).then((value) {
              onTap(); // Reset the selection state
              if (value != null) {
                _handleMenuSelection(title, value);
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Text(title,
                    style: isSelected ? customSelectedStyle : customStyle),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Icon(Icons.keyboard_arrow_down,
                      color: isSelected ? primaryBlue : darkGrey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleMenuSelection(String title, int value) {
    switch (title) {
      case "Project info":
        switch (value) {
          case 1:
            _saveContext(AiMatchPage.routeName);
            Navigator.pushNamed(context, AiMatchPage.routeName,
                arguments: ScreenArguments(widget.token));
            break;
          case 2:
            // Handle Call invite format selection
            break;
        }
        break;
      case "Draft angle outreach":
        switch (value) {
          case 1:
            // Handle Draft an outreach for a specific angle selection
            break;
          case 2:
            // Handle Add angles selection
            break;
        }
        break;
    }
  }

  static const TextStyle customStyle =
      TextStyle(color: darkGrey, fontSize: 14, fontWeight: FontWeight.w500);
  static const TextStyle customSelectedStyle =
      TextStyle(color: primaryBlue, fontSize: 14, fontWeight: FontWeight.w500);
}
