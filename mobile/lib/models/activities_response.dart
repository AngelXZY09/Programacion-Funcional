import 'package:mobile/models/activity_view_model.dart';

class ActivitiesResponse {
  final int totalCreditos;
  final List<ActivityViewModel> actividades;

  ActivitiesResponse({
    required this.totalCreditos,
    required this.actividades,
  });

  factory ActivitiesResponse.fromJson(Map<String, dynamic> json) {
    var actividadesList = json['actividades'] as List? ?? [];
    List<ActivityViewModel> actividadesViewModel = actividadesList
        .map((i) => ActivityViewModel.fromJson(i as Map<String, dynamic>))
        .toList();

    return ActivitiesResponse(
      totalCreditos: json['totalCreditos'] as int? ?? 0,
      actividades: actividadesViewModel,
    );
  }
} 