import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:admin/pages/available_experts_page.dart';
import 'package:admin/pages/components/header.dart';
import 'package:admin/utils/models/project.dart';
import 'package:admin/utils/BaseAPI.dart';
import 'package:admin/utils/persistence/global_bloc.dart';
import 'package:admin/utils/models/user.dart';
import 'package:admin/utils/persistence/secure_storage.dart';

class AdminPage extends StatefulWidget {
  final String token;
  static const routeName = '/admin';

  const AdminPage({Key? key, required this.token}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<bool> _isSelected = [true, false];
  final AuthAPI _authAPI = AuthAPI();

  @override
  void initState() {
    super.initState();
    _loadData();
    _saveContext();
  }

  Future<void> _saveContext() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('last_route', AdminPage.routeName);
  }

  Future<void> _loadData() async {
    final GlobalBloc globalBloc =
        Provider.of<GlobalBloc>(context, listen: false);
    globalBloc.onUserLogin(widget.token);
  }

  Future<void> _sendProject(Project project) async {
    await _authAPI.makeProject(widget.token, project);
    await _loadData(); // Refresh data after sending the project
  }

  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);
    List<Project> projectList = globalBloc.projectList;
    List<User> userList = globalBloc.userList;

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: TopMenu(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All projects',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  ToggleButtons(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Users'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Projects'),
                      ),
                    ],
                    isSelected: _isSelected,
                    onPressed: (int index) {
                      setState(() {
                        for (int i = 0; i < _isSelected.length; i++) {
                          _isSelected[i] = i == index;
                        }
                      });
                    },
                  ),
                  Text(
                    'ADMIN VIEW',
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: Align(
                    alignment: Alignment.topCenter,
                    child: _isSelected[1]
                        ? ProjectView(
                            projectList: projectList,
                            token: widget.token,
                            globalBloc: globalBloc,
                          )
                        : UserView(
                            userList: userList,
                            token: widget.token,
                            orgId: globalBloc.currentUser.organizationId)),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _isSelected[1]
            ? ElevatedButton(
                onPressed: () async {
                  final Project project = Project.defaultProject(
                      globalBloc.currentUser.organizationId);
                  await _sendProject(project); // Send project and refresh data
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child:
                    Text('+ Add new project', style: TextStyle(fontSize: 16)),
              )
            : null);
  }
}

class ProjectView extends StatelessWidget {
  final List<Project> projectList;
  final String token;
  final GlobalBloc globalBloc;

  const ProjectView({
    required this.projectList,
    required this.token,
    required this.globalBloc,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        columns: [
          DataColumn(label: Text('Project ID')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Calls Completed')),
          DataColumn(label: Text('Target')),
          DataColumn(label: Text('Start Date')),
          DataColumn(label: Text('End Date')),
        ],
        rows: projectList.map((project) {
          return DataRow(
            cells: [
              DataCell(
                Text(project.projectId ?? "Missing ID"),
                onTap: () async {
                  _navigateToDetailPage(context, project);
                },
              ),
              DataCell(
                Text(project.name),
                onTap: () async {
                  _navigateToDetailPage(context, project);
                },
              ),
              DataCell(
                Text(project.callsCompleted.toString()),
                onTap: () async {
                  _navigateToDetailPage(context, project);
                },
              ),
              DataCell(
                Text(project.targetCompany),
                onTap: () async {
                  _navigateToDetailPage(context, project);
                },
              ),
              DataCell(
                Text(project.startDate.toString()),
                onTap: () async {
                  _navigateToDetailPage(context, project);
                },
              ),
              DataCell(
                Text(project.endDate.toString()),
                onTap: () async {
                  _navigateToDetailPage(context, project);
                },
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _navigateToDetailPage(BuildContext context, Project project) async {
    SecureStorage secureStorage = SecureStorage();
    globalBloc.setProjectIdFilter(project.projectId!);
    await secureStorage.write('projectId', project.projectId!);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('last_route', AvailableExpertsDashboard.routeName);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AvailableExpertsDashboard(token: token),
      ),
    );
  }
}

class UserView extends StatelessWidget {
  final List<User> userList;
  final String token;
  final String orgId;

  UserView({
    required this.userList,
    required this.token,
    required this.orgId,
    Key? key,
  }) : super(key: key);

  final AuthAPI _authAPI = AuthAPI();

  void _showAddUserDialog(BuildContext context, String orgId) {
    TextEditingController emailController = TextEditingController();
    TextEditingController fullNameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController levelController = TextEditingController();
    bool isAdmin = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add New User'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(hintText: "Email"),
                    ),
                    TextField(
                      controller: levelController,
                      decoration: InputDecoration(hintText: "Level at Company"),
                    ),
                    TextField(
                      controller: fullNameController,
                      decoration: InputDecoration(hintText: "Full Name"),
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(hintText: "Password"),
                    ),
                    SwitchListTile(
                      title: Text("Is Admin"),
                      value: isAdmin,
                      onChanged: (bool value) {
                        setState(() => isAdmin = value);
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Add'),
                  onPressed: () async {
                    final GlobalBloc globalBloc =
                        Provider.of<GlobalBloc>(context, listen: false);

                    User user = User(
                      admin: isAdmin,
                      email: emailController.text,
                      fullName: fullNameController.text,
                      password: passwordController.text,
                      level: levelController.text,
                      organizationId: orgId,
                      currentProject: globalBloc.benchProject,
                      pastProjects: [
                        Proj(
                            projectId: globalBloc.benchProject,
                            start: DateTime(1, 1))
                      ],
                    );
                    await _authAPI.signup(user);
                    await _loadData(context); // Pass context here
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _loadData(BuildContext context) async {
    final GlobalBloc globalBloc =
        Provider.of<GlobalBloc>(context, listen: false);
    globalBloc.onUserLogin(token);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            columns: const [
              DataColumn(label: Text('User ID')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Rank')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Last login')),
              DataColumn(label: Text('Number of projects')),
            ],
            rows: userList.map((user) {
              return DataRow(
                cells: [
                  DataCell(Text(user.userId ?? '')),
                  DataCell(Text(user.fullName)),
                  DataCell(Text(user.email)),
                  DataCell(Text(user.level)),
                  DataCell(Text('Active')), // Example Status
                  DataCell(Text('4/2/24')), // Example Last login
                  DataCell(
                      Text((user.pastProjects.toSet().length - 1).toString())),
                ],
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0),
          child: TextButton.icon(
            onPressed: () {
              _showAddUserDialog(context, orgId);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add new user'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
          ),
        ),
      ],
    );
  }
}
