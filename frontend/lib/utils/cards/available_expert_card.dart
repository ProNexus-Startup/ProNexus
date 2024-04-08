class AvailableExpert {
  bool isSelected = false; // Add this line
  final String expertId;
  final String name;
  final String projectId;
  bool favorite;
  final String title;
  final String company;
  final String yearsAtCompany; //Potentially save as date. Wait for feedback
  final String description;
  final String geography; //Save as string for now, but this is case-by-case
  final String angle;
  String status;
  final int AIAssessment;
  String comments;
  final String availability;
  final String expertNetworkName;
  final double cost;
  final List<String> screeningQuestions;

  AvailableExpert({
    required this.isSelected,
    required this.expertId,
    required this.name,
    required this.projectId,
    required this.favorite,
    required this.title,
    required this.company,
    required this.yearsAtCompany,
    required this.description,
    required this.geography,
    required this.angle,
    required this.status,
    required this.AIAssessment,
    required this.comments,
    required this.availability,
    required this.expertNetworkName,
    required this.cost,
    required this.screeningQuestions,
  });

  factory AvailableExpert.fromJson(Map<String, dynamic> json) {
    // Ensure screeningQuestions is cast to List<String>
    var screeningQuestionsFromJson = json['screeningQuestions'];
    List<String> screeningQuestionsList = [];
    if (screeningQuestionsFromJson != null) {
      screeningQuestionsList = List<String>.from(
          screeningQuestionsFromJson.map((question) => question.toString()));
    }

    return AvailableExpert(
      isSelected: false,
      expertId: json['expertId'],
      name: json['name'],
      projectId: json['projectId'],
      favorite: json['favorite'],
      title: json['title'],
      company: json['company'],
      yearsAtCompany: json['yearsAtCompany'],
      description: json['description'],
      geography: json['geography'],
      angle: json['angle'],
      status: json['status'],
      AIAssessment: json['AIAssessment'],
      comments: json['comments'],
      availability: json['availability'],
      expertNetworkName: json['expertNetworkName'],
      cost: json['cost'].toDouble(), // Ensure it's a double, might need parsing
      screeningQuestions: screeningQuestionsList,
    );
  }
}
