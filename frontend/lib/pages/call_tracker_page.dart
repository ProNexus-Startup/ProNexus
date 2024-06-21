import 'package:admin/pages/components/call_table.dart';
import 'package:admin/pages/components/cards/action_card.dart';
import 'package:admin/pages/components/sub_menu.dart';
import 'package:admin/pages/components/header.dart';
import 'package:admin/utils/formatting/app_theme.dart';
import 'package:admin/utils/persistence/global_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CallTrackerDashboard extends StatefulWidget {
  static const routeName = '/calls';

  final String token;

  const CallTrackerDashboard({Key? key, required this.token}) : super(key: key);

  @override
  _CallTrackerDashboardState createState() => _CallTrackerDashboardState();
}

class _CallTrackerDashboardState extends State<CallTrackerDashboard> {
  bool isAnySelected = false;
  final GlobalKey<CallTableState> _callTableKey = GlobalKey<CallTableState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final GlobalBloc globalBloc =
        Provider.of<GlobalBloc>(context, listen: false);
    globalBloc.onUserLogin(widget.token);
  }

  void updateSelection(bool isSelected) {
    setState(() {
      isAnySelected = isSelected;
    });
  }

  void exportToCSV(BuildContext context) {
    final state = _callTableKey.currentState;
    if (state != null) {
      state.exportToCSV();
    } else {
      print("Could not find ExpertTable state.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalBloc>(builder: (context, globalBloc, child) {
      return Scaffold(
          backgroundColor: Colors.white,
          body: Column(children: [
            TopMenu(),
            SubMenu(
              token: widget.token,
            ),
            Row(
              children: [
                const SizedBox(width: 128),
                const ActionCard(
                  title: 'Send unscheduled invites to team',
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  hasBorder: false,
                ),
                const SizedBox(width: 50),
                ActionCard(
                  title: 'Search Live Projects',
                  leadingIcon: Image.asset('assets/icons/search.png',
                      height: 24, width: 24),
                ),
                const Spacer(),
                ElevatedButton(
                  child: Text('Download Experts'),
                  onPressed: () {
                    exportToCSV(context);
                  },
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 26),
            Expanded(child: CallTable(callsList: globalBloc.callList)),
          ]));
    });
  }
}
