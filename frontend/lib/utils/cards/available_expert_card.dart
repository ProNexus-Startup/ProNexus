class AvailableExpert {
  final String expertId;
  final String name;
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
  final String screeningQuestions;

  AvailableExpert({
    required this.expertId,
    required this.name,
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
    return AvailableExpert(
      expertId: json['expertId'],
      name: json['name'],
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
      screeningQuestions: json['screeningQuestions'],
    );
  }
}
