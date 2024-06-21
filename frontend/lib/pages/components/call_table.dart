import 'package:admin/pages/expert_specific_page.dart';
import 'package:admin/utils/formatting/app_theme.dart';
import 'package:admin/utils/math/project_dashboard_functions.dart';
import 'package:admin/utils/models/call_tracker.dart';
import 'package:admin/utils/persistence/global_bloc.dart';
import 'package:admin/utils/persistence/screen_arguments.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import 'dart:html' as html; // Only needed for web
import 'package:flutter/services.dart';

class CallTable extends StatefulWidget {
  const CallTable({super.key, required this.callsList});
  final List<CallTracker> callsList;

  @override
  State<CallTable> createState() => CallTableState();
}

class CallTableState extends State<CallTable> {
  late final ScrollController _verticalController = ScrollController();
  late final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  void showAngleMenu(BuildContext context, List<String> uniqueAngles) async {
    if (uniqueAngles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No angles available')),
      );
      return;
    }

    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final selectedAngle = await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Offset.zero &
            const Size(40, 40), // This is the position of the popup menu
        Offset.zero & overlay.size,
      ),
      items: uniqueAngles.map((String angle) {
        return PopupMenuItem<String>(
          value: angle,
          child: Text(angle),
        );
      }).toList(),
    );

    if (selectedAngle != null) {
      // Handle the selected angle here
      print('Selected angle: $selectedAngle');
    }
  }

  String _getCellContent(TableVicinity vicinity) {
    if (vicinity.row == 0) {
      return header[vicinity.column];
    }

    final expertData = widget.callsList[vicinity.row - 1];
    return _extractTextFromCell(_buildCellData(expertData, vicinity.column));
  }

  String _extractTextFromCell(Widget cell) {
    if (cell is Text) {
      return cell.data ?? '';
    } else if (cell is Column) {
      // Assuming that the Column contains InkWell which contains an Image.asset
      return '';
    } else if (cell is DropdownButton<String>) {
      return cell.value ?? '';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Scrollbar(
        controller: _horizontalController,
        interactive: true,
        thumbVisibility: true,
        trackVisibility: true,
        child: Scrollbar(
          controller: _verticalController,
          interactive: true,
          thumbVisibility: true,
          trackVisibility: true,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16, left: 16),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: offWhite,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TableView.builder(
              cellBuilder: _buildCell,
              columnCount: header.length,
              rowCount: widget.callsList.length + 1,
              columnBuilder: _buildColumnSpan,
              pinnedRowCount: 1,
              rowBuilder: (val) {
                return Span(extent: FixedSpanExtent(val == 0 ? 66 : 71));
              },
            ),
          ),
        ),
      ),
    );
  }

  TableViewCell _buildCell(BuildContext context, TableVicinity vicinity) {
    if (vicinity.row == 0) {
      return TableViewCell(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            header[vicinity.column],
            style: const TextStyle(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return TableViewCell(
      child: GestureDetector(
        onTapUp: (TapUpDetails details) {
          final RenderBox overlay =
              Overlay.of(context).context.findRenderObject() as RenderBox;
          final Offset tapPosition = details.globalPosition;

          showMenu(
            context: context,
            position: RelativeRect.fromLTRB(
              tapPosition.dx,
              tapPosition.dy,
              overlay.size.width - tapPosition.dx,
              overlay.size.height - tapPosition.dy,
            ),
            items: <PopupMenuEntry>[
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.copy),
                  title: const Text('Copy'),
                  onTap: () {
                    final cellContent = _getCellContent(vicinity);
                    Clipboard.setData(ClipboardData(text: cellContent));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied to clipboard: $cellContent'),
                      ),
                    );
                    Navigator.of(context).pop(); // Close the menu
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.navigation),
                  title: const Text('Navigate'),
                  onTap: () async {
                    final GlobalBloc globalBloc =
                        Provider.of<GlobalBloc>(context, listen: false);

                    final expertId = widget.callsList[vicinity.row - 1].id;
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString('expert_string', expertId);
                    await Navigator.pushNamed(
                      context,
                      ExpertSpecificPage.routeName,
                      arguments: ScreenArguments(globalBloc.currentUser.token!),
                    );
                    Navigator.of(context).pop(); // Close the menu
                  },
                ),
              ),
              if (header[vicinity.column] == 'Angle')
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Change angle'),
                    onTap: () {
                      final GlobalBloc globalBloc =
                          Provider.of<GlobalBloc>(context, listen: false);

                      List<String> uniqueAngles =
                          getUniqueAngles(globalBloc.unfilteredCallList);
                      Navigator.of(context).pop(); // Close the menu

                      showAngleMenu(
                          context, uniqueAngles); // Show the popup menu
                    },
                  ),
                ),
            ],
          );
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 4 * 20.0, // Ensures each row is 4 lines tall
            maxHeight: 4 * 20.0,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _buildCellData(
                widget.callsList[vicinity.row - 1],
                vicinity.column,
              ),
            ),
          ),
        ),
      ),
    );
  }

  TableSpan _buildColumnSpan(int index) {
    return TableSpan(
      extent: _columnExtents[index].isFixed
          ? FixedTableSpanExtent(_columnExtents[index].extent)
          : FractionalTableSpanExtent(_columnExtents[index].extent),
    );
  }

  List<String> header = [
    'Favorite',
    'Comment',
    'Status',
    'Name',
    'Title',
    'Company',
    'Year',
    'Geography',
    'Angle',
    'AI match',
    'AI analysis',
    'Comments from network',
    'Availability',
    'Network',
    'Cost (1 hr)',
  ];

  late List<ExtentModel> _columnExtents = List.generate(
    header.length,
    (index) => ExtentModel(extent: 150, isFixed: true),
  );

  Widget _buildCellData(CallTracker callData, int columnIndex) {
    switch (header[columnIndex]) {
      case 'Favorite':
        return Icon(callData.favorite ? Icons.star : Icons.star_border);
      case 'Comment':
        return Text(callData.comments ?? 'No data',
            style: _textStyle, textAlign: TextAlign.center);
      case 'Status':
        return DropdownButton<String>(
          value: callData.status,
          items: ['Scheduled', 'Completed'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              callData.status = newValue!;
            });
          },
        );
      case 'Name':
        return Text(callData.name ?? 'No data',
            style: _textStyle, textAlign: TextAlign.center);
      case 'Title':
        return Text(callData.profession ?? 'No data',
            style: _textStyle, textAlign: TextAlign.center);
      case 'Company':
        return Text(callData.company ?? 'No data',
            style: _textStyle, textAlign: TextAlign.center);
      case 'Year':
        return Text(callData.startDate?.toIso8601String() ?? 'No data',
            style: _textStyle, textAlign: TextAlign.center);
      case 'Geography':
        return Text(callData.geography ?? 'No data',
            style: _textStyle, textAlign: TextAlign.center);
      case 'Angle':
        return Text(callData.angle ?? 'No data',
            style: _textStyle, textAlign: TextAlign.center);
      case 'AI match':
        return Text(callData.aiAssessment.toString(),
            style: _textStyle, textAlign: TextAlign.center);
      case 'AI analysis':
        return Text(callData.aiAnalysis ?? 'No data',
            style: _textStyle, textAlign: TextAlign.center);
      case 'Comments from network':
        return Text(callData.comments ?? 'No data',
            style: _textStyle, textAlign: TextAlign.center);
      case 'Availability':
        return Text(
          callData.availabilities?.first.start.toString() ??
              "No availabilities",
          style: _textStyle,
          textAlign: TextAlign.center,
        );
      case 'Network':
        return Text(callData.expertNetworkName ?? 'No data',
            style: _textStyle, textAlign: TextAlign.center);
      case 'Cost (1 hr)':
        return Text(callData.cost.toString(),
            style: _textStyle, textAlign: TextAlign.center);
      default:
        return Text('No data', style: _textStyle, textAlign: TextAlign.center);
    }
  }

  final TextStyle _textStyle = TextStyle(color: darkGrey);

  void exportToCSV() async {
    List<List<dynamic>> rows = [];

    // Add headers
    rows.add(header);

    // Add data
    for (var call in widget.callsList) {
      List<dynamic> row = [];
      row.add(call.favorite ? 'Yes' : 'No');
      row.add(call.comments ?? '');
      row.add(call.status ?? '');
      row.add(call.name ?? '');
      row.add(call.profession ?? '');
      row.add(call.company ?? '');
      row.add(call.startDate.toString());
      row.add(call.geography ?? '');
      row.add(call.angle ?? '');
      row.add(call.aiAssessment ?? '');
      row.add(call.aiAnalysis ?? '');
      row.add(call.comments ?? '');
      row.add(call.availabilities?.first.start.toString() ?? '');
      row.add(call.expertNetworkName ?? '');
      row.add(call.cost.toString());

      rows.add(row);
    }

    String csvData = const ListToCsvConverter().convert(rows);
    if (kIsWeb) {
      final bytes = utf8.encode(csvData);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "call_table.csv")
        ..click();
      html.Url.revokeObjectUrl(url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exported to CSV')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('CSV export is not supported on this platform')),
      );
    }
  }
}

class ExtentModel {
  final double extent;
  final bool isFixed;

  ExtentModel({required this.extent, required this.isFixed});
}
