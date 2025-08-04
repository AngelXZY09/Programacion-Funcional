import 'package:mobile/models/activity_view_model.dart';

class PeriodActivities {
  final String periodo;
  final List<ActivityViewModel> actividades;

  PeriodActivities({
    required this.periodo,
    required this.actividades,
  });

  factory PeriodActivities.fromJson(Map<String, dynamic> json) {
    var actividadesList = json['actividades'] as List? ?? [];
    List<ActivityViewModel> actividadesViewModel = actividadesList
        .map((i) => ActivityViewModel.fromJson(i as Map<String, dynamic>))
        .toList();

    return PeriodActivities(
      periodo: json['periodo'] as String? ?? 'Periodo no especificado',
      actividades: actividadesViewModel,
    );
  }
} 