class Project {
  final String? projectId;
  final String name;
  final String organizationId;
  final DateTime startDate;
  DateTime? endDate;
  final String target;
  final int callsCompleted;
  final String status;

  Project({
    this.projectId,
    required this.name,
    required this.startDate,
    this.endDate,
    required this.organizationId,
    required this.target,
    required this.callsCompleted,
    required this.status,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectId: json['projectId'] as String,
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      organizationId: json['organizationId'] as String, // Handle this field
      target: json['target'] as String, // Ensure non-nullability
      callsCompleted: json['callsCompleted'] as int,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'organizationId': organizationId,
      // Format the date to ISO8601 without milliseconds and with 'Z'
      'startDate':
          startDate.toIso8601String().replaceFirst(RegExp(r'\.\d+'), '') + 'Z',
      'target': target,
      'callsCompleted': callsCompleted,
      'status': status,
    };
  }
}
