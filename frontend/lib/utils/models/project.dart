class Project {
  final String projectId;
  final String name;
  final DateTime startDate;
  final String? target;
  int callsCompleted;
  String? status;

  Project({
    required this.projectId,
    required this.name,
    required this.startDate,
    required this.target,
    required this.callsCompleted,
    required this.status,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectId: json['projectId'],
      name: json['name'],
      startDate: DateTime.parse(
          json['startDate']), // Add this line to parse the date string
      target: json['target'],
      callsCompleted: json['callsCompleted'],
      status: json['status'],
    );
  }
}
