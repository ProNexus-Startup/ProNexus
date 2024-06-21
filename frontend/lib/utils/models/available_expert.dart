class AvailableExpert {
  bool isSelected;
  bool favorite;

  final String expertId;
  String name;
  String organizationId;
  String projectId;
  String profession;
  String company;
  String? companyType;
  DateTime? startDate;
  String? description;
  String? geography;
  String? angle;
  String? status;
  int? aiAssessment;
  String? aiAnalysis;
  String? comments;
  List<Availability>? availabilities;
  String? expertNetworkName;
  double? cost;
  List<Question>? screeningQuestionsAndAnswers;
  List<Job>? employmentHistory;
  String? addedExpertBy;
  DateTime? dateAddedExpert;
  String? trends;
  String? linkedInLink;

  AvailableExpert(
      {this.isSelected = false,
      required this.expertId,
      required this.name,
      required this.organizationId,
      required this.projectId,
      this.favorite = false,
      required this.profession,
      required this.company,
      this.companyType,
      this.startDate,
      this.description,
      this.geography,
      this.angle,
      this.status,
      this.aiAssessment,
      this.aiAnalysis,
      this.comments,
      this.availabilities,
      this.expertNetworkName,
      this.cost,
      this.screeningQuestionsAndAnswers,
      this.employmentHistory,
      this.addedExpertBy,
      this.dateAddedExpert,
      this.trends,
      this.linkedInLink});

  factory AvailableExpert.defaultExpert() {
    return AvailableExpert(
      expertId: 'defaultId',
      name: 'Default Name',
      organizationId: 'defaultOrganizationId',
      projectId: 'defaultProjectId',
      profession: 'Default Profession',
      company: 'Default Company',
      companyType: 'Default Company Type',
      startDate: DateTime.now(),
      description: 'Default Description',
      geography: 'Default Geography',
      angle: 'Default Angle',
      status: 'Default Status',
      aiAssessment: 0,
      aiAnalysis: 'Default AI Analysis',
      comments: 'Default Comments',
      availabilities: [],
      expertNetworkName: 'Default Expert Network',
      cost: 0.0,
      screeningQuestionsAndAnswers: [],
      employmentHistory: [],
      addedExpertBy: 'Default Adder',
      dateAddedExpert: DateTime.now(),
      trends: 'Default Trends',
      linkedInLink: 'https://www.linkedin.com/default',
    );
  }
  factory AvailableExpert.fromJson(Map<String, dynamic> json) {
    var screeningQuestionsFromJson =
        json['screeningQuestionsAndAnswers'] as List<dynamic>?;
    List<Question> screeningQuestionsList = screeningQuestionsFromJson != null
        ? List<Question>.from(screeningQuestionsFromJson
            .map((question) => Question.fromJson(question)))
        : [];

    var availabilitiesFromJson = json['availabilities'] as List<dynamic>?;
    List<Availability> availabilitiesList = availabilitiesFromJson != null
        ? List<Availability>.from(availabilitiesFromJson
            .map((availability) => Availability.fromJson(availability)))
        : [];

    var employmentHistoryFromJson = json['employmentHistory'] as List<dynamic>?;
    List<Job> employmentHistoryList = employmentHistoryFromJson != null
        ? List<Job>.from(
            employmentHistoryFromJson.map((job) => Job.fromJson(job)))
        : [];

    return AvailableExpert(
      isSelected: json['isSelected'] ?? false,
      expertId: json['expertId'] ?? '',
      name: json['name'] ?? '',
      organizationId: json['organizationId'] ?? '',
      projectId: json['projectId'] ?? '',
      favorite: json['favorite'] ?? false,
      profession: json['profession'] ?? '',
      company: json['company'] ?? '',
      companyType: json['companyType'],
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      description: json['description'],
      geography: json['geography'],
      angle: json['angle'],
      status: json['status'],
      aiAssessment: json['aiAssessment'],
      aiAnalysis: json['aiAnalysis'],
      comments: json['comments'],
      availabilities: availabilitiesList,
      expertNetworkName: json['expertNetworkName'],
      cost: json['cost']?.toDouble(),
      screeningQuestionsAndAnswers: screeningQuestionsList,
      employmentHistory: employmentHistoryList,
      addedExpertBy: json['addedExpertBy'],
      dateAddedExpert: json['dateAddedExpert'] != null
          ? DateTime.parse(json['dateAddedExpert'])
          : null,
      trends: json['trends'],
      linkedInLink: json['linkedInLink'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expertId': expertId,
      'name': name,
      'organizationId': organizationId,
      'projectId': projectId,
      'favorite': favorite,
      'profession': profession,
      'company': company,
      'companyType': companyType,
      'startDate':
          startDate!.toIso8601String().replaceFirst(RegExp(r'\.\d+'), '') + 'Z',
      'description': description,
      'geography': geography,
      'angle': angle,
      'status': status,
      'aiAssessment': aiAssessment,
      'aiAnalysis': aiAnalysis,
      'comments': comments,
      'availabilities': availabilities?.map((a) => a.toJson()).toList(),
      'expertNetworkName': expertNetworkName,
      'cost': cost,
      'screeningQuestionsAndAnswers':
          screeningQuestionsAndAnswers?.map((q) => q.toJson()).toList(),
      'employmentHistory':
          employmentHistory?.map((job) => job.toJson()).toList(),
      'addedExpertBy': addedExpertBy,
      'dateAddedExpert': dateAddedExpert!
              .toIso8601String()
              .replaceFirst(RegExp(r'\.\d+'), '') +
          'Z',
      'trends': trends,
      'linkedInLink': linkedInLink,
    };
  }
}

class Question {
  String question;
  String answer;

  Question({required this.question, required this.answer});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
    };
  }
}

class Job {
  String role;
  String company;
  DateTime? startDate;
  DateTime? endDate;

  Job({
    required this.role,
    required this.company,
    this.startDate,
    this.endDate,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      role: json['Role'] ?? '', // Ensure this matches your JSON key
      company: json['Company'] ?? '', // Ensure this matches your JSON key
      startDate:
          json['StartDate'] != null ? DateTime.parse(json['StartDate']) : null,
      endDate: json['EndDate'] != null && json['EndDate'].isNotEmpty
          ? DateTime.parse(json['EndDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'company': company,
      'startDate':
          startDate!.toIso8601String().replaceFirst(RegExp(r'\.\d+'), '') + 'Z',
      'endDate':
          endDate!.toIso8601String().replaceFirst(RegExp(r'\.\d+'), '') + 'Z',
    };
  }
}

class Availability {
  DateTime? start;
  DateTime? end;
  String timeZone;

  Availability({
    this.start,
    this.end,
    required this.timeZone,
  });

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      start: json['start'] != null ? DateTime.parse(json['start']) : null,
      end: json['end'] != null ? DateTime.parse(json['end']) : null,
      timeZone: json['timeZone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start':
          start!.toIso8601String().replaceFirst(RegExp(r'\.\d+'), '') + 'Z',
      'end': end!.toIso8601String().replaceFirst(RegExp(r'\.\d+'), '') + 'Z',
      'timeZone': timeZone,
    };
  }
}
