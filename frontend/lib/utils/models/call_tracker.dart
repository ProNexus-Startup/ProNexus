class CallTracker {
  bool? isSelected = false;
  final String expertId;
  String name;
  String projectId;
  bool? favorite = false;
  String title;
  String company;
  String companyType;
  String yearsAtCompany;
  String description;
  String geography;
  String angle;
  String status;
  final int? AIAssessment;
  String? comments;
  final String availability;
  final String expertNetworkName;
  double cost;
  List<String> screeningQuestions;
  String addedExpertBy;
  DateTime dateAddedExpert;
  String addedCallBy;
  DateTime dateAddedCall;
  bool inviteSent;
  DateTime meetingStartDate;
  DateTime meetingEndDate;
  bool paidStatus;
  int rating;

  CallTracker({
    this.isSelected,
    required this.expertId,
    required this.name,
    required this.projectId,
    this.favorite,
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
    required this.addedCallBy,
    required this.dateAddedCall,
    required this.inviteSent,
    required this.meetingStartDate,
    required this.meetingEndDate,
    required this.paidStatus,
    required this.rating,
  });

  factory CallTracker.fromJson(Map<String, dynamic> json) {
    var screeningQuestionsFromJson = json['screeningQuestions'];
    List<String> screeningQuestionsList = [];
    if (screeningQuestionsFromJson != null) {
      screeningQuestionsList = List<String>.from(
          screeningQuestionsFromJson.map((question) => question.toString()));
    }

    return CallTracker(
      isSelected: json['isSelected'] ?? false,
      expertId: json['expertId'],
      name: json['name'],
      projectId: json['projectId'],
      favorite: json['favorite'],
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
      addedCallBy: json['addedCallBy'],
      dateAddedCall: DateTime.parse(json['dateAddedCall']),
      inviteSent: json['inviteSent'],
      meetingStartDate: DateTime.parse(json['meetingStartDate']),
      meetingEndDate: DateTime.parse(json['meetingEndDate']),
      paidStatus: json['paidStatus'],
      rating: json['rating'],
    );
  }
}
