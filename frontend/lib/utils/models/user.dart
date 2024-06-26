class User {
  String? userId;
  String email;
  String fullName;
  String password;
  String organizationId;
  DateTime? dateOnboarded;
  String currentProject;
  List<Proj> pastProjects;
  bool admin;
  String? level;
  DateTime? signedAt;
  String? token;

  User({
    this.userId,
    required this.email,
    required this.fullName,
    required this.password,
    required this.currentProject,
    required this.organizationId,
    this.dateOnboarded,
    required this.admin,
    this.level,
    this.signedAt,
    this.token,
    required this.pastProjects,
  });

  User.defaultUser()
      : userId = '',
        email = '',
        fullName = '',
        password = '',
        currentProject = '',
        organizationId = '',
        level = '',
        pastProjects = [],
        admin = false;

  factory User.fromJson(Map<String, dynamic> json) {
    var pastprojectFromJson = json['pastProjects'] as List<dynamic>?;
    List<Proj> pastProjectsList = pastprojectFromJson != null
        ? List<Proj>.from(pastprojectFromJson
            .map((availability) => Proj.fromJson(availability)))
        : [];

    return User(
      userId: json['id'] as String?,
      email: json['email'] as String,
      currentProject: json['currentProject'] as String,
      fullName: json['fullName'] as String,
      password: json['password'] as String,
      organizationId: json['organizationId'] as String,
      dateOnboarded: json['dateOnboarded'] == null
          ? null
          : DateTime.parse(json['dateOnboarded']),
      admin: json['admin'] as bool,
      level: json['level'] as String,
      signedAt:
          json['signedAt'] == null ? null : DateTime.parse(json['signedAt']),
      token: json['token'] as String?,
      pastProjects: pastProjectsList,
    );
  }
}

class Proj {
  DateTime start;
  DateTime? end;
  String projectId;

  Proj({
    required this.start,
    this.end,
    required this.projectId,
  });

  factory Proj.fromJson(Map<String, dynamic> json) {
    return Proj(
      start: DateTime.parse(json['start']),
      end: json['end'] != null ? DateTime.parse(json['end']) : null,
      projectId: json['projectId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start.toIso8601String().replaceFirst(RegExp(r'\.\d+'), '') + 'Z',
      'end': end!.toIso8601String().replaceFirst(RegExp(r'\.\d+'), '') + 'Z',
      'projectId': projectId,
    };
  }
}
