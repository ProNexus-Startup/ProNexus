import 'package:admin/pages/components/sub_menu.dart';
import 'package:admin/pages/components/top_menu.dart';
import 'package:admin/pages/schedule_meeting_screen.dart';
import 'package:admin/responsive.dart';
import 'package:admin/utils/global_bloc.dart';
import 'package:admin/utils/BaseAPI.dart';
import 'package:admin/utils/models/call_tracker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';

class CallTrackerDashboard extends StatefulWidget {
  final String token;
  static const routeName = '/calls';

  const CallTrackerDashboard({Key? key, required this.token}) : super(key: key);

  @override
  _CallTrackerDashboardState createState() => _CallTrackerDashboardState();
}

class _CallTrackerDashboardState extends State<CallTrackerDashboard> {
  final AuthAPI _authAPI = AuthAPI();

  bool isAnySelected = false;

  // Update this based on checkbox changes
  void updateSelection(bool isSelected) {
    setState(() {
      isAnySelected = isSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc =
        Provider.of<GlobalBloc>(context, listen: false);

    return Scaffold(
        appBar: PreferredSize(
            preferredSize:
                Size.fromHeight(100), // Set the height of the app bar
            child: TopMenu()),
        body: Column(children: [
          SubMenu(
            onItemSelected: (String item) {
              print("Selected: $item"); // Example action
            },
            projectName: "Project name here later",
          ),
          Expanded(
              child: SingleChildScrollView(
            primary: false,
            padding: EdgeInsets.all(defaultPadding),
            child: Column(
              children: [
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
                          CallTable(),
                          if (Responsive.isMobile(context))
                            SizedBox(height: defaultPadding),
                          // Adding the new ElevatedButton here
                          ElevatedButton(
                            onPressed: () {
                              //_authAPI.postCall(globalBloc, widget.token);
                            },
                            child: Text('Add Call'), // Button text
                          ),
                          //if (Responsive.isMobile(context)) RoleTypes(),
                        ],
                      ),
                    ),
                    if (!Responsive.isMobile(context))
                      SizedBox(width: defaultPadding),
                  ],
                )
              ],
            ),
          ))
        ]));
  }
}

class CallTable extends StatefulWidget {
  @override
  _CallTableState createState() => _CallTableState();
}

class _CallTableState extends State<CallTable> {
  bool areAllSelected(List<CallTracker> calls) {
    return calls.every((call) => call.isSelected);
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
                      rows: globalBloc.callList
                          //.where((call) => globalBloc.applyFilters(
                          //  call)) // Ensure filtering logic is applied
                          .map<DataRow>((call) => recentFileDataRow(
                              context, call, globalBloc.toggleFavorite))
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

  DataRow recentFileDataRow(BuildContext context, CallTracker call,
      void Function(CallTracker) toggleFavorite) {
    // Method to show the popup menu
    void _showPopupMenu(BuildContext context, CallTracker call) async {
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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ScheduleMeeting(),
              ),
            );
            break;
          case 'delete':
            print('Delete action on ${call.name}');
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
          _showPopupMenu(context, call);
        }
      },
      cells: [
        DataCell(
          IconButton(
            icon: Icon(
              call.favorite ? Icons.star : Icons.star_border,
              color: call.favorite ? Colors.yellow : null,
            ),
            onPressed: () => toggleFavorite(call),
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
            child: Text(call.name),
          ),
        ),
        DataCell(Text(call.title)),
        DataCell(Text(call.company)),
        DataCell(Text('${call.yearsAtCompany}')),
        DataCell(Text(call.geography)),
        DataCell(Text(call.angle)),
        DataCell(Text(call.status)),
        DataCell(Text('${call.AIAssessment}')),
        DataCell(Text(call.comments ?? '')),
        DataCell(Text(call.availability)),
      ],
    );
  }
}
