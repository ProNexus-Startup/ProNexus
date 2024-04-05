/*Future<void> createSampleAvailableExperts() async {
    print("Sample list made");
    this.expertList = [
// Sample AvailableExpert 1
      AvailableExpert(
        isSelected: false,
        expertId: "1",
        name: "Alice Johnson",
        favorite: true,
        title: "Senior Flutter Developer",
        company: "Tech Innovations Inc",
        yearsAtCompany: "5",
        description:
            "Alice is a seasoned Flutter developer with a passion for creating seamless mobile applications. She has contributed to over 20 apps in the finance and healthcare sectors.",
        geography: "North America",
        angle: "Application Development",
        status: "Active",
        AIAssessment: 99,
        comments:
            "Great understanding of Flutter best practices and architecture.",
        availability: "Monday to Friday, 9am to 5pm EST",
        expertNetworkName: "Flutter AvailableExperts Hub",
        cost: 19999,
        screeningQuestions: [
          "Please describe your project's main objectives and your specific needs from a Flutter development perspective.",
          "Please describe your project's main objectives and your specific needs from a Flutter development perspective."
        ],
      ),

// Sample AvailableExpert 2
      AvailableExpert(
        isSelected: true,
        expertId: "2",
        name: "Bob Smith",
        favorite: false,
        title: "Flutter UI/UX Specialist",
        company: "DesignWorld",
        yearsAtCompany: "3",
        description:
            "Bob specializes in crafting intuitive and engaging user interfaces for Flutter apps. His work emphasizes accessibility and user experience.",
        geography: "Europe",
        angle: "UI/UX Design",
        status: "Active",
        AIAssessment: 50,
        comments:
            "Exceptional skills in UI design patterns and user testing methodologies.",
        availability: "Flexible",
        expertNetworkName: "Global Tech Artists",
        cost: 100,
        screeningQuestions: [
          "Can you provide examples of UI/UX challenges you've faced in Flutter apps and how you resolved them?",
          "Can you provide examples of UI/UX challenges you've faced in Flutter apps and how you resolved them?"
        ],
      ),

// Sample AvailableExpert 3
      AvailableExpert(
        isSelected: false,
        expertId: "3",
        name: "Christina Lee",
        favorite: true,
        title: "Mobile Tech Analyst",
        company: "Big Bank",
        yearsAtCompany: "7",
        description:
            "With a deep understanding of the mobile tech industry, Christina offers invaluable insights into market trends and Flutter's place within it.",
        geography: "Asia",
        angle: "Market Analysis",
        status: "Consulting",
        AIAssessment: 1,
        comments:
            "Provides thorough and actionable market analysis tailored to Flutter's ecosystem.",
        availability: "By appointment",
        expertNetworkName: "Tech Insights Network",
        cost: 300,
        screeningQuestions: [
          "What specific market trends are you interested in exploring?",
          "What specific market trends are you interested in exploring?"
        ],
      ),
    ];
  }
  
  
  
class FilterTable extends StatefulWidget {
  @override
  _FilterTableState createState() => _FilterTableState();
}

class _FilterTableState extends State<FilterTable> {
  Map<String, bool> statusFilters = {
    'In process': false,
    'Available': false,
    'Already scheduled': false,
    'Not pursuing': false,
  };

  bool favoriteFilter = false;

  Map<String, bool> angleFilters = {
    'Retailers': false,
    'Decision makers': false,
    'Other industry participants': false,
  };

  Map<String, bool> geographyFilters = {
    'USA': false,
    'India': false,
  };

  Map<String, bool> expertNetworkFilters = {
    'Alphasights': false,
    'GLG': false,
    'Coleman': false,
    'Third Bridge': false,
    'Dialectica': false,
    'ProSapient': false,
  };

  bool isExpanded = false;

  Widget _buildFilterCategory(String title, Map<String, bool> filters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        ...filters.keys.map((key) {
          return CheckboxListTile(
            title: Text(key),
            value: filters[key],
            onChanged: (bool? value) {
              setState(() {
                filters[key] = value!;
              });
            },
          );
        }).toList(),
        Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Filter Options',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          _buildFilterCategory('Status', statusFilters),
          CheckboxListTile(
            title: Text('Favorite'),
            value: favoriteFilter,
            onChanged: (bool? value) {
              setState(() {
                favoriteFilter = value!;
              });
            },
          ),
          _buildFilterCategory('Filter by angle', angleFilters),
          _buildFilterCategory('Geography', geographyFilters),
          _buildFilterCategory('Expert network', expertNetworkFilters),
          InkWell(
            child: Text(isExpanded ? 'Show Less' : 'Show More'),
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
          ),
        ],
      ),
    );
  }
}
*/