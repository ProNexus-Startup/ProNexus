class User {
  String? userId;
  String email;
  String fullName;
  String password;
  String organizationId;
  String? projectId;
  DateTime? dateOnboarded;
  List<String>? pastProjectIDs;
  bool admin;

  User({
    this.userId,
    required this.email,
    required this.fullName,
    required this.password,
    required this.organizationId,
    this.projectId,
    this.dateOnboarded,
    this.pastProjectIDs,
    required this.admin,
  });

  // Default constructor
  User.defaultUser()
      : userId = '',
        email = '',
        fullName = '',
        password = '',
        organizationId = '',
        admin = false;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['id'] as String?,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      password: json['password'] as String,
      organizationId: json['organizationId'] as String,
      projectId: json['projectId']
          as String?, // Nullable in JSON, so make sure it's nullable in Dart
      dateOnboarded: json['dateOnboarded'] == null
          ? null
          : DateTime.parse(json['dateOnboarded']),
      pastProjectIDs: (json['pastProjectIDs'] as List<dynamic>?)
          ?.map((item) => item as String)
          .toList(),
      admin: json['admin'] as bool,
    );
  }
}
