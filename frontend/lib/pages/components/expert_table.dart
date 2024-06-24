import 'dart:convert';
import 'package:admin/pages/expert_specific_page.dart';
import 'package:admin/utils/formatting/app_theme.dart';
import 'package:admin/utils/math/project_dashboard_functions.dart';
import 'package:admin/utils/models/available_expert.dart';
import 'package:admin/utils/models/extent_model.dart';
import 'package:admin/utils/persistence/global_bloc.dart';
import 'package:admin/utils/persistence/screen_arguments.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:csv/csv.dart';
import 'dart:html' as html;

import 'package:shared_preferences/shared_preferences.dart';

class ExpertTable extends StatefulWidget {
  const ExpertTable({
    Key? key,
    required this.experts,
    required this.onFavoriteChange,
  }) : super(key: key);

  final List<AvailableExpert> experts;
  final Function(bool, AvailableExpert) onFavoriteChange;

  @override
  State<ExpertTable> createState() => ExpertTableState();
}

class ExpertTableState extends State<ExpertTable> {
  late List<String> uniqueQuestions = [];

  @override
  void initState() {
    super.initState();
    getUniqueQuestions(widget.experts);
    getTableFormatting();
  }

  void getUniqueQuestions(List<AvailableExpert> experts) {
    final Set<String> unique = {};

    for (var expert in experts) {
      if (expert.screeningQuestionsAndAnswers != null) {
        for (var question in expert.screeningQuestionsAndAnswers!) {
          unique.add(question.question);
        }
      }
    }

    uniqueQuestions = unique.toList();
  }

  List<String> stableHeader = [
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
      return Colors.red;
    } else if (value <= 66) {
      return Colors.yellow;
    } else {
      return Colors.green;
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
                      widget.experts.length,
                      (index) {
                        final expert = widget.experts[index];
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
                            _buildDataCell(expert, 0, index),
                            _buildDataCell(expert, 1, index),
                            _buildDataCell(expert, 2, index),
                            _buildDataCell(expert, 3, index),
                            _buildDataCell(expert, 4, index),
                            _buildDataCell(expert, 5, index),
                            _buildDataCell(expert, 6, index),
                            _buildDataCell(expert, 7, index),
                            _buildDataCell(expert, 8, index),
                            _buildDataCell(expert, 9, index),
                            _buildDataCell(expert, 10, index),
                            _buildDataCell(expert, 11, index),
                            _buildDataCell(expert, 12, index),
                            _buildDataCell(expert, 13, index),
                            _buildDataCell(expert, 14, index),
                            ...uniqueQuestions.map((question) =>
                                _buildQuestionDataCell(
                                    expert, question, index)),
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

  DataCell _buildDataCell(
      AvailableExpert expertData, int columnIndex, int rowIndex) {
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
                    final cellContent =
                        _getCellContent(expertData, columnIndex);
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

                    final expertId = widget.experts[rowIndex].expertId;
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
            child: _buildCellContent(expertData, columnIndex),
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

  Widget _buildCellContent(AvailableExpert expertData, int columnIndex) {
    switch (columnIndex) {
      case 0:
        return InkWell(
          onTap: () {
            widget.onFavoriteChange(!expertData.favorite, expertData);
          },
          child: Center(
            child: (expertData.favorite)
                ? Icon(
                    Icons.star,
                    color: Colors.amber,
                  )
                : Icon(
                    Icons.star_border_outlined,
                    color: Colors.amber,
                  ),
          ),
        );
      case 1:
        return Text(
          expertData.comments ?? 'No data',
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      case 2:
        return Container(
          color: _getStatusColor(expertData.status),
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: DropdownButton<String>(
            value: expertData.status,
            items: [
              'Available',
              'Going to schedule',
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                expertData.status = newValue!;
              });
            },
          ),
        );
      case 3:
        return Text(
          expertData.name,
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      case 4:
        return Text(
          expertData.profession,
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      case 5:
        return Text(
          expertData.company,
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      case 6:
        return Text(
          (expertData.startDate?.toIso8601String() ?? ''),
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      case 7:
        return Text(
          expertData.geography ?? 'No data',
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      case 8:
        return Text(
          expertData.angle ?? 'No data',
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      case 9:
        return Text(
          expertData.aiAssessment.toString(),
          style: TextStyle(
            color: _getAiMatchColor(expertData.aiAssessment ?? 0),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left,
        );
      case 10:
        return Text(
          expertData.aiAnalysis ?? 'No data',
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      case 11:
        return Text(
          expertData.comments ?? 'No data',
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      case 12:
        return Text(
          expertData.availabilities?.first.start.toString() ??
              'No availabilities',
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      case 13:
        return Text(
          expertData.expertNetworkName ?? 'No data',
          style: _textStyle,
          textAlign: TextAlign.left,
        );
      case 14:
        return Text(
          expertData.cost.toString(),
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
      case 'Available':
        return mustardYellow;
      case 'Going to schedule':
        return primaryBlue;
      default:
        return Colors.transparent;
    }
  }

  String _getCellContent(AvailableExpert expertData, int columnIndex) {
    switch (columnIndex) {
      case 0:
        return expertData.favorite ? 'Yes' : 'No';
      case 1:
        return expertData.comments ?? '';
      case 2:
        return expertData.status ?? '';
      case 3:
        return expertData.name;
      case 4:
        return expertData.profession;
      case 5:
        return expertData.company;
      case 6:
        return expertData.startDate?.toIso8601String() ?? '';
      case 7:
        return expertData.geography ?? '';
      case 8:
        return expertData.angle ?? '';
      case 9:
        return expertData.aiAssessment.toString();
      case 10:
        return expertData.aiAnalysis ?? '';
      case 11:
        return expertData.comments ?? '';
      case 12:
        return expertData.availabilities?.first.start.toString() ?? '';
      case 13:
        return expertData.expertNetworkName ?? '';
      case 14:
        return expertData.cost.toString();
      default:
        return 'No data';
    }
  }

  DataCell _buildQuestionDataCell(
      AvailableExpert expertData, String question, int rowIndex) {
    final answer = expertData.screeningQuestionsAndAnswers
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
    List<List<dynamic>> rows = [];

    // Define header if not defined
    List<String> header = [
      'Favorite',
      'Comments',
      'Status',
      'Name',
      'Profession',
      'Company',
      'Start Date',
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

    for (var expert in widget.experts) {
      List<dynamic> row = [];
      row.add(expert.favorite ? 'Yes' : 'No');
      row.add(expert.comments ?? '');
      row.add(expert.status ?? '');
      row.add(expert.name);
      row.add(expert.profession);
      row.add(expert.company);
      row.add(expert.startDate.toString());
      row.add(expert.geography ?? '');
      row.add(expert.angle ?? '');
      row.add(expert.aiAssessment.toString());
      row.add(expert.aiAnalysis ?? '');
      row.add(expert.comments ?? '');
      row.add(expert.availabilities?.toString() ?? '');
      row.add(expert.expertNetworkName ?? '');
      row.add(expert.cost.toString());

      for (var question in uniqueQuestions) {
        var answer = expert.screeningQuestionsAndAnswers
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
      ..setAttribute("download", "expert_table.csv")
      ..click();
    html.Url.revokeObjectUrl(url);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exported to CSV')),
    );
  }
}
