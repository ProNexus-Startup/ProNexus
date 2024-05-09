class AvailableExpert {
  bool isSelected = false; // Default to false instead of being nullable
  bool favorite = false; // Default to false

  final String expertId;
  String name;
  String projectId;
  String title;
  String company;
  String companyType;
  String yearsAtCompany;
  String description;
  String geography;
  String angle;
  String status;
  int? AIAssessment; // Keep nullable if assessment may not exist
  String? comments;
  final String availability;
  final String expertNetworkName;
  double cost;
  List<String> screeningQuestions;
  String addedExpertBy;
  DateTime dateAddedExpert;

  AvailableExpert({
    this.isSelected = false, // Provide a default value directly
    required this.expertId,
    required this.name,
    required this.projectId,
    this.favorite = false, // Provide a default value directly
    required this.title,
    required this.company,
    required this.companyType,
    required this.yearsAtCompany,
    required this.description,
    required this.geography,
    required this.angle,
    required this.status,
    this.AIAssessment,
    this.comments,
    required this.availability,
    required this.expertNetworkName,
    required this.cost,
    required this.screeningQuestions,
    required this.addedExpertBy,
    required this.dateAddedExpert,
  });

  factory AvailableExpert.fromJson(Map<String, dynamic> json) {
    var screeningQuestionsFromJson = json['screeningQuestions'];
    List<String> screeningQuestionsList = screeningQuestionsFromJson != null
        ? List<String>.from(
            screeningQuestionsFromJson.map((question) => question.toString()))
        : [];

    return AvailableExpert(
      isSelected: json['isSelected'] ?? false,
      expertId: json['expertId'],
      name: json['name'],
      projectId: json['projectId'],
      favorite: json['favorite'] ?? false,
      title: json['title'],
      company: json['company'],
      companyType: json['companyType'],
      yearsAtCompany: json['yearsAtCompany'],
      description: json['description'],
      geography: json['geography'],
      angle: json['angle'],
      status: json['status'],
      AIAssessment: json['AIAssessment'],
      comments: json['comments'],
      availability: json['availability'],
      expertNetworkName: json['expertNetworkName'],
      cost: json['cost'].toDouble(),
      screeningQuestions: screeningQuestionsList,
      addedExpertBy: json['addedExpertBy'],
      dateAddedExpert: DateTime.parse(json['dateAddedExpert']),
    );
  }
}
