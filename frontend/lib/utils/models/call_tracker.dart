class CallTracker {
  bool isSelected = false;
  bool favorite = false;
  final String expertId;
  String name;
  String projectId;
  String organizationId; // Added to match the Go model
  String title;
  String company;
  String companyType;
  int yearsAtCompany;
  String description;
  String geography;
  String angle;
  String status;
  String AIAssessment;
  String comments;
  String availability;
  String expertNetworkName;
  double cost; // Keep as double, equivalent to float64 in Go
  List<String> screeningQuestions;
  String addedExpertBy;
  DateTime dateAddedExpert;
  String addedCallBy;
  DateTime dateAddedCall;
  bool inviteSent = false;
  DateTime meetingStartDate;
  DateTime meetingEndDate;
  bool paidStatus;
  int? rating;

  CallTracker({
    this.isSelected = false,
    required this.expertId,
    required this.name,
    required this.projectId,
    this.favorite = false,
    required this.organizationId, // Ensure this is initialized
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
    this.inviteSent = false,
    required this.meetingStartDate,
    required this.meetingEndDate,
    required this.paidStatus,
    this.rating,
  });

  factory CallTracker.fromJson(Map<String, dynamic> json) {
    return CallTracker(
      isSelected: json['isSelected'] ?? false,
      expertId: json['expertId'],
      name: json['name'],
      projectId: json['projectId'],
      favorite: json['favorite'] ?? false,
      organizationId: json['organizationId'], // Added
      title: json['title'],
      company: json['company'],
      companyType: json['companyType'],
      yearsAtCompany: json['yearsAtCompany'] as int,
      description: json['description'],
      geography: json['geography'],
      angle: json['angle'],
      status: json['status'],
      AIAssessment: json['AIAssessment'],
      comments: json['comments'],
      availability: json['availability'],
      expertNetworkName: json['expertNetworkName'],
      cost: json['cost'].toDouble(),
      screeningQuestions: List<String>.from(
          json['screeningQuestions'].map((x) => x.toString())),
      addedExpertBy: json['addedExpertBy'],
      dateAddedExpert: DateTime.parse(json['dateAddedExpert']),
      addedCallBy: json['addedCallBy'],
      dateAddedCall: DateTime.parse(json['dateAddedCall']),
      inviteSent: json['inviteSent'] ?? false,
      meetingStartDate: DateTime.parse(json['meetingStartDate']),
      meetingEndDate: DateTime.parse(json['meetingEndDate']),
      paidStatus: json['paidStatus'],
      rating: json['rating'],
    );
  }
}
