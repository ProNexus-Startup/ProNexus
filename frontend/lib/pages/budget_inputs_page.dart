import 'package:admin/pages/components/sub_menu.dart';
import 'package:admin/pages/components/header.dart';
import 'package:admin/utils/BaseAPI.dart';
import 'package:admin/utils/formatting/app_theme.dart';
import 'package:admin/utils/models/project.dart';
import 'package:admin/utils/persistence/global_bloc.dart';
import 'package:admin/utils/persistence/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetInputsPage extends StatefulWidget {
  final String token;
  static const routeName = '/budget';

  const BudgetInputsPage({Key? key, required this.token}) : super(key: key);

  @override
  _BudgetInputsPageState createState() => _BudgetInputsPageState();
}

class _BudgetInputsPageState extends State<BudgetInputsPage> {
  bool isAnySelected = false;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _saveContext();
    _loadData();
  }

  Future<void> _saveContext() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('last_route', BudgetInputsPage.routeName);
  }

  Future<void> _loadData() async {
    Project? project = await findProjectById();
    if (project != null) {
      Provider.of<ExpensesProvider>(context, listen: false)
          .setExpenses(project.expenses ?? []);
    }

    final GlobalBloc globalBloc =
        Provider.of<GlobalBloc>(context, listen: false);
    globalBloc.onUserLogin();
  }

  Future<Project?> findProjectById() async {
    final GlobalBloc globalBloc =
        Provider.of<GlobalBloc>(context, listen: false);
    List<Project> projects = globalBloc.projectList;

    SecureStorage secureStorage = SecureStorage();
    String projectId = await secureStorage.read('projectId');

    for (var project in projects) {
      if (project.projectId == projectId) {
        return project;
      }
    }
    return null; // Return null if the project is not found
  }

  void updateSelection(bool isSelected) {
    setState(() {
      isAnySelected = isSelected;
    });
  }

  Future<void> _saveChanges(String token, List<Expense> newExpenses) async {
    final AuthAPI _authAPI = AuthAPI();
    SecureStorage secureStorage = SecureStorage();
    String projectId = await secureStorage.read('projectId');

    await _authAPI.updateProjectExpenses(token, projectId, newExpenses);
  }

  void _revertChanges() {
    _toggleEditing();
  }

  void _toggleEditing() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenses = Provider.of<ExpensesProvider>(context).expenses;
    return Scaffold(
      appBar:
          PreferredSize(preferredSize: Size.fromHeight(100), child: TopMenu()),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SubMenu(
              token: widget.token,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 160.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Budget input updates',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isEditing)
                        TextButton.icon(
                          onPressed: _toggleEditing,
                          icon: Icon(Icons.edit, color: primaryBlue),
                          label: Text(
                            'Edit budget inputs',
                            style: TextStyle(color: primaryBlue),
                          ),
                        ),
                      if (isEditing)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _saveChanges(widget.token, expenses);
                                _toggleEditing();
                              },
                              child: Text('Save Changes'),
                            ),
                            ElevatedButton(
                              onPressed: _revertChanges,
                              child: Text('Revert'),
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircularDataTable(
                            title: "Project Expenses",
                            columnHeaders: ['Name', 'Input'],
                            expenses: expenses,
                            token: widget.token,
                            isEditing: isEditing,
                          ),
                          SizedBox(height: 20),
                          CircularDataTable(
                            title: "Survey Expenses",
                            columnHeaders: ['Name', 'Input'],
                            expenses: expenses,
                            token: widget.token,
                            isEditing: isEditing,
                          ),
                          SizedBox(height: 20),
                          CircularDataTable(
                            title: "Other Call Expenses",
                            columnHeaders: ['Name', 'Input'],
                            expenses: expenses,
                            token: widget.token,
                            isEditing: isEditing,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircularDataTable(
                            title: "Secondary Reports",
                            columnHeaders: ['Name', 'Input'],
                            expenses: expenses,
                            token: widget.token,
                            isEditing: isEditing,
                          ),
                          SizedBox(height: 20),
                          CircularDataTable(
                            title: "Personal Expenses",
                            columnHeaders: ['Name', 'Input'],
                            expenses: expenses,
                            token: widget.token,
                            isEditing: isEditing,
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularDataTable extends StatefulWidget {
  final List<String> columnHeaders;
  final List<Expense> expenses;
  final String title;
  final String token;
  final bool isEditing;

  CircularDataTable({
    required this.columnHeaders,
    required this.expenses,
    required this.title,
    required this.token,
    required this.isEditing,
  });

  @override
  _CircularDataTableState createState() => _CircularDataTableState();
}

class _CircularDataTableState extends State<CircularDataTable> {
  late List<List<dynamic>> rowsData;
  late List<TextEditingController> controllers;
  late List<bool> isEditingRow;

  List<List<dynamic>> getRows(List<Expense> expenses, String title) {
    List<List<dynamic>> rows = [];
    for (Expense expense in expenses) {
      if (expense.type == title) {
        rows.add([expense.name, expense.cost.toString()]);
      }
    }
    return rows;
  }

  @override
  void initState() {
    super.initState();
    rowsData = List.from(getRows(widget.expenses, widget.title));
    controllers = List.generate(rowsData.length, (index) {
      return TextEditingController(text: rowsData[index][1]);
    });
    isEditingRow = List.generate(rowsData.length, (index) => false);
  }

  void _addExpense(String name, double amount) {
    setState(() {
      rowsData.add([name, amount.toString()]);
      controllers.add(TextEditingController(text: amount.toString()));
      isEditingRow.add(false);
    });
    Provider.of<ExpensesProvider>(context, listen: false)
        .addExpense(Expense(name: name, cost: amount, type: widget.title));
  }

  Future<void> showAddExpenseDialog(BuildContext context, String token,
      Function(String, double) onAdd, List<Expense> newExpenses) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Expense"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final String name = nameController.text;
                final double amount =
                    double.tryParse(amountController.text) ?? 0.0;
                if (name.isNotEmpty) {
                  onAdd(name, amount);
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = rowsData.fold(0, (sum, row) {
      double amount = double.tryParse(row[1]) ?? 0.0;
      return sum + amount;
    });

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Column(
          children: [
            Container(
              width: 400,
              color: primaryBlue,
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  widget.title,
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                columnWidths: {
                  for (int i = 0; i < widget.columnHeaders.length; i++)
                    i: FixedColumnWidth(200.0),
                },
                children: [
                  TableRow(
                    children: widget.columnHeaders.map((header) {
                      return Container(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            header,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  ...rowsData
                      .asMap()
                      .map((rowIndex, row) {
                        return MapEntry(
                          rowIndex,
                          TableRow(
                            children: row
                                .asMap()
                                .map((index, cell) {
                                  return MapEntry(
                                    index,
                                    GestureDetector(
                                      onTap: () {
                                        if (index == 1 && widget.isEditing) {
                                          setState(() {
                                            isEditingRow[rowIndex] = true;
                                          });
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                        ),
                                        padding: EdgeInsets.all(8.0),
                                        child: Center(
                                          child: isEditingRow[rowIndex] &&
                                                  index == 1
                                              ? TextField(
                                                  controller:
                                                      controllers[rowIndex],
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                  ),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  onSubmitted: (newValue) {
                                                    setState(() {
                                                      rowsData[rowIndex][1] =
                                                          newValue;
                                                      isEditingRow[rowIndex] =
                                                          false;
                                                    });
                                                    Provider.of<ExpensesProvider>(
                                                            context,
                                                            listen: false)
                                                        .updateExpense(
                                                            rowIndex,
                                                            Expense(
                                                                name: rowsData[
                                                                        rowIndex]
                                                                    [0],
                                                                cost: double.tryParse(
                                                                        newValue) ??
                                                                    0.0,
                                                                type: widget
                                                                    .title));
                                                  },
                                                )
                                              : Text(
                                                  cell,
                                                  style: index == 0
                                                      ? TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)
                                                      : TextStyle(
                                                          fontWeight: FontWeight
                                                              .normal),
                                                ),
                                        ),
                                      ),
                                    ),
                                  );
                                })
                                .values
                                .toList(),
                          ),
                        );
                      })
                      .values
                      .toList(),
                ],
              ),
            ),
            if (widget.isEditing)
              Container(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () {
                      showAddExpenseDialog(
                          context, widget.token, _addExpense, widget.expenses);
                    },
                    icon: Icon(Icons.add),
                    label: Text("Add expense"),
                  ),
                ),
              ),
            Table(
              columnWidths: {
                for (int i = 0; i < widget.columnHeaders.length; i++)
                  i: FixedColumnWidth(200.0),
              },
              children: [
                TableRow(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "Total",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "\$${totalAmount.toStringAsFixed(2)}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ExpensesProvider with ChangeNotifier {
  List<Expense> _expenses = [];

  List<Expense> get expenses => _expenses;

  void setExpenses(List<Expense> expenses) {
    _expenses = expenses;
    notifyListeners();
  }

  void updateExpense(int index, Expense newExpense) {
    _expenses[index] = newExpense;
    notifyListeners();
  }

  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }
}
