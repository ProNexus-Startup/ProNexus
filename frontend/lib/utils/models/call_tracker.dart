import 'package:flutter/material.dart';

class CallTracker {
  final String expertId;
  final String name;
  final String projectId;
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
  final List<String> screeningQuestions;
  bool inviteSent;
  DateTime meetingDate;
  TimeOfDay meetingTime;
  Duration meetingLength;
  String companyType;
  bool paidStatus;
  String quoteAttribution;
  int rating;

  CallTracker(
      {required this.expertId,
      required this.name,
      required this.projectId,
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
      required this.inviteSent,
      required this.meetingDate,
      required this.meetingTime,
      required this.meetingLength,
      required this.companyType,
      required this.paidStatus,
      required this.quoteAttribution,
      required this.rating});

  Map<String, dynamic> toJson() {
    return {
      'expertId': expertId,
      'name': name,
      'favorite': favorite,
      'title': title,
      'company': company,
      'yearsAtCompany': yearsAtCompany,
      'description': description,
      'geography': geography,
      'angle': angle,
      'status': status,
      'AIAssessment': AIAssessment,
      'comments': comments,
      'availability': availability,
      'expertNetworkName': expertNetworkName,
      'cost': cost,
      'screeningQuestions': screeningQuestions,
      'inviteSent': inviteSent,
      'meetingDate':
          meetingDate.toIso8601String(), // Convert DateTime to ISO-8601 string
      'meetingTime':
          "${meetingTime.hour}:${meetingTime.minute}", // Format TimeOfDay to a string
      'meetingLength': meetingLength.inMinutes, // Convert Duration to minutes
      'companyType': companyType,
      'paidStatus': paidStatus,
      'quoteAttribution': quoteAttribution,
      'rating': rating,
    };
  }

  factory CallTracker.fromJson(Map<String, dynamic> json) {
    // Ensure screeningQuestions is cast to List<String>
    var screeningQuestionsFromJson = json['screeningQuestions'];
    List<String> screeningQuestionsList = [];
    if (screeningQuestionsFromJson != null) {
      screeningQuestionsList = List<String>.from(
          screeningQuestionsFromJson.map((question) => question.toString()));
    }
    DateTime parsedMeetingDate = DateTime.parse(json['meetingDate']);
    List<String> splitMeetingTime = json['meetingTime'].split(':');
    TimeOfDay parsedMeetingTime = TimeOfDay(
        hour: int.parse(splitMeetingTime[0]),
        minute: int.parse(splitMeetingTime[1]));
    Duration parsedMeetingLength = Duration(minutes: json['meetingLength']);

    return CallTracker(
      expertId: json['expertId'],
      name: json['name'],
      projectId: json['project'],
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
      screeningQuestions: screeningQuestionsList,
      inviteSent: json['inviteSent'],
      meetingDate: parsedMeetingDate,
      meetingTime: parsedMeetingTime,
      meetingLength: parsedMeetingLength,
      companyType: json['companyType'],
      paidStatus: json['paidStatus'],
      quoteAttribution: json['quoteAttribution'],
      rating: json['rating'],
    );
  }
}
