class Project {
  final String? projectId;
  final String name;
  final String organizationId;
  final DateTime startDate;
  DateTime? endDate;
  final int callsCompleted;
  final String status;
  List<Expense>? expenses;
  List<Angle>? angles;
  final String targetCompany;
  final List<String> doNotContact;
  final List<String> regions;
  final String scope;
  final String type;
  final int estimatedCalls;
  final double budgetCap;
  final String? emailBody;
  final String? emailSubject;
  final List<Colleague> colleagues;

  Project({
    this.projectId,
    required this.name,
    required this.startDate,
    this.endDate,
    required this.organizationId,
    required this.callsCompleted,
    required this.status,
    this.expenses,
    this.angles,
    required this.targetCompany,
    required this.doNotContact,
    required this.regions,
    required this.scope,
    required this.type,
    required this.estimatedCalls,
    required this.budgetCap,
    this.emailBody,
    this.emailSubject,
    required this.colleagues,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectId: json['projectId'] as String?,
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      organizationId: json['organizationId'] as String,
      callsCompleted: json['callsCompleted'] as int,
      status: json['status'] as String,
      expenses: json['expenses'] != null
          ? (json['expenses'] as List)
              .map((item) => Expense.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
      angles: json['angles'] != null
          ? (json['angles'] as List)
              .map((item) => Angle.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
      targetCompany: json['targetCompany'] as String,
      doNotContact: (json['doNotContact'] as List<dynamic>)
          .map((item) => item as String)
          .toList(),
      regions: (json['regions'] as List<dynamic>)
          .map((item) => item as String)
          .toList(),
      scope: json['scope'] as String,
      type: json['type'] as String,
      estimatedCalls: json['estimatedCalls'] as int,
      budgetCap: (json['budgetCap'] as num).toDouble(),
      emailBody: json['emailBody'] as String?,
      emailSubject: json['emailSubject'] as String?,
      colleagues: (json['colleagues'] as List)
          .map((item) => Colleague.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'name': name,
      'organizationId': organizationId,
      'startDate': startDate.toUtc().toIso8601String(),
      'endDate': endDate?.toUtc().toIso8601String(),
      'callsCompleted': callsCompleted,
      'status': status,
      'expenses': expenses?.map((expense) => expense.toJson()).toList(),
      'angles': angles?.map((angle) => angle.toJson()).toList(),
      'targetCompany': targetCompany,
      'doNotContact': doNotContact,
      'regions': regions,
      'scope': scope,
      'type': type,
      'estimatedCalls': estimatedCalls,
      'budgetCap': budgetCap,
      'emailBody': emailBody,
      'emailSubject': emailSubject,
      'colleagues': colleagues.map((colleague) => colleague.toJson()).toList(),
    };
  }

  static Project defaultProject(String orgId) {
    return Project(
      name: 'Default Project',
      startDate: DateTime.now(),
      organizationId: orgId,
      callsCompleted: 0,
      status: 'Pending',
      targetCompany: 'Default Target Company',
      doNotContact: [],
      regions: [],
      scope: 'Default Scope',
      type: 'Default Type',
      estimatedCalls: 0,
      budgetCap: 0.0,
      emailBody: null,
      emailSubject: null,
      colleagues: [],
    );
  }
}

class Expense {
  final String name;
  final double cost;
  final String type;

  Expense({
    required this.name,
    required this.cost,
    required this.type,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      name: json['name'] as String,
      cost: (json['cost'] as num).toDouble(),
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cost': cost,
      'type': type,
    };
  }
}

class Angle {
  final String name;
  final String background;
  final int callLength;
  final List<String> exampleCompanies;
  final List<String> exampleRoles;
  final List<String> screeningQuestions;
  final String? aiMatchPrompt;
  final String preferredSeniority;
  final int estimatedCallCount;
  final String additionalDetails;

  Angle({
    required this.name,
    required this.background,
    required this.callLength,
    required this.exampleCompanies,
    required this.exampleRoles,
    required this.screeningQuestions,
    this.aiMatchPrompt,
    required this.preferredSeniority,
    required this.estimatedCallCount,
    required this.additionalDetails,
  });

  factory Angle.fromJson(Map<String, dynamic> json) {
    return Angle(
      name: json['name'] as String,
      background: json['background'] as String,
      callLength: json['callLength'] as int,
      exampleCompanies: (json['exampleCompanies'] as List<dynamic>)
          .map((item) => item as String)
          .toList(),
      exampleRoles: (json['exampleRoles'] as List<dynamic>)
          .map((item) => item as String)
          .toList(),
      screeningQuestions: (json['screeningQuestions'] as List<dynamic>)
          .map((item) => item as String)
          .toList(),
      aiMatchPrompt: json['aiMatchPrompt'] as String?,
      preferredSeniority: json['preferredSeniority'] as String,
      estimatedCallCount: json['estimatedCallCount'] as int,
      additionalDetails: json['additionalDetails'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'background': background,
      'callLength': callLength,
      'exampleCompanies': exampleCompanies,
      'exampleRoles': exampleRoles,
      'screeningQuestions': screeningQuestions,
      'aiMatchPrompt': aiMatchPrompt,
      'preferredSeniority': preferredSeniority,
      'estimatedCallCount': estimatedCallCount,
      'additionalDetails': additionalDetails,
    };
  }
}

class Colleague {
  final String name;
  final String email;
  final String role;
  final String angleName;
  bool calendarLinked;

  Colleague({
    required this.name,
    required this.email,
    required this.role,
    required this.angleName,
    required this.calendarLinked,
  });

  factory Colleague.fromJson(Map<String, dynamic> json) {
    return Colleague(
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      angleName: json['angleName'] as String,
      calendarLinked: json['calendarLinked'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'angleName': angleName,
      'calendarLinked': calendarLinked,
    };
  }
}

/*
class Workstream {
  final String name;
  final List<Colleague> colleagues;

  Workstream({required this.name, required this.colleagues});

  factory Workstream.fromJson(Map<String, dynamic> json) {
    return Workstream(
      name: json['name'] as String,
      colleagues: (json['colleagues'] as List)
          .map((item) => Colleague.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'colleagues':
            colleagues.map((colleague) => colleague.toJson()).toList(),
      };
}*/