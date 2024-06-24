import 'package:admin/utils/formatting/app_theme.dart';
import 'package:flutter/material.dart';

class StepperLayout extends StatefulWidget {
  final int initialIndex;
  final ValueChanged<int> onStepChanged;

  StepperLayout(
      {Key? key, required this.initialIndex, required this.onStepChanged})
      : super(key: key);

  @override
  _StepperLayoutState createState() => _StepperLayoutState();
}

class _StepperLayoutState extends State<StepperLayout> {
  late int _selectedIndex;

  final List<String> _titles = [
    "Details",
    "Angles",
    "Colleagues",
    "Ready to share"
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(StepperLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      setState(() {
        _selectedIndex = widget.initialIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(_titles.length, (index) {
            bool isSelected = _selectedIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                widget.onStepChanged(index);
              },
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isSelected ? primaryBlue : Colors.grey,
                    radius: 10,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    _titles[index],
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (index != _titles.length - 1) ...[
                    SizedBox(width: 5),
                    Container(
                      width: 50,
                      height: 2,
                      color: Colors.grey,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                    ),
                    SizedBox(width: 5),
                  ]
                ],
              ),
            );
          }),
        ),
        // Add other content here, depending on the selected step
      ],
    );
  }
}
