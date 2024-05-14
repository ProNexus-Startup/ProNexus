class AvailableExpert {
  bool isSelected = false;
  bool favorite = false;

  final String expertId;
  String name;
  String organizationId; // Added to match backend
  String projectId;
  String title;
  String company;
  String companyType;
  String yearsAtCompany;
  String description;
  String geography;
  String angle;
  String status;
  int AIAssessment; // Changed to non-nullable
  String comments; // Changed to non-nullable
  final String availability;
  final String expertNetworkName;
  double cost;
  List<String> screeningQuestions;
  String addedExpertBy;
  DateTime dateAddedExpert;

  AvailableExpert({
    this.isSelected = false,
    required this.expertId,
    required this.name,
    required this.organizationId, // Now required
    required this.projectId,
    this.favorite = false,
    required this.title,
    required this.company,
    required this.companyType,
    required this.yearsAtCompany,
    required this.description,
    required this.geography,
    required this.angle,
    required this.status,
    required this.AIAssessment, // Non-nullable
    required this.comments, // Non-nullable
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
      organizationId: json['organizationId'], // Added
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
      AIAssessment: json['AIAssessment'], // Assume presence in JSON
      comments: json['comments'], // Assume presence in JSON
      availability: json['availability'],
      expertNetworkName: json['expertNetworkName'],
      cost: json['cost'].toDouble(),
      screeningQuestions: screeningQuestionsList,
      addedExpertBy: json['addedExpertBy'],
      dateAddedExpert: DateTime.parse(json['dateAddedExpert']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'organizationId': organizationId,
      'projectId': projectId,
      'favorite': favorite,
      'title': title,
      'company': company,
      'companyType': companyType,
      'yearsAtCompany': yearsAtCompany,
      'description': description,
      'geography': geography,
      'angle': angle,
      'status': status,
      'availability': availability,
      'expertNetworkName': expertNetworkName,
      'cost': cost,
      'screeningQuestions': screeningQuestions,
      'addedExpertBy': addedExpertBy,
      'dateAddedExpert':
          dateAddedExpert.toIso8601String().replaceFirst(RegExp(r'\.\d+'), '') +
              'Z',
    };
  }
}
