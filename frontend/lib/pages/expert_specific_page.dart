import 'package:admin/pages/components/header.dart';
import 'package:admin/pages/components/sub_menu.dart';
import 'package:admin/utils/models/available_expert.dart';
import 'package:admin/utils/models/call_tracker.dart';
import 'package:admin/utils/persistence/global_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ExpertSpecificPage extends StatefulWidget {
  final String token;
  static const routeName = '/expert-specific';

  const ExpertSpecificPage({Key? key, required this.token}) : super(key: key);

  @override
  _ExpertSpecificPageState createState() => _ExpertSpecificPageState();
}

class _ExpertSpecificPageState extends State<ExpertSpecificPage> {
  late AvailableExpert expert = AvailableExpert.defaultExpert();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final GlobalBloc globalBloc =
        Provider.of<GlobalBloc>(context, listen: false);
    globalBloc.onUserLogin(widget.token);

    String expertId = prefs.getString('expert_string') ?? '';
    if (expertId.isNotEmpty) {
      AvailableExpert? newExpert = globalBloc.unfilteredExpertList.firstWhere(
          (expert) => expertId.contains(expert.expertId),
          orElse: () => AvailableExpert.defaultExpert());

      CallTracker? newCall = globalBloc.unfilteredCallList.firstWhere(
          (call) => expertId.contains(call.id),
          orElse: () => CallTracker.defaultCall());

      if (newExpert != AvailableExpert.defaultExpert()) {
        setState(() {
          expert = newExpert;
        });
      } else if (newCall != CallTracker.defaultCall()) {
        setState(() {
          expert =
              getAvailableExpert(newCall) ?? AvailableExpert.defaultExpert();
        });
      }
    }
  }

  AvailableExpert? getAvailableExpert(CallTracker callTracker) {
    if (callTracker.availabilities != null &&
        callTracker.availabilities!.isNotEmpty) {
      return AvailableExpert(
        isSelected: callTracker.isSelected,
        expertId: callTracker.id,
        name: callTracker.name ?? '',
        organizationId: callTracker.organizationId ?? '',
        projectId: callTracker.projectId ?? '',
        favorite: callTracker.favorite,
        profession: callTracker.profession ?? '',
        company: callTracker.company ?? '',
        companyType: callTracker.companyType,
        startDate: callTracker.startDate,
        description: callTracker.description,
        geography: callTracker.geography,
        angle: callTracker.angle,
        status: callTracker.status,
        aiAssessment: callTracker.aiAssessment,
        aiAnalysis: callTracker.aiAnalysis,
        comments: callTracker.comments,
        availabilities: callTracker.availabilities,
        expertNetworkName: callTracker.expertNetworkName,
        cost: callTracker.cost,
        screeningQuestionsAndAnswers: callTracker.screeningQuestionsAndAnswers,
        employmentHistory: callTracker.employmentHistory,
        addedExpertBy: callTracker.addedExpertBy,
        dateAddedExpert: callTracker.dateAddedExpert,
        trends: callTracker.trends,
        linkedInLink: callTracker.linkedInLink,
      );
    }
    return null;
  }

  String getFormattedDateRange(Job job) {
    String start = job.startDate != null
        ? '${job.startDate!.month}/${job.startDate!.year}'
        : '';
    String end = job.endDate != null
        ? '${job.endDate!.month}/${job.endDate!.year}'
        : 'Present';
    return '$start - $end';
  }

  Color _getMatchColor(int matchPercentage) {
    if (matchPercentage <= 50) {
      return Colors.red;
    } else if (matchPercentage <= 75) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }

  void _launchURL(String url) async {
    if (!await launch(url)) throw 'Could not launch $url';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: TopMenu(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SubMenu(
              token: widget.token,
            ),
            const SizedBox(width: 55),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Container(
                        color: Colors.grey[200],
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (expert.startDate != null)
                              Text(
                                '${expert.company} - ${expert.profession} (${DateFormat.MMMM().format(expert.startDate!)}, ${expert.startDate?.year} - Present)',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(
                                      expert.name), // Use NetworkImage directly
                                ),
                                SizedBox(width: 16),
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            expert.name,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                          SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () {
                                              _launchURL(
                                                  expert.linkedInLink ?? '');
                                            },
                                            child: Image.asset(
                                              'icons/linkedin.webp', // Add the path to your LinkedIn logo
                                              width: 24,
                                              height: 24,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'With 20 years in the hotel industry and currently leading procurement, this expert specializes in selecting high-end amenities, notably Aesop soaps and L\'Occitane skincare products, ensuring guest satisfaction and sustainability',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Column(
                              children: expert.screeningQuestionsAndAnswers!
                                  .map((q) => _buildQuestionAnswer(q))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // Right Column
                  Flexible(
                    fit: FlexFit.loose,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Container(
                        color: Colors.grey[200],
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.business),
                                    SizedBox(width: 8),
                                    Text(
                                      expert.expertNetworkName ?? '',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.star_border),
                                      onPressed: () {
                                        // Implement favorite button functionality here
                                      },
                                    ),
                                    Text(
                                      'Favorite',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.mail_outline),
                                SizedBox(width: 8),
                                Text(
                                  '${expert.aiAssessment}% match',
                                  style: TextStyle(
                                    color: _getMatchColor(
                                        expert.aiAssessment ?? 50),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.person_outline),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'AI analysis:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            Text(expert.aiAnalysis.toString()),
                            SizedBox(height: 16),
                            Text(
                              'Team comments:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(expert.comments.toString()),
                            SizedBox(height: 16),
                            Text(
                              'Expert network comments:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            // Bottom Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Container(
                  color: Colors.grey[200],
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var job in expert.employmentHistory ?? []) ...[
                        _buildResumeItem(
                          role: job.role,
                          company: job.company,
                          years: getFormattedDateRange(job),
                        ),
                        Divider(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionAnswer(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 12,
                child: Text(
                  (expert.screeningQuestionsAndAnswers!.indexOf(question) + 1)
                      .toString(),
                  style: TextStyle(fontSize: 12),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  question.question,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32.0, top: 8, bottom: 16),
          child: Text(question.answer),
        ),
      ],
    );
  }

  Widget _buildExpertNetwork(String network, String match, String analysis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.network_check),
            SizedBox(width: 8),
            Expanded(
                child: Text(network,
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.thumb_up),
            SizedBox(width: 8),
            Expanded(
                child: Text('Match: $match',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.description),
            SizedBox(width: 8),
            Expanded(child: Text(analysis)),
          ],
        ),
      ],
    );
  }

  Widget _buildResumeItem(
      {required String role, required String company, required String years}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(role, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(years, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Text(company),
      ],
    );
  }
}
