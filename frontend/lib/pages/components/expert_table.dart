import 'dart:convert';
import 'package:admin/pages/expert_specific_page.dart';
import 'package:admin/utils/formatting/app_theme.dart';
import 'package:admin/utils/math/project_dashboard_functions.dart';
import 'package:admin/utils/models/available_expert.dart';
import 'package:admin/utils/models/extent_model.dart';
import 'package:admin/utils/persistence/global_bloc.dart';
import 'package:admin/utils/persistence/screen_arguments.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'package:csv/csv.dart';
import 'dart:html' as html; // Only needed for web

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
  late final ScrollController _verticalController = ScrollController();
  late final ScrollController _horizontalController = ScrollController();
  late List<String> uniqueQuestions = [];

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

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
          child: TableView.builder(
            cellBuilder: _buildCell,
            columnCount: header.length,
            rowCount: widget.experts.length + 1,
            columnBuilder: _buildColumnSpan,
            pinnedRowCount: 1,
            rowBuilder: (val) {
              return Span(
                extent: FixedSpanExtent(4 * 20.0), // 4 lines tall
                backgroundDecoration: TableSpanDecoration(
                  color: val % 2 == 0 && val != 0 ? Colors.grey[300] : null,
                ),
              );
            },
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  header[vicinity.column],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (header[vicinity.column] == 'AI match') ...[
                const SizedBox(width: 5),
                Image.asset('assets/icons/pencil.png', height: 24, width: 24)
              ]
            ],
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

                    final expertId = widget.experts[vicinity.row - 1].expertId;
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
                widget.experts[vicinity.row - 1],
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

  TableSpan _buildRowSpan(int index) {
    final TableSpanDecoration decoration = TableSpanDecoration(
      color: index.isEven ? Colors.purple[100] : null,
      border: const TableSpanBorder(
        trailing: BorderSide(
          width: 3,
        ),
      ),
    );

    switch (index % 3) {
      case 0:
        return TableSpan(
          backgroundDecoration: decoration,
          extent: const FixedTableSpanExtent(100),
          recognizerFactories: <Type, GestureRecognizerFactory>{
            TapGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
              () => TapGestureRecognizer(),
              (TapGestureRecognizer t) =>
                  t.onTap = () => print('Tap row $index'),
            ),
          },
        );
      case 1:
        return TableSpan(
          backgroundDecoration: decoration,
          extent: const FixedTableSpanExtent(65),
          cursor: SystemMouseCursors.click,
        );
      case 2:
        return TableSpan(
          backgroundDecoration: decoration,
          extent: const FractionalTableSpanExtent(0.15),
        );
    }
    throw AssertionError(
      'This should be unreachable, as every index is accounted for in the '
      'switch clauses.',
    );
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

  void getTableFormatting() {
    header = List.from(stableHeader)..addAll(uniqueQuestions);
    int uniqueQuestionsLength = uniqueQuestions.length;

    _columnExtents = _columnExtentsBase;

    for (int i = 0; i < uniqueQuestionsLength; i++) {
      _columnExtents.add(ExtentModel(200));
    }
  }

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

  Widget _buildCellData(AvailableExpert expertData, int columnIndex) {
    if (columnIndex < stableHeader.length) {
      switch (columnIndex) {
        case 0:
          return Column(
            children: [
              InkWell(
                  onTap: () {
                    widget.onFavoriteChange(!expertData.favorite, expertData);
                  },
                  child: Image.asset(
                      (expertData.favorite)
                          ? 'assets/icons/star_filled.png'
                          : 'assets/icons/star_outline.png',
                      height: 24,
                      width: 24)),
            ],
          );
        case 1:
          return _buildEditableCommentCell(expertData);
        case 2:
          return DropdownButton<String>(
            value: expertData.status,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            iconSize: 24,
            elevation: 16,
            style: const TextStyle(color: Colors.white),
            dropdownColor: Colors.white,
            onChanged: (String? newValue) {
              setState(() {
                expertData.status = newValue!;
              });
            },
            items: <String>['Available', 'Going to schedule']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: value == 'Available' ? Colors.green : Colors.blue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              );
            }).toList(),
          );
        case 3:
          return Text(expertData.name, textAlign: TextAlign.center);
        case 4:
          return Text(expertData.profession, textAlign: TextAlign.center);
        case 5:
          return Text(expertData.company, textAlign: TextAlign.center);
        case 6:
          return Text(expertData.startDate.toString(),
              textAlign: TextAlign.center);
        case 7:
          return Text(expertData.geography ?? "No geography found",
              textAlign: TextAlign.center);
        case 8:
          return Text(expertData.angle ?? "No angle found",
              textAlign: TextAlign.center);
        case 9:
          return Text("${expertData.aiAssessment}%",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: expertData.aiAssessment! >= 90
                      ? greenButtonColor
                      : expertData.aiAssessment! >= 70
                          ? const Color(0xffFFD600)
                          : const Color(0xffFF0000)));
        case 10:
          return Text(expertData.aiAnalysis ?? "0",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12));
        case 11:
          return Text(expertData.comments ?? "No comments",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12));
        case 12:
          return Text(
              expertData.availabilities?.first.start.toString() ??
                  "No availabilities",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12));
        case 13:
          return Text(expertData.expertNetworkName ?? 'No expert network',
              textAlign: TextAlign.center);
        case 14:
          return Text(expertData.cost.toString(), textAlign: TextAlign.center);
        default:
          return const Text('No data');
      }
    } else {
      final questionIndex = columnIndex - stableHeader.length;
      final question = uniqueQuestions[questionIndex];
      final answer = expertData.screeningQuestionsAndAnswers
              ?.firstWhere(
                (q) => q.question == question,
              )
              .answer ??
          "No response";

      return Text(answer,
          textAlign: TextAlign.center, style: const TextStyle(fontSize: 12));
    }
  }

  Widget _buildEditableCommentCell(AvailableExpert expertData) {
    TextEditingController _controller =
        TextEditingController(text: expertData.comments);

    return EditableText(
      controller: _controller,
      focusNode: FocusNode(),
      style: const TextStyle(color: Colors.black, fontSize: 12),
      cursorColor: Colors.blue,
      backgroundCursorColor: Colors.grey,
      onSubmitted: (newValue) {
        setState(() {
          expertData.comments = newValue;
        });
      },
    );
  }

  String _getCellContent(TableVicinity vicinity) {
    if (vicinity.row == 0) {
      return header[vicinity.column];
    }

    final expertData = widget.experts[vicinity.row - 1];
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

  void exportToCSV() async {
    List<List<dynamic>> rows = [];

    // Add headers
    rows.add(header);

    // Add data
    for (var expert in widget.experts) {
      List<dynamic> row = [];
      row.add(expert.favorite ? 'Yes' : 'No');
      row.add(expert.comments ?? '');
      row.add(expert.status);
      row.add(expert.name);
      row.add(expert.profession);
      row.add(expert.company);
      row.add(expert.startDate.toString());
      row.add(expert.geography ?? '');
      row.add(expert.angle ?? '');
      row.add(expert.aiAssessment?.toString() ?? '');
      row.add(expert.aiAnalysis ?? '');
      row.add(expert.comments ?? '');
      row.add(expert.availabilities?.first.start.toString() ?? '');
      row.add(expert.expertNetworkName ?? '');
      row.add(expert.cost.toString());

      for (var question in uniqueQuestions) {
        var answer = expert.screeningQuestionsAndAnswers
                ?.firstWhere((q) => q.question == question)
                .answer ??
            '';
        row.add(answer);
      }

      rows.add(row);
    }

    String csvData = const ListToCsvConverter().convert(rows);
    if (kIsWeb) {
      final bytes = utf8.encode(csvData);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      // ignore: unused_local_variable
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "expert_table.csv")
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
