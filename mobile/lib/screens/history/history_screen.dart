import 'package:flutter/material.dart';
import 'package:mobile/models/history_response.dart';
import 'package:mobile/services/activity_service.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late ActivityService _activityService;
  Future<HistoryResponse>? _historyFuture;
  String? _error;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _activityService = Provider.of<ActivityService>(context, listen: false);
    _loadHistory();
  }

  void _loadHistory() {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.isAuthenticated && authService.token != null) {
      setState(() {
        _error = null;
        _historyFuture = _activityService.getHistory(token: authService.token!);
      });
    } else {
      setState(() {
        _error = "Usuario no autenticado o token no disponible.";
        _historyFuture = Future.value(HistoryResponse(totalCreditos: 0, periodos: []));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final iconThemeColor = Theme.of(context).iconTheme.color;
    final errorColor = Theme.of(context).colorScheme.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Actividades'),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<HistoryResponse>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (_error != null) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: $_error', style: textTheme.bodyLarge?.copyWith(color: errorColor, fontSize: 16)),
            ));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error al cargar el historial: ${snapshot.error}', textAlign: TextAlign.center, style: textTheme.bodyLarge?.copyWith(color: errorColor, fontSize: 16)),
            ));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No se pudieron cargar los datos del historial.', style: textTheme.bodyLarge));
          }

          final historyResponse = snapshot.data!;

          if (historyResponse.periodos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_toggle_off, size: 60, color: iconThemeColor?.withOpacity(0.6)),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes actividades registradas en tu historial.',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total de créditos acumulados: ${historyResponse.totalCreditos}',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Total de Créditos Acumulados: ${historyResponse.totalCreditos}',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: historyResponse.periodos.length,
                  itemBuilder: (context, index) {
                    final periodActivities = historyResponse.periodos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                      elevation: 2,
                      child: ExpansionTile(
                        title: Text(
                          periodActivities.periodo,
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        children: periodActivities.actividades.map((activity) {
                          return ListTile(
                            leading: activity.urlImg != null && activity.urlImg!.isNotEmpty
                                ? Image.network(
                                    activity.urlImg!,
                                    width: 40, height: 40, fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, st) => Icon(Icons.broken_image, size: 40, color: iconThemeColor?.withOpacity(0.5)),
                                  )
                                : Icon(Icons.event_note, size: 40, color: iconThemeColor),
                            title: Text(activity.nombre, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500)),
                            subtitle: Text(
                              'Categoría: ${activity.categoria ?? 'N/A'} - Créditos: ${activity.creditos}\n'
                              'Estado: ${activity.estado ?? 'N/A'}',
                              style: textTheme.bodySmall,
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 