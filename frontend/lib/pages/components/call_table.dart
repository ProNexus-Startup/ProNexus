import 'dart:convert';
import 'package:admin/pages/expert_specific_page.dart';
import 'package:admin/utils/formatting/app_theme.dart';
import 'package:admin/utils/math/project_dashboard_functions.dart';
import 'package:admin/utils/models/available_expert.dart';
import 'package:admin/utils/models/call_tracker.dart';
import 'package:admin/utils/models/extent_model.dart';
import 'package:admin/utils/persistence/global_bloc.dart';
import 'package:admin/utils/persistence/screen_arguments.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:csv/csv.dart';
import 'dart:html' as html;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CallTable extends StatefulWidget {
  const CallTable({
    Key? key,
    required this.calls,
    required this.onFavoriteChange,
  }) : super(key: key);

  final List<CallTracker> calls;
  final Function(bool, CallTracker) onFavoriteChange;

  @override
  State<CallTable> createState() => CallTableState();
}

class CallTableState extends State<CallTable> {
  late List<String> uniqueQuestions = [];

  @override
  void initState() {
    super.initState();
    getUniqueQuestions(widget.calls);
    getTableFormatting();
  }

  void getUniqueQuestions(List<CallTracker> calls) {
    final Set<String> unique = {};

    for (var call in calls) {
      if (call.screeningQuestionsAndAnswers != null) {
        for (var question in call.screeningQuestionsAndAnswers!) {
          unique.add(question.question);
        }
      }
    }

    uniqueQuestions = unique.toList();
  }

  List<String> stableHeader = [
    'Invite Sent to Team',
    'Quote Attribution',
    'Rating',
    'Comment',
    'Status',
    'Name',
    'Date',
    'Length',
    'Time',
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

  List<String> header = [];
  List<ExtentModel> _columnExtents = [];

  final List<ExtentModel> _columnExtentsBase = [
    ExtentModel(73),
    ExtentModel(182),
    ExtentModel(175),
    ExtentModel(126),
    ExtentModel(126),
    ExtentModel(126),
    ExtentModel(126),
    ExtentModel(126),
    ExtentModel(126),
    ExtentModel(126),
    ExtentModel(97),
    ExtentModel(176),
    ExtentModel(235),
    ExtentModel(235),
    ExtentModel(146),
    ExtentModel(146),
    ExtentModel(146),
  ];

  void getTableFormatting() {
    header = List.from(stableHeader)..addAll(uniqueQuestions);
    int uniqueQuestionsLength = uniqueQuestions.length;

    _columnExtents = List.from(_columnExtentsBase);

    for (int i = 0; i < uniqueQuestionsLength; i++) {
      _columnExtents.add(ExtentModel(200));
    }
  }

  Widget _buildHeaderRow() {
    return Row(
      children: header.map((title) {
        return Flexible(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              textAlign: TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getAiMatchColor(int value) {
    if (value <= 33) {
      return redColor;
    } else if (value <= 66) {
      return mustardYellow;
    } else {
      return greenButtonColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: header.map((title) {
                      return DataColumn(
                        label: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                            title,
                            textAlign: TextAlign.left,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      );
                    }).toList(),
                    rows: List<DataRow>.generate(
                      widget.calls.length,
                      (index) {
                        final call = widget.calls[index];
                        final isGrey = index % 2 == 0;
                        final rowColor =
                            isGrey ? Colors.grey[200] : Colors.white;
                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.08);
                            }
                            return rowColor;
                          }),
                          cells: [
                            _buildDataCell(call, 0, index),
                            _buildDataCell(call, 1, index),
                            _buildDataCell(call, 2, index),
                            _buildDataCell(call, 3, index),
                            _buildDataCell(call, 4, index),
                            _buildDataCell(call, 5, index),
                            _buildDataCell(call, 6, index),
                            _buildDataCell(call, 7, index),
                            _buildDataCell(call, 8, index),
                            _buildDataCell(call, 9, index),
                            _buildDataCell(call, 10, index),
                            _buildDataCell(call, 11, index),
                            _buildDataCell(call, 12, index),
                            _buildDataCell(call, 13, index),
                            _buildDataCell(call, 14, index),
                            _buildDataCell(call, 15, index),
                            _buildDataCell(call, 16, index),
                            _buildDataCell(call, 17, index),
                            _buildDataCell(call, 18, index),
                            _buildDataCell(call, 19, index),
                            ...uniqueQuestions.map((question) =>
                                _buildQuestionDataCell(call, question, index)),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataCell _buildDataCell(CallTracker callData, int columnIndex, int rowIndex) {
    return DataCell(
      GestureDetector(
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
                    final cellContent = _getCellContent(callData, columnIndex);
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

                    final callId = widget.calls[rowIndex].id;
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString('call_string', callId);
                    await Navigator.pushNamed(
                      context,
                      ExpertSpecificPage.routeName,
                      arguments: ScreenArguments(globalBloc.currentUser.token!),
                    );
                    Navigator.of(context).pop(); // Close the menu
                  },
                ),
              ),
              if (header[columnIndex] == 'Angle')
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
        child: Container(
          constraints: BoxConstraints(maxHeight: 60),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: _buildCellContent(callData, columnIndex),
          ),
        ),
      ),
    );
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

  Widget _buildCellContent(CallTracker callData, int columnIndex) {
    switch (columnIndex) {
      case 0:
        return GestureDetector(
          onTap: () {
            setState(() {
              callData.inviteSent = !callData.inviteSent;
            });
          },
          child: Center(
            child: callData.inviteSent
                ? Image.asset(
                    'icons/user_check.png',
                    height: 24,
                    width: 24,
                  )
                : Text('No'),
          ),
        );

      case 1:
        return Text(
          '${callData.profession} at ${callData.company}',
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      case 2:
        return RatingBar.builder(
          initialRating: (callData.rating ?? 0) /
              2, // Converting rating from 1-10 to 0.5-5.0
          minRating: 0.5,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
            setState(() {
              callData.rating =
                  (rating * 2).toInt(); // Convert back to 1-10 scale
            });
          },
        );
      case 3:
        return Text(
          callData.comments ?? 'No data',
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      case 4:
        return Container(
          color: _getStatusColor(callData.status),
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: DropdownButton<String>(
            value: callData.status,
            items: {'Scheduled', 'Completed'}.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                callData.status = newValue!;
              });
            },
          ),
        );
      case 5:
        return Text(
          callData.name,
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      case 6:
        return Text(
          (callData.startDate?.toIso8601String() ?? ''),
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      case 7:
        if (callData.meetingStartDate != null &&
            callData.meetingEndDate != null) {
          return Text(
            '${callData.meetingEndDate!.difference(callData.meetingStartDate!)} minutes',
            style: _textStyle,
            textAlign: TextAlign.left,
          );
        } else {
          return Text('Missing meeting date information');
        }

      case 8:
        return Text(
          (callData.startDate?.toIso8601String() ?? '').substring(11, 16),
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      case 9:
        return Text(
          callData.profession,
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      case 10:
        return Text(
          callData.company,
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      case 11:
        return Text(
          (callData.startDate?.year.toString() ?? ''),
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      case 12:
        return Text(
          callData.geography ?? 'No data',
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      case 13:
        return Text(
          callData.angle ?? 'No data',
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      case 14:
        return Text(
          callData.aiAssessment.toString(),
          style: TextStyle(
            color: _getAiMatchColor(callData.aiAssessment ?? 0),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left,
        );
      case 15:
        return Text(
          callData.aiAnalysis ?? 'No data',
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      case 16:
        return Text(
          callData.comments ?? 'No data',
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      case 17:
        return Text(
          callData.availabilities?.first.start.toString() ??
              'No availabilities',
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      case 18:
        return Text(
          callData.expertNetworkName ?? 'No data',
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      case 19:
        return Text(
          callData.cost.toString(),
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      default:
        return Text(
          'No data',
          style: _textStyle,
          textAlign: TextAlign.left,
        );
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Scheduled':
        return mustardYellow;
      case 'Completed':
        return primaryBlue;
      default:
        return Colors.transparent;
    }
  }

  String _getCellContent(CallTracker callData, int columnIndex) {
    switch (columnIndex) {
      case 0:
        return callData.inviteSent ? 'Yes' : 'No';
      case 1:
        return '${callData.profession} at ${callData.company}';
      case 2:
        return callData.favorite ? 'Yes' : 'No';
      case 3:
        return callData.comments ?? '';
      case 4:
        return callData.status ?? '';
      case 5:
        return callData.name;
      case 6:
        return callData.startDate?.toIso8601String() ?? '';
      case 7:
        if (callData.meetingStartDate != null &&
            callData.meetingEndDate != null) {
          return '${callData.meetingEndDate!.difference(callData.meetingStartDate!)} minutes';
        } else {
          return 'Missing meeting date information';
        }
      case 8:
        return (callData.startDate?.toIso8601String() ?? '').substring(11, 16);
      case 9:
        return callData.profession;
      case 10:
        return callData.company;
      case 11:
        return callData.startDate?.year.toString() ?? '';
      case 12:
        return callData.geography ?? '';
      case 13:
        return callData.angle ?? '';
      case 14:
        return callData.aiAssessment.toString();
      case 15:
        return callData.aiAnalysis ?? '';
      case 16:
        return callData.comments ?? '';
      case 17:
        return callData.availabilities?.first.start.toString() ?? '';
      case 18:
        return callData.expertNetworkName ?? '';
      case 19:
        return callData.cost.toString();
      default:
        return 'No data';
    }
  }

  DataCell _buildQuestionDataCell(
      CallTracker callData, String question, int rowIndex) {
    final answer = callData.screeningQuestionsAndAnswers
            ?.firstWhere((q) => q.question == question,
                orElse: () => Question(question: '', answer: 'N/A'))
            .answer ??
        'No response';
    return DataCell(
      GestureDetector(
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
                    Clipboard.setData(ClipboardData(text: answer));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied to clipboard: $answer'),
                      ),
                    );
                    Navigator.of(context).pop(); // Close the menu
                  },
                ),
              ),
            ],
          );
        },
        child: Container(
          constraints: BoxConstraints(maxHeight: 60),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Text(
              answer,
              style: _textStyle,
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
    );
  }

  final TextStyle _textStyle = TextStyle(color: Colors.black);

  void exportToCSV() async {
    print('exportToCSV called');
    List<List<dynamic>> rows = [];

    // Define header if not defined
    List<String> header = [
      'Invite Sent to Team',
      'Quote Attribution',
      'Rating',
      'Comments',
      'Status',
      'Name',
      'Date',
      'Length',
      'Time',
      'Profession',
      'Company',
      'Year',
      'Geography',
      'Angle',
      'AI Assessment',
      'AI Analysis',
      'Comments',
      'Availability Start',
      'Expert Network Name',
      'Cost'
    ];

    // Add unique questions to the header
    header.addAll(uniqueQuestions);

    rows.add(header);

    for (var call in widget.calls) {
      String callLength = '';
      if (call.meetingStartDate != null && call.meetingEndDate != null) {
        callLength =
            '${call.meetingEndDate!.difference(call.meetingStartDate!)} minutes';
      } else {
        callLength = 'Missing meeting date information';
      }

      List<dynamic> row = [];
      row.add(call.inviteSent ? 'Yes' : 'No');
      row.add('${call.profession} at ${call.company}');
      row.add(call.favorite ? 'Yes' : 'No');
      row.add(call.comments ?? '');
      row.add(call.status ?? '');
      row.add(call.name);
      row.add(call.startDate.toString());
      row.add(callLength.toString());
      row.add((call.startDate?.toIso8601String() ?? '').substring(11, 16));
      row.add(call.profession);
      row.add(call.company);
      row.add(call.startDate?.year.toString() ?? '');
      row.add(call.geography ?? '');
      row.add(call.angle ?? '');
      row.add(call.aiAssessment.toString());
      row.add(call.aiAnalysis ?? '');
      row.add(call.comments ?? '');
      row.add(call.availabilities?.first.start.toString() ?? '');
      row.add(call.expertNetworkName ?? '');
      row.add(call.cost.toString());

      for (var question in uniqueQuestions) {
        var answer = call.screeningQuestionsAndAnswers
                ?.firstWhere((q) => q.question == question,
                    orElse: () => Question(question: 'question', answer: 'N/A'))
                .answer ??
            '';
        row.add(answer);
      }

      rows.add(row);
    }

    String csvData = const ListToCsvConverter().convert(rows);
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
  }
}
