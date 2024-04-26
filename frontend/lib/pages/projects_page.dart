import 'dart:convert';
import 'package:admin/pages/components/page_wrapper.dart';
import 'package:admin/utils/models/project.dart';
import 'package:admin/utils/BaseAPI.dart';
import 'package:admin/utils/global_bloc.dart';
import 'package:admin/utils/persistence/screen_arguments.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ProjectPage extends StatefulWidget {
  final String token;
  static const routeName = '/projects';

  const ProjectPage({Key? key, required this.token}) : super(key: key);

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
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

  Future<void> postProject(
      String name, DateTime startDate, String target, String status) async {
    AuthAPI _authAPI = AuthAPI();
    final response = await http.post(
      _authAPI.makeProjectPath,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode({
        'projectId': '', // This is a unique identifier for the project
        'name': name, // Name of the project
        'startDate': startDate
            .toUtc()
            .toIso8601String(), //startDate, // Start date in ISO 8601 format
        'target': target, // The target goal of the project
        'callsCompleted':
            0, // Number of calls or actions completed towards the project
        'status': status, // The current status of the project
      }),
    );

    if (response.statusCode == 200) {
      // Handle the response body if the call was successful
      print('Success: ${response.body}');
      _loadUserData();
    } else {
      // Handle the error
      print('Failed to post project. StatusCode: ${response.statusCode}');
    }
  }

  void _showAddProjectDialog(
    BuildContext context,
  ) {
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
        // To reflect changes in dropdown, using StatefulBuilder to rebuild the AlertDialog widget
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
                    postProject(projectNameController.text, startDate!,
                        targetController.text, selectedStatus.toString());
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

    return Scaffold(
      appBar: AppBar(
        title: Text('All Projects'),
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        itemCount: projectList.length,
        itemBuilder: (context, index) {
          print(projectList[index].projectId);
          return ProjectTile(project: projectList[index], token: widget.token);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProjectDialog(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class ProjectTile extends StatelessWidget {
  final Project project;
  final String token;

  const ProjectTile({
    required this.project,
    required this.token,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc =
        Provider.of<GlobalBloc>(context, listen: false);

    return InkWell(
      onTap: () {
        globalBloc.setProjectIdFilter(project.projectId);
        Navigator.pushReplacementNamed(context, HomePage.routeName,
            arguments: ScreenArguments(token, ""));
      },
      child: Card(
        child: ListTile(
          title: Text(project.name),
          subtitle: Text(
              'Start date: ${DateFormat('MM/dd/yyyy').format(project.startDate)}\nTarget: ${project.target ?? "Whatever"}\nCalls completed: ${project.callsCompleted}'),
          trailing: ElevatedButton(
            onPressed: () {
              // Your existing button press logic here
            },
            child: Text(project.status ?? "Missing Status"),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  // Define colors based on project status
                  switch (project.status) {
                    case 'Open':
                      return Colors.green; // Green for Open
                    case 'In Progress':
                      return Colors.orange; // Orange for In Progress
                    case 'Complete':
                      return Colors.blue; // Blue for Complete
                    default:
                      return Colors
                          .grey; // Default color for unspecified or missing status
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
