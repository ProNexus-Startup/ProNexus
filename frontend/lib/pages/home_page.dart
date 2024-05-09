import 'package:admin/pages/components/top_menu.dart';
import 'package:admin/utils/cards/project_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin/utils/models/project.dart';
import 'package:admin/utils/global_bloc.dart';

class HomePage extends StatefulWidget {
  final String token; // Username variable
  static const routeName = '/home';

  const HomePage({Key? key, required this.token}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = Provider.of<GlobalBloc>(context);
    List<Project> projectList = globalBloc.projectList;

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(100), // Set the height of the app bar
          child: TopMenu()),
      body: ListView.builder(
        itemCount: projectList.length,
        itemBuilder: (context, index) {
          return ProjectTile(
            project: projectList[index],
            token:
                'your_token_here', // You might want to fetch this token from a secure place or state management
          );
        },
      ),
    );
  }
}
