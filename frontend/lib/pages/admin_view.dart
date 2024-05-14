import 'package:admin/pages/available_experts_dashboard.dart';
import 'package:admin/pages/components/top_menu.dart';
import 'package:admin/utils/models/project.dart';
import 'package:admin/utils/BaseAPI.dart';
import 'package:admin/utils/global_bloc.dart';
import 'package:admin/utils/models/user.dart';
import 'package:admin/utils/persistence/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  }

  Future<void> _loadData() async {
    final GlobalBloc globalBloc =
        Provider.of<GlobalBloc>(context, listen: false);
    globalBloc.onUserLogin(widget.token);
  }

  void _showAddProjectDialog(BuildContext context, organizationId) {
    TextEditingController projectNameController = TextEditingController();
    DateTime? startDate; // Changed to DateTime to store date object
    TextEditingController targetController = TextEditingController();
    String? selectedStatus; // This will hold the selected status

    // Define the statuses available for selection
    List<String> statuses = ['Open', 'In Progress', 'Complete'];

    // Function to show DatePicker
    Future<void> _selectStartDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: startDate ??
            DateTime.now(), // Use current date if no date has been picked
        firstDate: DateTime(2000), // Adjust based on your requirement
        lastDate: DateTime(2025),
      );
      if (picked != null && picked != startDate) {
        // Update the state with the new selected date
        (context as Element).markNeedsBuild();
        startDate = picked;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add New Project'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      controller: projectNameController,
                      decoration: InputDecoration(hintText: "Project Name"),
                    ),
                    InkWell(
                      onTap: () {
                        _selectStartDate(context).then((_) {
                          // Update UI after date selection
                          setState(() {});
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.grey))),
                        child: Text(
                          startDate == null
                              ? "Select Start Date"
                              : "${startDate!.month}/${startDate!.day}/${startDate!.year}",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ),
                    ),
                    TextField(
                      controller: targetController,
                      decoration: InputDecoration(hintText: "Target"),
                    ),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedStatus,
                      hint: Text("Select Status"),
                      onChanged: (String? newValue) {
                        setState(() => selectedStatus = newValue);
                      },
                      items: statuses
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
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
                  onPressed: () {
                    Project project = Project(
                        name: projectNameController.text,
                        startDate: startDate!,
                        organizationId: organizationId,
                        target: targetController.text,
                        callsCompleted: 0,
                        status: selectedStatus.toString());
                    _authAPI.makeProject(widget.token, project);
                    _loadData();
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

  void _showAddUserDialog(BuildContext context, orgId) {
    TextEditingController emailController = TextEditingController();
    TextEditingController fullNameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
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
                    User user = User(
                        admin: isAdmin,
                        email: emailController.text,
                        fullName: fullNameController.text,
                        password: passwordController.text,
                        organizationId: orgId);
                    var response = await _authAPI.signup(user);
                    print(response);
                    _loadData();
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

  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);
    List<Project> projectList = globalBloc.projectList;
    List<User> userList = globalBloc.userList;

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(100), // Set the height of the app bar
          child: TopMenu()),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'All projects',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Adjust alignment
              children: [
                Container(), // Placeholder to maintain the space on the left
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
                      // This will make only the tapped button selected
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
            if (_isSelected[1])
              ProjectView(
                projectList: projectList,
                token: widget.token,
                globalBloc: globalBloc,
              ),
            if (!_isSelected[1]) UserView(userList: userList),
          ])),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isSelected[1]
          ? ElevatedButton(
              onPressed: () {
                _showAddProjectDialog(
                    context, globalBloc.currentUser.organizationId);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text('+ Add new project', style: TextStyle(fontSize: 16)),
            )
          : ElevatedButton(
              onPressed: () => _showAddUserDialog(
                  context, globalBloc.currentUser.organizationId),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text('+ Add new user', style: TextStyle(fontSize: 16)),
            ),
    );
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
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
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
                DataCell(Text(project.projectId ?? "Missing ID")),
                DataCell(Text(project.name)),
                DataCell(Text(project.callsCompleted.toString())),
                DataCell(Text(project.target)),
                DataCell(Text(project.startDate.toString())),
                DataCell(Text(project.endDate.toString())),
              ],
              onSelectChanged: (bool? selected) async {
                SecureStorage secureStorage = SecureStorage();
                if (selected != null && selected) {
                  globalBloc.setProjectIdFilter(project.projectId!);
                  await secureStorage.write('projectId', project.projectId!);

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          AvailableExpertsDashboard(token: token),
                    ),
                  );
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class UserView extends StatelessWidget {
  final List<User> userList;

  const UserView({
    required this.userList,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('User ID')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Current Project')),
        ],
        rows: userList
            .map((user) => DataRow(cells: [
                  DataCell(Text(user.userId ?? '')),
                  DataCell(Text(user.fullName)),
                  DataCell(Text(user.email)),
                  DataCell(Text(user.projectId ?? ''))
                ]))
            .toList(),
      ),
    ));
  }
}
