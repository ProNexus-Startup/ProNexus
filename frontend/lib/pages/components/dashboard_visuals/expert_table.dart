import 'package:admin/utils/cards/available_expert_card.dart';
import 'package:admin/utils/global_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/constants.dart';

class ExpertTable extends StatelessWidget {
  const ExpertTable({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalBloc>(builder: (context, globalBloc, child) {
      return Container(
        padding: EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columnSpacing: defaultPadding,
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
                      .where((expert) => globalBloc.applyFilters(expert))
                      .map<DataRow>((expert) =>
                          recentFileDataRow(expert, globalBloc.toggleFavorite))
                      .toList(),
                ),
              ),
            ),
          );
        }),
      );
    });
  }
}

DataRow recentFileDataRow(
    AvailableExpert expert, void Function(AvailableExpert) toggleFavorite) {
  return DataRow(
    cells: [
      DataCell(
        IconButton(
          icon: Icon(
            expert.favorite == 1 ? Icons.star : Icons.star_border,
            color: expert.favorite == 1 ? Colors.yellow : null,
          ),
          onPressed: () => toggleFavorite(expert),
        ),
      ),
      DataCell(Text(expert.name)),
      DataCell(Text(expert.title)),
      DataCell(Text(expert.company)),
      DataCell(Text('${expert.yearsAtCompany}')),
      DataCell(Text(expert.geography)),
      DataCell(Text(expert.angle)),
      DataCell(Text(expert.status)),
      DataCell(Text('${expert.AIAssessment}')),
      DataCell(Text(expert.comments)),
      DataCell(Text(expert.availability)),
    ],
  );
}
