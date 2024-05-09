class CallTracker {
  bool isSelected = false;
  bool favorite = false;
  final String
      expertId; // Adjusted to be consistent with the backend model field name `ID`
  String name;
  String projectId;
  String title;
  String company;
  String companyType;
  int yearsAtCompany; // Changed from String to int
  String description;
  String geography;
  String angle;
  String status;
  String AIAssessment; // Changed from `int?` to `String` to match the backend
  String comments;
  String availability;
  String expertNetworkName;
  double cost;
  List<String> screeningQuestions;
  String addedExpertBy;
  DateTime dateAddedExpert;
  String addedCallBy;
  DateTime dateAddedCall;
  bool inviteSent = false; // Default value adjusted to non-nullable
  DateTime meetingStartDate;
  DateTime meetingEndDate;
  bool paidStatus;
  int rating;

  CallTracker({
    this.isSelected = false, // Default provided in constructor
    required this.expertId,
    required this.name,
    required this.projectId,
    this.favorite = false, // Default provided in constructor
    required this.title,
    required this.company,
    required this.companyType,
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
    required this.addedExpertBy,
    required this.dateAddedExpert,
    required this.addedCallBy,
    required this.dateAddedCall,
    this.inviteSent = false, // Default provided in constructor
    required this.meetingStartDate,
    required this.meetingEndDate,
    required this.paidStatus,
    required this.rating,
  });

  factory CallTracker.fromJson(Map<String, dynamic> json) {
    return CallTracker(
      isSelected: json['isSelected'] ?? false,
      expertId: json['expertId'],
      name: json['name'],
      projectId: json['projectId'],
      favorite: json['favorite'] ?? false,
      title: json['title'],
      company: json['company'],
      companyType: json['companyType'],
      yearsAtCompany: json['yearsAtCompany'] as int, // Handle casting
      description: json['description'],
      geography: json['geography'],
      angle: json['angle'],
      status: json['status'],
      AIAssessment: json['AIAssessment'],
      comments: json['comments'],
      availability: json['availability'],
      expertNetworkName: json['expertNetworkName'],
      cost: json['cost'].toDouble(), // Ensure casting to double
      screeningQuestions: List<String>.from(
          json['screeningQuestions'].map((x) => x.toString())),
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
