/*import 'package:admin/utils/formatting/app_theme.dart';
import 'package:admin/utils/models/available_expert.dart';
import 'package:admin/utils/models/extent_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

class ExpertTable extends StatefulWidget {
  ExpertTable(
      {super.key, required this.experts, required this.onFavoriteChange});
  final List<AvailableExpert>? experts;
  final Function(bool, AvailableExpert) onFavoriteChange;

  @override
  State<ExpertTable> createState() => _ExpertTableState();
}

class _ExpertTableState extends State<ExpertTable> {
  late final ScrollController _verticalController = ScrollController();
  late final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    super.dispose();
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
            columnCount: 19,
            rowCount: widget.experts?.length ?? 0 + 1,
            columnBuilder: _buildColumnSpan,
            pinnedRowCount: 1,
            rowBuilder: (val) {
              return Span(
                  extent: FixedSpanExtent(val == 0 ? 100 : 150),
                  backgroundDecoration: TableSpanDecoration(
                    color: (val) % 2 == 0 && val != 0 ? Colors.grey[300] : null,
                  ));
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

    if (vicinity.row > 0 && vicinity.row <= widget.experts.length) {
      return TableViewCell(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _buildCellData(
            widget.experts[vicinity.row - 1],
            vicinity.column,
          ),
        ),
      );
    } else {
      return const TableViewCell(child: Text('No data'));
    }
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
    'Role in the decision making process?',
    'Decision making criteria?',
    'Companies purchased from?',
    'Key trends?'
  ];

  final List<ExtentModel> _columnExtents = [
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
    ExtentModel(227),
    ExtentModel(227),
    ExtentModel(247),
    ExtentModel(281),
  ];

  Widget _buildCellData(AvailableExpert expertData, int columnIndex) {
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
        return Text(expertData.comments ?? "null",
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 12));
      case 2:
        return DropdownButton<String>(
          value: expertData.status,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          iconSize: 24,
          elevation: 16,
          style: const TextStyle(color: Colors.white),
          dropdownColor:
              expertData.status == 'Available' ? Colors.green : Colors.orange,
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
                  color: value == 'Available' ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        return Text(expertData.startDate?.toIso8601String() ?? "Date",
            textAlign: TextAlign.center);
      case 7:
        return Text(expertData.geography ?? "null",
            textAlign: TextAlign.center);
      case 8:
        return Text(expertData.angle ?? "null", textAlign: TextAlign.center);
      case 9:
        return Text("${expertData.AIAssessment}%",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: expertData.AIAssessment! >= 90
                    ? labelBgColor
                    : expertData.AIAssessment! >= 70
                        ? const Color(0xffFFD600)
                        : const Color(0xffFF0000)));
      case 10:
        return Text(expertData.aiAnalysis ?? 'No assessment',
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 12));
      case 11:
        return Text(expertData.comments ?? "null",
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 12));
      case 12:
        print(
            'expert availability here: ${expertData.availabilities?.first.start}');
        print(
            'expert timzone here: ${expertData.availabilities?.first.timeZone}');
        print('expert end here: ${expertData.availabilities?.first.end}');

        return Text(
          expertData.availabilities
                  ?.map((a) =>
                      'from ${a.start!.toIso8601String()}') //to ${a.end!.toIso8601String()} (${a.timeZone})')
                  .join(',\n') ??
              'no time',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        );

      case 13:
        return Text(expertData.expertNetworkName ?? "null",
            textAlign: TextAlign.center);
      case 14:
        return Text(expertData.cost.toString(), textAlign: TextAlign.center);
      case 15:
        return Text(
            expertData.screeningQuestionsAndAnswers?[0].answer ?? 'No response',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12));
      case 16:
        return Text(
            expertData.screeningQuestionsAndAnswers?[1].answer ?? 'No response',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12));
      case 17:
        return Text(
            expertData.screeningQuestionsAndAnswers?[2].answer ?? "No response",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12));
      case 18:
        return Text(expertData.trends ?? "null",
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 12));

      default:
        return const Text('No data');
    }
  }
}
*/