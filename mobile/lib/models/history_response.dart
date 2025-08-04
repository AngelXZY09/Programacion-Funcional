import 'package:mobile/models/period_activities.dart';

class HistoryResponse {
  final int totalCreditos;
  final List<PeriodActivities> periodos;

  HistoryResponse({
    required this.totalCreditos,
    required this.periodos,
  });

  factory HistoryResponse.fromJson(Map<String, dynamic> json) {
    var periodosList = json['periodos'] as List? ?? [];
    List<PeriodActivities> periodActivitiesList = periodosList
        .map((i) => PeriodActivities.fromJson(i as Map<String, dynamic>))
        .toList();

    return HistoryResponse(
      totalCreditos: json['totalCreditos'] as int? ?? 0,
      periodos: periodActivitiesList,
    );
  }
} 