/*import 'package:admin/utils/global_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/constants.dart';

class Chart extends StatelessWidget {
  const Chart({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 70,
              startDegreeOffset: -90,
              sections: makePie(globalBloc),
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: defaultPadding),
                Text(
                  "",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 0.5,
                      ),
                ),
                //Text("of 128GB")
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<PieChartSectionData> makePie(bloc) {
  int total = bloc.typeMap["Consulting"] +
      bloc.typeMap["Finance"] +
      bloc.typeMap["Job Stuff"] +
      bloc.typeMap["Other Role"];

  List<PieChartSectionData> paiChartSelectionData = [
    PieChartSectionData(
      value: 360 * bloc.typeMap["Finance"] / total,
      showTitle: false,
      radius: 25,
    ),
    PieChartSectionData(
      color: Color(0xFF26E5FF),
      value: 360 * bloc.typeMap["Consulting"] / total,
      showTitle: false,
      radius: 22,
    ),
    PieChartSectionData(
      color: Color(0xFFFFCF26),
      value: 360 * bloc.typeMap["Job Stuff"] / total,
      showTitle: false,
      radius: 19,
    ),
    PieChartSectionData(
      color: Color(0xFFEE2727),
      value: 360 * bloc.typeMap["Other Role"] / total,
      showTitle: false,
      radius: 16,
    ),
    PieChartSectionData(
      value: 25,
      showTitle: false,
      radius: 13,
    ),
  ];
  return paiChartSelectionData;
}*/
