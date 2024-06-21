import 'package:admin/pages/components/header.dart';
import 'package:admin/pages/components/steps_menu.dart';
import 'package:admin/pages/home_page.dart';
import 'package:admin/utils/models/project.dart';
import 'package:admin/utils/persistence/global_bloc.dart';
import 'package:admin/utils/persistence/screen_arguments.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../utils/BaseAPI.dart';

class ProjectCreationPage extends StatefulWidget {
  static const routeName = '/project-creation';
  final String token;

  const ProjectCreationPage({Key? key, required this.token}) : super(key: key);

  @override
  _ProjectCreationPageState createState() => _ProjectCreationPageState();
}

class _ProjectCreationPageState extends State<ProjectCreationPage> {
  int _selectedIndex = 0;

  void _cancel() {
    Navigator.of(context).pop();
  }

  void _goBack() {
    if (_selectedIndex > 0) {
      setState(() {
        _selectedIndex--;
      });
    }
  }

  void _nextStep() {
    if (_selectedIndex < 4) {
      setState(() {
        _selectedIndex++;
      });
    }
  }

  void _launchProject() {
    final GlobalBloc globalBloc =
        Provider.of<GlobalBloc>(context, listen: false);

    final AuthAPI _authAPI = AuthAPI();

    final projectDetails = Provider.of<ProjectDetails>(context, listen: false);
    Project newProject = Project(
        name: projectDetails.projectTitle,
        startDate: projectDetails.projectStartDate!,
        endDate: projectDetails.projectEndDate,
        organizationId: globalBloc.currentUser.organizationId,
        callsCompleted: 0,
        status: 'Open',
        targetCompany: projectDetails.targetCompany,
        doNotContact: projectDetails.dncCompanies,
        regions: projectDetails.countriesRegion,
        scope: projectDetails.projectScope,
        type: projectDetails.projectType,
        estimatedCalls: projectDetails.estimatedCalls,
        budgetCap: projectDetails.budgetCap,
        colleagues: projectDetails.colleagues);

    _authAPI.makeProject(widget.token, newProject);
    Navigator.pushNamed(
      context,
      HomePage.routeName,
      arguments: ScreenArguments(widget.token),
    );
  }

  void _handleStepChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectDetails>(
      builder: (context, projectDetails, child) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(100),
            child:
                TopMenu(), // Ensure TopMenu provides PreferredSizeWidget or a fixed height
          ),
          body: Column(
            children: [
              SizedBox(height: 40),
              SizedBox(
                width: 558,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    child: StepperLayout(
                      initialIndex: _selectedIndex,
                      onStepChanged: _handleStepChanged,
                    ),
                    width: MediaQuery.of(context).size.width * .85,
                  ),
                ),
              ),
              SizedBox(height: 50),
              Expanded(
                child: _buildContent(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _selectedIndex == 0 ? _cancel : _goBack,
                      child: Text(_selectedIndex == 0 ? 'Cancel' : 'Go Back'),
                    ),
                    ElevatedButton(
                      onPressed:
                          _selectedIndex == 3 ? _launchProject : _nextStep,
                      child: Text(
                          _selectedIndex == 3 ? 'Launch Project' : 'Next Step'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100.0),
          child: Details(),
        );
      case 1:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100.0),
          child: AngleTable(),
        );
      case 2:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100.0),
          child: ColleagueTable(),
        );
      case 3:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100.0),
          child: AngleFormatter(),
        );
      default:
        return Center(child: Text('Something went wrong'));
    }
  }
}

class ProjectDetails with ChangeNotifier {
  String projectTitle = '';
  String targetCompany = '';
  List<String> countriesRegion = [];
  List<String> dncCompanies = [];
  String projectScope = '';
  String projectType = '';
  String caseCode = '';
  double budgetCap = 0;
  int estimatedCalls = 0;
  DateTime? projectStartDate;
  DateTime? projectEndDate;
  List<Angle> angles = [];
  List<Colleague> colleagues = [];

  void updateProjectTitle(String title) {
    projectTitle = title;
    notifyListeners();
  }
}

class Details extends StatefulWidget {
  @override
  _CreateDetailsState createState() => _CreateDetailsState();
}

class _CreateDetailsState extends State<Details> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _projectTitleController;
  late TextEditingController _targetCompanyController;
  List<String> _regions = [];
  late TextEditingController _regionController;
  List<String> _dncCompanies = [];
  late TextEditingController _dncCompanyController;

  late TextEditingController _projectScopeController;
  late TextEditingController _projectTypeController;
  late TextEditingController _caseCodeController;

  DateTime? _projectStartDate;
  DateTime? _projectEndDate;

  @override
  void initState() {
    super.initState();
    _projectTitleController = TextEditingController();
    _targetCompanyController = TextEditingController();
    _regionController = TextEditingController();
    _dncCompanyController = TextEditingController();
    _projectScopeController = TextEditingController();
    _projectTypeController = TextEditingController();
    _caseCodeController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final projectDetails = Provider.of<ProjectDetails>(context, listen: false);

    _projectTitleController.text = projectDetails.projectTitle;
    _targetCompanyController.text = projectDetails.targetCompany;
    _projectScopeController.text = projectDetails.projectScope;
    _projectTypeController.text = projectDetails.projectType;
    _caseCodeController.text = projectDetails.caseCode;
    _projectStartDate = projectDetails.projectStartDate;
    _projectEndDate = projectDetails.projectEndDate;
  }

  @override
  void dispose() {
    _projectTitleController.dispose();
    _targetCompanyController.dispose();
    _projectScopeController.dispose();
    _projectTypeController.dispose();
    _caseCodeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null &&
        picked != (isStartDate ? _projectStartDate : _projectEndDate)) {
      setState(() {
        if (isStartDate) {
          _projectStartDate = picked;
          Provider.of<ProjectDetails>(context, listen: false).projectStartDate =
              picked;
        } else {
          _projectEndDate = picked;
          Provider.of<ProjectDetails>(context, listen: false).projectEndDate =
              picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectDetails = Provider.of<ProjectDetails>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Project',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 25),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: ListView(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Project Title',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextFormField(
                                        controller: _projectTitleController,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText:
                                              'Please enter project title',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter project title';
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          projectDetails.targetCompany = value;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Target Company',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextFormField(
                                        controller: _targetCompanyController,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText:
                                              'Please enter target company',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a target company';
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          projectDetails.targetCompany = value;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Relevant Regions',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextFormField(
                                        controller: _regionController,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText:
                                              'Please enter relevant regions',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter relevant regions';
                                          }
                                          return null;
                                        },
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (_regionController
                                              .text.isNotEmpty) {
                                            setState(() {
                                              _regions
                                                  .add(_regionController.text);
                                              _regionController.clear();
                                            });
                                          }
                                        },
                                        child: Text('Add Region'),
                                      ),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: _regions.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            title: Text(_regions[index]),
                                            trailing: IconButton(
                                              icon: Icon(Icons.delete),
                                              onPressed: () {
                                                setState(() {
                                                  _regions.removeAt(index);
                                                });
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Do not contact companies',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextFormField(
                                        controller: _dncCompanyController,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText:
                                              'Please enter DNC companies',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter DNC companies';
                                          }
                                          return null;
                                        },
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (_dncCompanyController
                                              .text.isNotEmpty) {
                                            setState(() {
                                              _dncCompanies.add(
                                                  _dncCompanyController.text);
                                              _dncCompanyController.clear();
                                            });
                                          }
                                        },
                                        child: Text('Add DNC Company'),
                                      ),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: _dncCompanies.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            title: Text(_dncCompanies[index]),
                                            trailing: IconButton(
                                              icon: Icon(Icons.delete),
                                              onPressed: () {
                                                setState(() {
                                                  _dncCompanies.removeAt(index);
                                                });
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Project Scope',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextFormField(
                                  controller: _projectScopeController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Please enter project scope',
                                  ),
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter project scope';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    projectDetails.projectScope = value;
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Project Type',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextFormField(
                                        controller: _projectTypeController,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'Please enter project type',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter project type';
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          projectDetails.projectType = value;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Case Code',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextFormField(
                                        controller: _caseCodeController,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'Please enter case code',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter case code';
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          projectDetails.caseCode = value;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Project Start Date',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextFormField(
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: _projectStartDate == null
                                              ? 'Select Start Date'
                                              : DateFormat.yMd()
                                                  .format(_projectStartDate!),
                                        ),
                                        onTap: () => _selectDate(context, true),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Project End Date',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextFormField(
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: _projectEndDate == null
                                              ? 'Select End Date'
                                              : DateFormat.yMd()
                                                  .format(_projectEndDate!),
                                        ),
                                        onTap: () =>
                                            _selectDate(context, false),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Estimated Number of calls',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextFormField(
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText:
                                              'Please enter the estimated number of calls',
                                        ),
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter the estimated number of calls';
                                          }
                                          if (int.tryParse(value) == null) {
                                            return 'Please enter a valid number';
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          projectDetails.estimatedCalls =
                                              int.tryParse(value) ?? 0;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Budget Cap for project',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextFormField(
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText:
                                              'Please enter the budget cap',
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter the budget cap';
                                          }
                                          if (int.tryParse(value) == null) {
                                            return 'Please enter a valid integer amount';
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            projectDetails.budgetCap =
                                                double.tryParse(value) ?? 0.0;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Align(
                      alignment: Alignment.topRight,
                      child: SizedBox(
                        height: 300,
                        width: MediaQuery.of(context).size.width * .25,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200], // Grey background
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Starting a project',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                    '. Keep project names generic as the name could be shared with experts'),
                                SizedBox(height: 8),
                                Text(
                                    '. Targets will be kept anonymous unless otherwise noted'),
                                SizedBox(height: 8),
                                Text(
                                    '. No need to go into specifics on particular angles or call types as subsequent sections get deeper into that'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AngleTable extends StatefulWidget {
  @override
  _CreateAngleTableState createState() => _CreateAngleTableState();
}

class _CreateAngleTableState extends State<AngleTable> {
  //final _formKey = GlobalKey<FormState>();

  late List<Angle> angleList;

  @override
  void initState() {
    super.initState();
    final projectDetails = Provider.of<ProjectDetails>(context, listen: false);
    angleList = projectDetails.angles; // Initialize with the project's angles
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showAddAngleDialog(
      BuildContext context, ProjectDetails projectDetails, Angle? angle) {
    TextEditingController _backgroundInfoController = TextEditingController();
    TextEditingController _angleNameController = TextEditingController();
    TextEditingController _exampleRolesController = TextEditingController();
    TextEditingController _exampleCompaniesController = TextEditingController();
    TextEditingController _estimatedCallsController = TextEditingController();
    TextEditingController _additionalDetailsController =
        TextEditingController();

    String _preferredSeniority = angle?.preferredSeniority ?? 'C-Level Manager';
    int _callLength = angle?.callLength ?? 60; // Default to 1 hour (60 minutes)
    List<String> _questions = angle?.screeningQuestions ?? [];
    List<String> _exampleCompanies = angle?.exampleCompanies ?? [];
    List<String> _exampleRoles = angle?.exampleRoles ?? [];

    if (angle != null) {
      _backgroundInfoController.text = angle.background;
      _angleNameController.text = angle.name;
      _estimatedCallsController.text = angle.estimatedCallCount.toString();
      _additionalDetailsController.text = angle.additionalDetails;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add New Angle'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                      'Angle name*',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _angleNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'E.g. Decision makers at hotels',
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Background info on the angle and who you are looking to talk with*',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _backgroundInfoController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Information about client',
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Role Scope',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _exampleRolesController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText:
                            'C-suite, manager level, associate level, etc.',
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          _exampleRoles.add(value);
                          _exampleRolesController.clear();
                        });
                      },
                    ),
                    Wrap(
                      children: _exampleRoles
                          .map((role) => Chip(
                                label: Text(role),
                                onDeleted: () {
                                  setState(() {
                                    _exampleRoles.remove(role);
                                  });
                                },
                              ))
                          .toList(),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Preferred seniority',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButtonFormField<String>(
                      value: _preferredSeniority,
                      items: ['C-Level Manager', 'Manager', 'Director', 'VP']
                          .map((label) => DropdownMenuItem(
                                child: Text(label),
                                value: label,
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _preferredSeniority = value!;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Estimated number of calls',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _estimatedCallsController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter an Integer',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Example companies',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _exampleCompaniesController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Ace Hotel, Four Seasons, Mariott',
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          _exampleCompanies.add(value);
                          _exampleCompaniesController.clear();
                        });
                      },
                    ),
                    Wrap(
                      children: _exampleCompanies
                          .map((company) => Chip(
                                label: Text(company),
                                onDeleted: () {
                                  setState(() {
                                    _exampleCompanies.remove(company);
                                  });
                                },
                              ))
                          .toList(),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Call length',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButtonFormField<int>(
                      value: _callLength,
                      items: [30, 45, 60]
                          .map((length) => DropdownMenuItem(
                                child: Text('$length minutes'),
                                value: length,
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _callLength = value!;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Additional details*',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _additionalDetailsController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText:
                            'Talk with decision makers at hotels that make the soap purchasing decisions',
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Screening Questions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ..._questions.asMap().entries.map((entry) {
                      int index = entry.key;
                      String question = entry.value;
                      TextEditingController _questionController =
                          TextEditingController(text: question);
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _questionController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter your question here',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _questions[index] = value;
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _questions.removeAt(index);
                              });
                            },
                          ),
                        ],
                      );
                    }).toList(),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _questions.add('');
                        });
                      },
                      child: Text('Add Question'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Add'),
                  onPressed: () async {
                    int estimatedCalls =
                        int.tryParse(_estimatedCallsController.text) ?? 0;
                    Angle newAngle = Angle(
                      preferredSeniority: _preferredSeniority,
                      estimatedCallCount: estimatedCalls,
                      name: _angleNameController.text,
                      background: _backgroundInfoController.text,
                      callLength: _callLength,
                      exampleCompanies: _exampleCompanies,
                      exampleRoles: _exampleRoles,
                      screeningQuestions: _questions,
                      additionalDetails: _additionalDetailsController.text,
                    );

                    // Check if an angle with the same name exists
                    bool angleExists = false;
                    for (int i = 0; i < projectDetails.angles.length; i++) {
                      if (projectDetails.angles[i].name == newAngle.name) {
                        // Overwrite the existing angle
                        projectDetails.angles[i] = newAngle;
                        angleExists = true;
                        break;
                      }
                    }

                    // If no existing angle was found, add the new angle
                    if (!angleExists) {
                      projectDetails.angles.add(newAngle);
                    }
                    projectDetails.notifyListeners();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectDetails = Provider.of<ProjectDetails>(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    columns: [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Edit')),
                      DataColumn(label: Text('Duplicate')),
                      DataColumn(label: Text('Delete')),
                    ],
                    rows: angleList.map((angle) {
                      return DataRow(
                        cells: [
                          DataCell(Text(angle.name)),
                          DataCell(
                            Icon(Icons.edit),
                            onTap: () {
                              _showAddAngleDialog(
                                  context, projectDetails, angle);
                            },
                          ),
                          DataCell(
                            Icon(Icons.copy),
                            onTap: () {
                              _duplicateAngle(context, projectDetails, angle);
                            },
                          ),
                          DataCell(
                            Icon(Icons.delete),
                            onTap: () {
                              _deleteAngle(context, projectDetails, angle);
                            },
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton(
        onPressed: () async {
          _showAddAngleDialog(context, projectDetails, null);
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: Text('+ Add new angle', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  void _duplicateAngle(
      BuildContext context, ProjectDetails projectDetails, Angle angle) {
    Angle newAngle = Angle(
        name: '${angle.name}copy',
        background: angle.background,
        callLength: angle.callLength,
        exampleCompanies: angle.exampleCompanies,
        exampleRoles: angle.exampleCompanies,
        screeningQuestions: angle.screeningQuestions,
        preferredSeniority: angle.preferredSeniority,
        estimatedCallCount: angle.estimatedCallCount,
        additionalDetails: angle.additionalDetails);

    projectDetails.angles.add(newAngle);
    projectDetails.notifyListeners();
  }

  void _deleteAngle(
      BuildContext context, ProjectDetails projectDetails, Angle angle) {
    projectDetails.angles.remove(angle);
    projectDetails.notifyListeners();
  }
}

class ColleagueTable extends StatefulWidget {
  @override
  _ColleagueTableState createState() => _ColleagueTableState();
}

class _ColleagueTableState extends State<ColleagueTable> {
  late List<Colleague> colleagues = [];

  late List<String> angles = [];

  @override
  void initState() {
    super.initState();
    final projectDetails = Provider.of<ProjectDetails>(context, listen: false);
    colleagues = projectDetails.colleagues;
    angles = projectDetails.angles.map((angle) => angle.name).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              columns: [
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Angle')),
                DataColumn(label: Text('Link calendar for scheduling')),
              ],
              rows: colleagues.map((colleague) {
                return DataRow(
                  cells: [
                    DataCell(Text(colleague.email)),
                    DataCell(
                      Text(colleague.angleName),
                    ),
                    DataCell(
                      Checkbox(
                        value: colleague.calendarLinked,
                        onChanged: (bool? newValue) {
                          setState(() {
                            colleague.calendarLinked = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => addColleagueDialog(context),
          child: Text('Add Colleague'),
        ),
      ],
    );
  }

  void addColleagueDialog(BuildContext context) {
    String name = '';
    String email = '';
    String angle = angles[0];
    bool calendarLinked = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Colleague'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  name = value;
                },
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                onChanged: (value) {
                  email = value;
                },
                decoration: InputDecoration(labelText: 'Email'),
              ),
              DropdownSearch<String>(
                items: angles,
                selectedItem: angle,
                onChanged: (String? newValue) {
                  setState(() {
                    angle = newValue!;
                  });
                },
              ),
              Row(
                children: [
                  Text('Link calendar for scheduling'),
                  Checkbox(
                    value: calendarLinked,
                    onChanged: (bool? newValue) {
                      setState(() {
                        calendarLinked = newValue!;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  colleagues.add(Colleague(
                    name: name,
                    role: '',
                    email: email,
                    angleName: angle,
                    calendarLinked: calendarLinked,
                  ));
                });
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

class AngleFormatter extends StatefulWidget {
  @override
  _AngleFormatterState createState() => _AngleFormatterState();
}

class _AngleFormatterState extends State<AngleFormatter> {
  late List<Angle> angles;
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final projectDetails = Provider.of<ProjectDetails>(context, listen: false);
    angles = projectDetails.angles;
    fixAngles();
  }

  void fixAngles() {
    for (var i = 0; i < angles.length; i++) {
      textController.text += buildAngleText(angles[i], i + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Outreach message to the networks',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextField(
                controller: textController,
                maxLines: null,
                expands: true,
                decoration: InputDecoration.collapsed(hintText: ''),
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: textController.text));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Text copied to clipboard')),
              );
            },
            child: Text('Copy'),
          ),
        ],
      ),
    );
  }

  String buildAngleText(Angle angle, int index) {
    return '''
Angle $index\n
Angle title: ${angle.name}\n
Background: ${angle.background}\n
Call length: ${angle.callLength} hour\n
Example companies: \n${angle.exampleCompanies.map((e) => '• $e').join('\n')}\n
Example roles: \n${angle.exampleRoles.map((e) => '• $e').join('\n')}\n
Screening questions: \n${angle.screeningQuestions.map((e) => '• $e').join('\n')}\n
${angle.aiMatchPrompt != null ? 'AI Match Prompt: ${angle.aiMatchPrompt}\n' : ''}
Preferred Seniority: ${angle.preferredSeniority}\n
Estimated Call Count: ${angle.estimatedCallCount}\n
Additional Details: ${angle.additionalDetails}\n
\n
''';
  }
}

class MySpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  final List<Angle> angles;

  MySpecialTextSpanBuilder({required this.angles});

  @override
  TextSpan build(String data,
      {TextStyle? textStyle, SpecialTextGestureTapCallback? onTap}) {
    List<InlineSpan> children = [];

    angles.asMap().forEach((index, angle) {
      children.add(TextSpan(
        text: 'Angle ${index + 1}\n\n',
        style: textStyle,
      ));
      children.add(_buildBoldText('Angle title: '));
      children.add(TextSpan(text: '${angle.name}\n', style: textStyle));

      children.add(_buildBoldText('Background: '));
      children.add(TextSpan(text: '${angle.background}\n', style: textStyle));

      children.add(_buildBoldText('Call length: '));
      children
          .add(TextSpan(text: '${angle.callLength} hour\n', style: textStyle));

      children.add(_buildBoldText('Geo Focus: '));

      children.add(_buildBoldText('Example companies: \n'));
      children.add(TextSpan(
          text: '${angle.exampleCompanies.map((e) => '• $e').join('\n')}\n',
          style: textStyle));

      children.add(_buildBoldText('Example roles: \n'));
      children.add(TextSpan(
          text: '${angle.exampleRoles.map((e) => '• $e').join('\n')}\n',
          style: textStyle));

      children.add(_buildBoldText('Screening questions: \n'));
      children.add(TextSpan(
          text: '${angle.screeningQuestions.map((e) => '• $e').join('\n')}\n',
          style: textStyle));

      if (angle.aiMatchPrompt != null) {
        children.add(_buildBoldText('AI Match Prompt: '));
        children
            .add(TextSpan(text: '${angle.aiMatchPrompt}\n', style: textStyle));
      }

      children.add(_buildBoldText('Preferred Seniority: '));
      children.add(
          TextSpan(text: '${angle.preferredSeniority}\n', style: textStyle));

      children.add(_buildBoldText('Estimated Call Count: '));
      children.add(
          TextSpan(text: '${angle.estimatedCallCount}\n', style: textStyle));

      children.add(_buildBoldText('Additional Details: '));
      children.add(
          TextSpan(text: '${angle.additionalDetails}\n\n', style: textStyle));
    });

    return TextSpan(children: children, style: textStyle);
  }

  @override
  SpecialText createSpecialText(String flag,
      {TextStyle? textStyle,
      SpecialTextGestureTapCallback? onTap,
      int? index}) {
    // Implement your logic to create a special text
    // Here is an example of returning a default text span
    return SpecialText(flag, textStyle);
  }

  TextSpan _buildBoldText(String text) {
    return TextSpan(
      text: text,
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }
}

abstract class SpecialTextSpanBuilder {
  TextSpan build(String data,
      {TextStyle? textStyle, SpecialTextGestureTapCallback? onTap});
  SpecialText createSpecialText(String flag,
      {TextStyle? textStyle, SpecialTextGestureTapCallback? onTap, int? index});
}

typedef SpecialTextGestureTapCallback = void Function(String);

class SpecialText {
  final String text;
  final TextStyle? textStyle;

  SpecialText(this.text, this.textStyle);
}
