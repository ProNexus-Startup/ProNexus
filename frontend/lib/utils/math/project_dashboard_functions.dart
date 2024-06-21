import 'package:admin/utils/models/call_tracker.dart';

List<String> getUniqueAngles(List<CallTracker> callList) {
  return callList
      .map((expert) => expert.angle)
      .where((angle) => angle != null)
      .toSet()
      .cast<String>()
      .toList();
}

List<String> getUniqueExpertNetworks(List<CallTracker> callList) {
  return callList
      .map((expert) => expert.expertNetworkName)
      .where((expertNetworkName) => expertNetworkName != null)
      .toSet()
      .cast<String>()
      .toList();
}

List<List<String>> countByAngle(
    List<CallTracker> callList, List<String> angles) {
  List<List<String>> result = [];
  int totalCompletedCount = 0;
  int totalScheduledCount = 0;

  for (var angle in angles) {
    int completedCount = 0;
    int scheduledCount = 0;

    for (var call in callList) {
      if (call.angle == angle) {
        if (call.status == 'Completed') {
          completedCount++;
        } else if (call.status == 'Scheduled') {
          scheduledCount++;
        }
      }
    }

    int totalCount = completedCount + scheduledCount;
    totalCompletedCount += completedCount;
    totalScheduledCount += scheduledCount;

    result.add([
      angle,
      completedCount.toString(),
      scheduledCount.toString(),
      totalCount.toString()
    ]);
  }

  int totalOverallCount = totalCompletedCount + totalScheduledCount;

  // Add the summary row
  result.add([
    "Total",
    totalCompletedCount.toString(),
    totalScheduledCount.toString(),
    totalOverallCount.toString(),
    "null"
  ]);

  return result;
}

List<List<String>> sumPriceByNetwork(
    List<CallTracker> callList, List<String> expertNetworks) {
  List<List<String>> results = [];
  double grandTotalCompleted = 0.0;
  double grandTotalScheduled = 0.0;

  for (var expertNetwork in expertNetworks) {
    double totalCompleted = 0.0;
    double totalScheduled = 0.0;

    for (var call in callList) {
      if (call.expertNetworkName == expertNetwork) {
        if (call.status?.toLowerCase() == 'Completed') {
          totalCompleted += call.cost!;
        } else if (call.status?.toLowerCase() == 'Scheduled') {
          totalScheduled += call.cost!;
        }
      }
    }

    double sumOfCosts = totalCompleted + totalScheduled;
    grandTotalCompleted += totalCompleted;
    grandTotalScheduled += totalScheduled;

    results.add([
      expertNetwork,
      totalCompleted.toString(),
      totalScheduled.toString(),
      sumOfCosts.toString()
    ]);
  }

  double grandSumOfCosts = grandTotalCompleted + grandTotalScheduled;
  results.add([
    'Summary',
    grandTotalCompleted.toString(),
    grandTotalScheduled.toString(),
    grandSumOfCosts.toString()
  ]);

  return results;
}
