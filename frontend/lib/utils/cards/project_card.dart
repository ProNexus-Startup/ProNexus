import 'package:admin/utils/global_bloc.dart';
import 'package:admin/utils/models/project.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
