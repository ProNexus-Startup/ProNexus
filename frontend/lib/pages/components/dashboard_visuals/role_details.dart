/*import 'package:admin/utils/global_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/constants.dart';
import 'chart.dart';
import '../../../utils/cards/role_card.dart';

class RoleTypes extends StatelessWidget {
  const RoleTypes({
    Key? key,
  }) : super(key: key);
//change the below so it it has a role card for each role type
  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Role Types",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: defaultPadding),
          Chart(),
          RoleCard(
            svgSrc: "assets/icons/Documents.svg",
            title: "Finance",
            amountOfFiles: globalBloc.typeMap["Finance"].toString(),
          ),
          RoleCard(
            svgSrc: "assets/icons/media.svg",
            title: "Consulting",
            amountOfFiles: globalBloc.typeMap["Consulting"].toString(),
          ),
          RoleCard(
            svgSrc: "assets/icons/folder.svg",
            title: "Job Stuff",
            amountOfFiles: globalBloc.typeMap["Job Stuff"].toString(),
          ),
          RoleCard(
            svgSrc: "assets/icons/unknown.svg",
            title: "Other Role",
            amountOfFiles: globalBloc.typeMap["Other Role"].toString(),
          ),
        ],
      ),
    );
  }
}
*/