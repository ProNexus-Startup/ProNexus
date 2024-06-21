import 'package:admin/pages/components/sub_menu.dart';
import 'package:admin/pages/components/header.dart';
import 'package:admin/utils/math/project_dashboard_functions.dart';
import 'package:admin/utils/formatting/app_theme.dart';
import 'package:admin/utils/persistence/global_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectDashboard extends StatefulWidget {
  final String token;
  static const routeName = '/project-dashboard';

  const ProjectDashboard({Key? key, required this.token}) : super(key: key);

  @override
  _ProjectDashboardState createState() => _ProjectDashboardState();
}

class _ProjectDashboardState extends State<ProjectDashboard> {
  bool isAnySelected = false;

  @override
  void initState() {
    super.initState();
    _saveContext();
    _loadData();
  }

  Future<void> _saveContext() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('last_route', ProjectDashboard.routeName);
  }

  Future<void> _loadData() async {
    final GlobalBloc globalBloc =
        Provider.of<GlobalBloc>(context, listen: false);
    globalBloc.onUserLogin(widget.token);
  }

  // Update this based on checkbox changes
  void updateSelection(bool isSelected) {
    setState(() {
      isAnySelected = isSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);
    List<String> uniqueAngles = getUniqueAngles(globalBloc.unfilteredCallList);
    List<String> uniqueNetworks =
        getUniqueExpertNetworks(globalBloc.unfilteredCallList);
    List<List<String>> callProgress =
        countByAngle(globalBloc.unfilteredCallList, uniqueAngles);
    List<List<String>> networkProgress =
        sumPriceByNetwork(globalBloc.unfilteredCallList, uniqueNetworks);

    // Ensure all rows have the same number of cells as there are columns
    callProgress = callProgress.map((row) {
      if (row.length < 5) {
        row.addAll(List<String>.filled(5 - row.length, ''));
      }
      return row;
    }).toList();

    networkProgress = networkProgress.map((row) {
      if (row.length < 4) {
        row.addAll(List<String>.filled(4 - row.length, ''));
      }
      return row;
    }).toList();

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(100), // Set the height of the app bar
          child: TopMenu()),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SubMenu(
              token: widget.token,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 160.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Call Progress",
                      style: TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircularDataTable(
                        columnHeaders: [
                          'Angles',
                          'Completed',
                          'Scheduled',
                          'Progress total',
                          'Goals'
                        ],
                        rowsData: callProgress,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Total Costs",
                      style: TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircularDataTable(
                        columnHeaders: [
                          'Source',
                          'Total',
                          'Value',
                          'Metric',
                        ],
                        rowsData: [
                          [
                            'Expert networks',
                            '\$4,500',
                            'Estimated total project fees',
                            '\$54,000'
                          ],
                          [
                            'Survey',
                            '\$5,000',
                            'Budget (at 17.5% of fees)',
                            '\$60,000'
                          ],
                          [
                            'Market research',
                            '\$10,000',
                            'Days Remaining in Project',
                            '10'
                          ],
                          ['Personal', '\$700', '% of calls complete', '25%'],
                          ['Others', '\$230', '', ''],
                          ['Totals', '\$15,930', '', ''],
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Total Costs",
                      style: TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircularDataTable(
                        columnHeaders: [
                          'Expert Network',
                          'Completed',
                          'Scheduled',
                          'Progress total',
                        ],
                        rowsData: networkProgress,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularDataTable extends StatelessWidget {
  final List<String> columnHeaders;
  final List<List<String>> rowsData;

  CircularDataTable({required this.columnHeaders, required this.rowsData});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0), // Circular corners
        border: Border.all(
          color: offWhite, // Border color
          width: 1.0, // Border width
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Column(
          children: [
            Container(
              color: primaryBlue,
              child: DataTable(
                headingRowHeight: 56.0, // Adjust the height as needed
                headingRowColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                  return primaryBlue; // Customize the header row color
                }),
                columns: columnHeaders
                    .map(
                      (header) => DataColumn(
                        label: Text(
                          header,
                          style: TextStyle(
                            color: Colors.white, // Change text color to white
                          ),
                        ),
                      ),
                    )
                    .toList(),
                rows: rowsData.asMap().entries.map((entry) {
                  int index = entry.key;
                  List<String> row = entry.value;
                  bool isLastRow = index == rowsData.length - 1;
                  return DataRow(
                    color: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                      return index % 2 == 0
                          ? Colors.white
                          : offWhite; // Alternating row color
                    }),
                    cells: row
                        .map((cell) => DataCell(
                              Text(
                                cell,
                                style: isLastRow
                                    ? TextStyle(fontWeight: FontWeight.bold)
                                    : TextStyle(fontWeight: FontWeight.normal),
                              ),
                            ))
                        .toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
