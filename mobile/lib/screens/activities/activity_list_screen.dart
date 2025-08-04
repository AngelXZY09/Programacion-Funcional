import 'package:flutter/material.dart';
import 'package:mobile/models/activities_response.dart';
import 'package:mobile/models/activity_view_model.dart';
import 'package:mobile/notifiers/filter_notifier.dart';
import 'package:mobile/screens/activities/activity_detail_screen.dart';
import 'package:mobile/services/activity_service.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

class ActivityListScreen extends StatefulWidget {
  const ActivityListScreen({super.key});

  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  late ActivityService _activityService;
  Future<ActivitiesResponse>? _activitiesFuture;
  String? _error;

  // Lista simulada de assets de imágenes de actividad existentes.
  // Idealmente, esto podría generarse o manejarse de forma más dinámica si tienes muchas imágenes.
  final List<String> _existingActivityImageAssets = [
    'Ajedrez.png',
    'Fútbol.png',
    'Talleres.png',
    'default_activity.png' // Asegurarse que la de por defecto esté aquí
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<FilterNotifier>(context, listen: false).addListener(_onFilterChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _activityService = Provider.of<ActivityService>(context, listen: false);
    _loadActivities();
  }

  @override
  void dispose() {
    Provider.of<FilterNotifier>(context, listen: false).removeListener(_onFilterChanged);
    super.dispose();
  }

  void _onFilterChanged() {
    if (mounted) {
      _loadActivities();
    }
  }

  void _loadActivities() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final filterNotifier = Provider.of<FilterNotifier>(context, listen: false);
    
    if (authService.isAuthenticated && authService.token != null) {
      // Usamos addPostFrameCallback para evitar llamar a setState durante un build.
      // Esto es más seguro, especialmente si _loadActivities se llama desde didChangeDependencies.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _error = null;
            _activitiesFuture = _activityService.getActivities(
              token: authService.token!,
              excluirInscritas: filterNotifier.excludeEnrolledOrFinished,
            ).catchError((e) {
              // Manejar el error dentro del futuro para que el FutureBuilder pueda mostrarlo
              // sin crashear si el futuro ya se completó con un error.
              if (mounted) {
                setState(() {
                  _error = e.toString();
                });
              }
              // Devolvemos una respuesta vacía para que el builder no intente acceder a datos nulos.
              return ActivitiesResponse(totalCreditos: 0, actividades: []);
            });
          });
        }
      });
    } else {
       WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _error = "Usuario no autenticado o token no disponible.";
            _activitiesFuture = Future.value(ActivitiesResponse(totalCreditos: 0, actividades: []));
          });
        }
       });
    }
  }

  String _getActivityImagePath(ActivityViewModel activity) {
    String baseAssetPath = 'assets/images/act/';
    String defaultImage = '${baseAssetPath}default_activity.png';

    // 1. Usar activity.urlImg si es un nombre de archivo válido en assets
    if (activity.urlImg != null && activity.urlImg!.isNotEmpty && !activity.urlImg!.startsWith('http')) {
      if (_existingActivityImageAssets.contains(activity.urlImg)) {
        return baseAssetPath + activity.urlImg!;
      }
    }

    // 2. Si la categoría es 'Talleres'
    if (activity.categoria?.toLowerCase() == 'talleres') {
      if (_existingActivityImageAssets.contains('Talleres.png')) {
        return '${baseAssetPath}Talleres.png';
      }
    }

    // 3. Intentar con activity.nombre + '.png'
    if (activity.nombre.isNotEmpty) {
      String imageNameFromName = '${activity.nombre}.png';
      if (_existingActivityImageAssets.contains(imageNameFromName)) {
        return baseAssetPath + imageNameFromName;
      }
      // Considerar casos comunes como Fútbol vs Futbol por si el nombre de la actividad no tiene acento
      if (activity.nombre.toLowerCase() == 'futbol' && _existingActivityImageAssets.contains('Fútbol.png')) {
          return '${baseAssetPath}Fútbol.png';
      }
    }

    // 4. Fallback a la imagen por defecto
    return defaultImage;
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final Color inscripcionColor = Theme.of(context).colorScheme.primary; 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividades Disponibles'),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<ActivitiesResponse>(
              future: _activitiesFuture,
              builder: (context, snapshot) {
                if (_error != null) {
                  return Center(child: Text('Error: $_error', style: TextStyle(color: Theme.of(context).colorScheme.error)));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar actividades: ${snapshot.error}', style: TextStyle(color: Theme.of(context).colorScheme.error)));
                }
                if (!snapshot.hasData || snapshot.data!.actividades.isEmpty) {
                  return const Center(child: Text('No hay actividades disponibles.'));
                }

                final activitiesResponse = snapshot.data!;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Text(
                        'Créditos Acumulados (Aprobados): ${authService.currentUser?.nombre != null ? activitiesResponse.totalCreditos : 'N/A'}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: activitiesResponse.actividades.length,
                        itemBuilder: (context, index) {
                          final activity = activitiesResponse.actividades[index];
                          final imagePath = _getActivityImagePath(activity);
                          final heroTag = 'activity_image_${activity.id}';

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () async {
                                // Se espera el resultado de la pantalla de detalles.
                                final shouldRefresh = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ActivityDetailScreen(activity: activity),
                                  ),
                                );
                                
                                // Si el resultado es 'true', se recarga la lista.
                                if (shouldRefresh == true) {
                                  _loadActivities();
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Hero(
                                      tag: heroTag,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: Image.asset(
                                          imagePath,
                                          width: 70, height: 70, fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            print("Error al cargar imagen local $imagePath: $error");
                                            return SizedBox(width: 70, height: 70, child: Icon(Icons.broken_image, size: 40, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)));
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(activity.nombre, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          Text('Categoría: ${activity.categoria ?? 'N/A'}', style: Theme.of(context).textTheme.bodySmall),
                                          Text('Créditos: ${activity.creditos}', style: Theme.of(context).textTheme.bodySmall),
                                          Text('Estado: ${activity.estado ?? 'N/A'} ${activity.estaInscrito ? '(Inscrito)' : ''}', 
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: activity.estaInscrito ? inscripcionColor : Theme.of(context).textTheme.bodySmall?.color, 
                                              fontWeight: activity.estaInscrito ? FontWeight.bold : null
                                            )
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color?.withOpacity(0.6)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 