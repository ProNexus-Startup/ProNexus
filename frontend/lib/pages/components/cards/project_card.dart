//import 'package:admin/pages/available_experts_page.dart';
import 'package:admin/utils/formatting/app_theme.dart';
import 'package:admin/utils/persistence/global_bloc.dart';
import 'package:admin/utils/models/project.dart';
import 'package:admin/utils/persistence/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      onTap: () async {
        SecureStorage secureStorage = SecureStorage();
        globalBloc.setProjectIdFilter(project.projectId!);
        await secureStorage.write('projectId', project.projectId!);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        //prefs.setString('last_route', AvailableExpertsDashboard.routeName);

        /*Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AvailableExpertsDashboard(token: token),
          ),
        );*/
      },
      child: Card(
        child: ListTile(
          title: Text(project.name),
          subtitle: Text(
              'Start date: ${DateFormat('MM/dd/yyyy').format(project.startDate)}\nTarget: ${project.targetCompany}\nCalls completed: ${project.callsCompleted}'),
          trailing: ElevatedButton(
            onPressed: () async {},
            child: Text(project.status),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  // Define colors based on project status
                  switch (project.status) {
                    case 'Open':
                      return greenButtonColor; // Green for Open
                    case 'In Progress':
                      return Colors.amber; // Orange for In Progress
                    case 'Complete':
                      return primaryBlue; // Blue for Complete
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
