import 'package:admin/pages/components/header.dart';
import 'package:admin/pages/components/sub_menu.dart';
import 'package:admin/utils/models/project.dart';
import 'package:admin/utils/persistence/global_bloc.dart';
import 'package:admin/utils/persistence/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AiMatchPage extends StatefulWidget {
  static const routeName = '/ai-match';
  final String token;

  const AiMatchPage({Key? key, required this.token}) : super(key: key);

  @override
  _AiMatchPageState createState() => _AiMatchPageState();
}

class _AiMatchPageState extends State<AiMatchPage> {
  int _selectedOption = 0;
  late List<Angle> options;

  final TextEditingController _textController = TextEditingController();

  Future<void> findAIMatchInfo() async {
    final GlobalBloc globalBloc =
        Provider.of<GlobalBloc>(context, listen: false);
    List<Project> projects = globalBloc.projectList;

    SecureStorage secureStorage = SecureStorage();
    String projectId = await secureStorage.read('projectId');

    for (var project in projects) {
      if (project.projectId == projectId) {
        options = project.angles ?? [];
      }
    }

    // Initialize the text controller with the first option's aiMatchPrompt
    if (options.isNotEmpty) {
      _textController.text = options[_selectedOption].aiMatchPrompt ?? '';
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    findAIMatchInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: TopMenu(),
      ),
      body: Column(
        children: [
          SubMenu(
            token: widget.token,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Adjust AI match by Angle',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Which angle would you like to adjust the AI match for?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              return RadioListTile<int>(
                                title: Text(options[index].name),
                                value: index,
                                groupValue: _selectedOption,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedOption = value!;
                                    _textController.text =
                                        options[_selectedOption]
                                                .aiMatchPrompt ??
                                            '';
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Adjustment to AI match for: ',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: options[_selectedOption].name,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _textController,
                            maxLines: 10,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your adjustment details here',
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Handle Cancel button press
                                },
                                child: Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Handle Send button press
                                },
                                child: Text('Send'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
