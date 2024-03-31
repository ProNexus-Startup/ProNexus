/*import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants.dart';

class JobSummary {
  final String? svgSrc, title;
  final int? numOfJobs;
  final Color? color;

  JobSummary({
    this.svgSrc,
    this.title,
    this.numOfJobs,
    this.color,
  });
}

//math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0)
List<JobSummary> progressReport(Map<String, int> progressCounts) {
  return [
    JobSummary(
      title: "Acceptances",
      numOfJobs: progressCounts["Accepted"],
      svgSrc: "assets/icons/acceptance.svg",
      color: Color.fromARGB(255, 91, 196, 46),
    ),
    JobSummary(
      title: "Rejections",
      numOfJobs: progressCounts["Rejected"],
      svgSrc: "assets/icons/rejection.svg",
      color: Color.fromARGB(255, 255, 55, 19),
    ),
    JobSummary(
      title: "No Response",
      numOfJobs: progressCounts["No Response"],
      svgSrc: "assets/icons/in_progress.svg",
      color: Color.fromARGB(255, 220, 231, 153),
    ),
    JobSummary(
      title: "Interviewing",
      numOfJobs: progressCounts["Interviewing"],
      svgSrc: "assets/icons/interviewing.svg",
      color: Color(0xFF007EE5),
    ),
  ];
}

class FileInfoCard extends StatelessWidget {
  const FileInfoCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(defaultPadding * 0.75),
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: SvgPicture.asset(
                  info.svgSrc!,
                  colorFilter: ColorFilter.mode(
                      info.color ?? Colors.black, BlendMode.srcIn),
                ),
              ),
              Icon(Icons.more_vert)
            ],
          ),
          Text(
            info.title!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          /*ProgressLine(
            color: info.color,
            percentage: info.percentage,
          ),*/
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${info.numOfJobs} Jobs",
                  style: Theme.of(context).textTheme.bodySmall!),
              /*Text(
                info.totalStorage!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: Colors.white),
              ),*/
            ],
          )
        ],
      ),
    );
  }
}

class ProgressLine extends StatelessWidget {
  const ProgressLine({
    Key? key,
    required this.percentage,
  }) : super(key: key);

  final int? percentage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) => Container(
            width: constraints.maxWidth * (percentage! / 100),
            height: 5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}
*/