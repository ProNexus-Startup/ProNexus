import 'package:admin/pages/schedule_meeting_screen.dart';
import 'package:admin/responsive.dart';
import 'package:admin/utils/models/available_expert.dart';
import 'package:admin/utils/global_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import 'components/header.dart';

class CallTrackerDashboard extends StatefulWidget {
  final String token; // Username variable
  static const routeName = '/experts';

  const CallTrackerDashboard({Key? key, required this.token}) : super(key: key);

  @override
  _CallTrackerDashboardState createState() => _CallTrackerDashboardState();
}

class _CallTrackerDashboardState extends State<CallTrackerDashboard> {
  bool isAnySelected = false;

  void updateSelection(bool isSelected) {
    setState(() {
      isAnySelected = isSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      primary: false,
      padding: EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          Header(),
          SizedBox(height: defaultPadding),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!Responsive.isMobile(context))
                SizedBox(width: defaultPadding),
            ],
          )
        ],
      ),
    );
  }
}

class ExpertTable extends StatefulWidget {
  @override
  _ExpertTableState createState() => _ExpertTableState();
}

class _ExpertTableState extends State<ExpertTable> {
  bool areAllSelected(List<AvailableExpert> experts) {
    return experts.every((expert) => expert.isSelected);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalBloc>(builder: (context, globalBloc, child) {
      return Container(
        padding: EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expanded widget for the DataTable to take up most of the space
            Expanded(
              flex: 5, // Adjust the flex as needed to distribute space
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth:
                          800), // Adjust minWidth for your DataTable needs
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: defaultPadding,
                      showCheckboxColumn: false,
                      columns: [
                        DataColumn(label: Text("Favorite")),
                        DataColumn(label: Text("Name")),
                        DataColumn(label: Text("Title")),
                        DataColumn(label: Text("Company")),
                        DataColumn(label: Text("Years")),
                        DataColumn(label: Text("Geography")),
                        DataColumn(label: Text("Angle")),
                        DataColumn(label: Text("AI Match")),
                        DataColumn(label: Text("AI Analysis")),
                        DataColumn(label: Text("Comments from Network")),
                        DataColumn(label: Text("Availability")),
                      ],
                      rows: globalBloc.expertList
                          //.where((expert) => globalBloc.applyFilters(
                          //  expert)) // Ensure filtering logic is applied
                          .map<DataRow>((expert) => recentFileDataRow(
                              context, expert, globalBloc.toggleFavorite))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  DataRow recentFileDataRow(BuildContext context, AvailableExpert expert,
      void Function(AvailableExpert) toggleFavorite) {
    // Method to show the popup menu
    void _showPopupMenu(BuildContext context, AvailableExpert expert) async {
      final RenderBox overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox;
      final RelativeRect position = RelativeRect.fromRect(
        Rect.fromPoints(
          overlay.localToGlobal(Offset.zero), // Top left corner of the overlay
          overlay.localToGlobal(overlay.size
              .bottomRight(Offset.zero)), // Bottom right corner of the overlay
        ),
        Offset.zero & overlay.size,
      );

      final String? selectedItem = await showMenu<String>(
        context: context,
        position: position, // Show the menu in the center of the overlay
        items: [
          PopupMenuItem<String>(
            value: 'scheduleMeeting',
            child: Text('Schedule Meeting'),
          ),
          PopupMenuItem<String>(
            value: 'delete',
            child: Text('Delete'),
          ),
          // Add more options as needed
        ],
      );

      // Handling the selected action
      if (selectedItem != null) {
        switch (selectedItem) {
          case 'scheduleMeeting':
            // Navigate to the EditExpertScreen with the selected expert
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ScheduleMeeting(), //expert: expert),
              ),
            );
            break;
          case 'delete':
            print('Delete action on ${expert.name}');
            // Handle delete action
            break;
          // Handle other cases as necessary
        }
      }
    }

    return DataRow(
      onSelectChanged: (bool? selected) {
        if (selected ?? false) {
          // This is where you handle the row selection. For demonstration, we show the popup menu.
          _showPopupMenu(context, expert);
        }
      },
      cells: [
        DataCell(
          IconButton(
            icon: Icon(
              expert.favorite ? Icons.star : Icons.star_border,
              color: expert.favorite ? Colors.yellow : null,
            ),
            onPressed: () => toggleFavorite(expert),
          ),
        ),
        DataCell(
          InkWell(
            onTap: () {
              // Show popup menu on tap
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(100, 100, 100,
                    100), // You can adjust the position as needed
                items: [
                  PopupMenuItem<String>(
                    child: const Text('Edit'),
                    value: 'Edit',
                  ),
                  PopupMenuItem<String>(
                    child: const Text('Delete'),
                    value: 'Delete',
                  ),
                ],
              ).then((value) {
                // Handle your action based on the selected option
                if (value == 'Edit') {
                  print('Edit tapped');
                } else if (value == 'Delete') {
                  print('Delete tapped');
                }
              });
            },
            child: Text(expert.name),
          ),
        ),
        DataCell(Text(expert.title)),
        DataCell(Text(expert.company)),
        DataCell(Text('${expert.yearsAtCompany}')),
        DataCell(Text(expert.geography)),
        DataCell(Text(expert.angle)),
        DataCell(Text(expert.status)),
        DataCell(Text('${expert.AIAssessment}')),
        DataCell(Text(expert.comments ?? '')),
        DataCell(Text(expert.availability)),
      ],
    );
  }
}
