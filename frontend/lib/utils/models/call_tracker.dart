import 'package:admin/utils/models/available_expert.dart';

class CallTracker {
  bool isSelected;
  bool favorite;
  String id;
  String? name;
  String? projectId;
  String? organizationId;
  String? profession;
  String? company;
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
  String? linkedInLink;
  String? trends;
  String? addedCallBy;
  DateTime? dateAddedCall;
  bool inviteSent;
  DateTime? meetingStartDate;
  DateTime? meetingEndDate;
  bool? paidStatus;
  int? rating;

  CallTracker({
    this.isSelected = false,
    required this.id,
    this.name,
    this.projectId,
    this.favorite = false,
    this.organizationId,
    this.profession,
    this.company,
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
    this.addedCallBy,
    this.dateAddedCall,
    this.inviteSent = false,
    this.meetingStartDate,
    this.meetingEndDate,
    this.paidStatus,
    this.rating,
    this.linkedInLink,
  });

  factory CallTracker.fromJson(Map<String, dynamic> json) {
    return CallTracker(
      isSelected: json['isSelected'] ?? false,
      id: json['expertId'],
      name: json['name'],
      projectId: json['projectId'],
      favorite: json['favorite'] ?? false,
      organizationId: json['organizationId'],
      profession: json['profession'],
      company: json['company'],
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
      availabilities: json['availabilities'] != null
          ? List<Availability>.from(
              json['availabilities'].map((x) => Availability.fromJson(x)))
          : null,
      expertNetworkName: json['expertNetworkName'],
      cost: json['cost']?.toDouble(),
      screeningQuestionsAndAnswers: json['screeningQuestionsAndAnswers'] != null
          ? List<Question>.from(json['screeningQuestionsAndAnswers']
              .map((x) => Question.fromJson(x)))
          : null,
      employmentHistory: json['employmentHistory'] != null
          ? List<Job>.from(
              json['employmentHistory'].map((x) => Job.fromJson(x)))
          : null,
      addedExpertBy: json['addedExpertBy'],
      dateAddedExpert: json['dateAddedExpert'] != null
          ? DateTime.parse(json['dateAddedExpert'])
          : null,
      trends: json['trends'],
      addedCallBy: json['addedCallBy'],
      dateAddedCall: json['dateAddedCall'] != null
          ? DateTime.parse(json['dateAddedCall'])
          : null,
      inviteSent: json['inviteSent'] ?? false,
      meetingStartDate: json['meetingStartDate'] != null
          ? DateTime.parse(json['meetingStartDate'])
          : null,
      meetingEndDate: json['meetingEndDate'] != null
          ? DateTime.parse(json['meetingEndDate'])
          : null,
      paidStatus: json['paidStatus'],
      rating: json['rating'],
      linkedInLink: json['linkedInLink'],
    );
  }

  factory CallTracker.defaultCall() {
    return CallTracker(
      id: 'default_id',
      isSelected: false,
      favorite: false,
      name: 'Default Name',
      projectId: 'default_project_id',
      organizationId: 'default_organization_id',
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
      expertNetworkName: 'Default Expert Network Name',
      cost: 0.0,
      screeningQuestionsAndAnswers: [],
      employmentHistory: [],
      addedExpertBy: 'Default Added Expert By',
      dateAddedExpert: DateTime.now(),
      trends: 'Default Trends',
      addedCallBy: 'Default Added Call By',
      dateAddedCall: DateTime.now(),
      inviteSent: false,
      meetingStartDate: DateTime.now(),
      meetingEndDate: DateTime.now(),
      paidStatus: false,
      rating: 0,
      linkedInLink: 'default_linkedin_link',
    );
  }
}
