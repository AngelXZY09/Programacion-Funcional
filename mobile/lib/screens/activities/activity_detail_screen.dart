import 'package:flutter/material.dart';
import 'package:mobile/models/activity_view_model.dart';
import 'package:mobile/models/activity_with_details.dart';
import 'package:mobile/models/datos_inscripcion.dart';
import 'package:mobile/models/grupo_horario_vista.dart';
import 'package:mobile/models/horario_detalle_vista.dart';
import 'package:mobile/models/inscripcion_request_dto.dart';
import 'package:mobile/models/tipo_de_horario.dart';
import 'package:mobile/models/update_enrollment_dto.dart';
import 'package:mobile/services/activity_service.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:provider/provider.dart';

class ActivityDetailScreen extends StatefulWidget {
  final ActivityViewModel activity;

  const ActivityDetailScreen({super.key, required this.activity});

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  // --- Services ---
  late final ActivityService _activityService;
  late final AuthService _authService;

  // --- State Variables ---
  Future<ActivityWithDetails>? _activityDetailsFuture;
  
  // Form selection state
  GrupoHorarioVista? _selectedGrupoHorario;
  String? _selectedDateString;
  HorarioDetalleVista? _selectedHorarioDetalle;
  
  // Dynamic lists for dropdowns
  List<String> _availableDates = [];
  List<HorarioDetalleVista> _availableHorarioDetalles = [];

  // UI state
  bool _isLoadingEnrollment = false;
  bool _isLoadingModification = false;
  bool _isLoadingDeletion = false;
  bool _isModifyingEnrollment = false;
  String? _userMessage;
  
  // --- Constants ---
  static const List<String> _existingActivityImageAssets = [
    'Ajedrez.png',
    'Fútbol.png',
    'Talleres.png',
    'default_activity.png'
  ];

  @override
  void initState() {
    super.initState();
    _activityService = Provider.of<ActivityService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    _fetchActivityDetails();
  }

  // --- Data Fetching ---
  void _fetchActivityDetails() {
    if (_authService.token == null) {
      setState(() {
        _activityDetailsFuture = Future.error('No se pudo obtener el token de autenticación.');
      });
      return;
    }
    setState(() {
      _activityDetailsFuture = _activityService.getActivityDetails(
        token: _authService.token!,
        activityId: widget.activity.id,
      );
      _resetSelectionsAndMessages();
      _isModifyingEnrollment = false;
    });
  }

  // --- State Management Helpers ---
  void _resetSelectionsAndMessages() {
    setState(() {
      _selectedGrupoHorario = null;
      _selectedDateString = null;
      _selectedHorarioDetalle = null;
      _availableDates = [];
      _availableHorarioDetalles = [];
      _userMessage = null;
    });
  }

  void _onGrupoHorarioChanged(GrupoHorarioVista? newGrupo) {
    setState(() {
      _selectedGrupoHorario = newGrupo;
      _selectedDateString = null;
      _selectedHorarioDetalle = null;
      _availableDates = [];
      _availableHorarioDetalles = [];
      _userMessage = null;

      if (newGrupo == null) return;

      switch (newGrupo.tipoDeHorario) {
        case TipoDeHorario.PorFecha:
          final allDates = newGrupo.detalles
              .where((d) => d.fecha != null && d.fecha!.isNotEmpty)
              .map((d) => d.fecha!)
              .toSet()
              .toList();
          allDates.sort();
          _availableDates = allDates;
          if (_availableDates.length == 1) {
            _onDateChanged(_availableDates.first);
          }
          break;
        case TipoDeHorario.Semanal:
        case TipoDeHorario.Unico:
          _availableHorarioDetalles = newGrupo.detalles;
          if (_availableHorarioDetalles.length == 1) {
            _selectedHorarioDetalle = _availableHorarioDetalles.first;
          }
          break;
        case TipoDeHorario.Desconocido:
          break;
      }
    });
  }

  void _onDateChanged(String? newDateString) {
    setState(() {
      _selectedDateString = newDateString;
      _selectedHorarioDetalle = null;
      _availableHorarioDetalles = [];
      _userMessage = null;

      if (newDateString != null && _selectedGrupoHorario != null) {
        _availableHorarioDetalles = _selectedGrupoHorario!.detalles
            .where((d) => d.fecha == newDateString)
            .toList();
        if (_availableHorarioDetalles.length == 1) {
          _selectedHorarioDetalle = _availableHorarioDetalles.first;
        }
      }
    });
  }

  void _onHorarioDetalleChanged(HorarioDetalleVista? newDetalle) {
    setState(() {
      _selectedHorarioDetalle = newDetalle;
      _userMessage = null;
    });
  }

  // --- API Call Handlers ---
  Future<void> _enrollToActivity(int activityId) async {
    if (_selectedGrupoHorario == null || _selectedHorarioDetalle == null || _authService.token == null) {
      _showSnackBar('Por favor, selecciona un grupo y un horario específico.', isError: true);
      return;
    }

    setState(() => _isLoadingEnrollment = true);

    final dto = InscripcionRequestDto(
      idActividad: activityId,
      idGrupoHorario: _selectedGrupoHorario!.grupoHorarioId,
      idHorarioDetalle: _selectedHorarioDetalle!.id,
    );

    try {
      final result = await _activityService.enrollToActivity(token: _authService.token!, inscripcionDto: dto);
      _showSnackBar(result['message'] as String? ?? 'Respuesta desconocida.', isError: result['success'] != true);
      if (result['success'] == true) {
        _fetchActivityDetails();
      }
    } catch (e) {
      _showSnackBar('Error al intentar inscribirse: ${e.toString()}', isError: true);
    } finally {
      if(mounted) setState(() => _isLoadingEnrollment = false);
    }
  }
  
  Future<void> _updateEnrollment(int inscripcionId, int activityId) async {
    if (_selectedGrupoHorario == null || _selectedHorarioDetalle == null || _authService.token == null) {
       _showSnackBar('Por favor, selecciona un nuevo grupo y horario.', isError: true);
      return;
    }

    setState(() => _isLoadingModification = true);

    final dto = UpdateEnrollmentDto(
      idActividad: activityId,
      idGrupoHorario: _selectedGrupoHorario!.grupoHorarioId,
      idHorarioDetalle: _selectedHorarioDetalle!.id,
      aprobado: false, 
    );

    try {
      final result = await _activityService.updateEnrollment(token: _authService.token!, inscripcionId: inscripcionId, updateDto: dto);
       _showSnackBar(result['message'] as String? ?? 'Respuesta desconocida.', isError: result['success'] != true);
      if (result['success'] == true) {
        _fetchActivityDetails(); // Recarga para salir del modo modificación y ver los nuevos datos
      }
    } catch (e) {
       _showSnackBar('Error al actualizar la inscripción: ${e.toString()}', isError: true);
    } finally {
      if(mounted) setState(() => _isLoadingModification = false);
    }
  }

  Future<void> _handleDeleteEnrollment(int inscripcionId) async {
    if (_authService.token == null) return;
    setState(() => _isLoadingDeletion = true);
    
    try {
      final result = await _activityService.deleteEnrollment(token: _authService.token!, inscripcionId: inscripcionId);
      _showSnackBar(result['message'] as String? ?? 'Respuesta desconocida.', isError: result['success'] != true);
      if (result['success'] == true) {
        _fetchActivityDetails();
      }
    } catch(e) {
      _showSnackBar('Error al eliminar la inscripción: ${e.toString()}', isError: true);
    } finally {
      if(mounted) setState(() => _isLoadingDeletion = false);
    }
  }

  // --- UI Helpers ---
  void _showSnackBar(String message, {bool isError = false}) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Theme.of(context).colorScheme.error : Colors.green[700],
        ),
      );
  }

  void _confirmDeleteEnrollment(int inscripcionId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Cancelación'),
        content: const Text('¿Estás seguro de que quieres cancelar tu inscripción?'),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            child: Text('Sí, Cancelar', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _handleDeleteEnrollment(inscripcionId);
            },
          ),
        ],
      ),
    );
  }

  void _toggleModificationMode(bool modify, ActivityWithDetails? details) {
    setState(() {
      _isModifyingEnrollment = modify;
      _resetSelectionsAndMessages();

      if (modify && details?.datosInscripcion != null) {
        final datos = details!.datosInscripcion!;
        try {
          final currentGroup = details.gruposHorarioVista.firstWhere((g) => g.grupoHorarioId == datos.idHorario);
          _onGrupoHorarioChanged(currentGroup);

          if (currentGroup.tipoDeHorario == TipoDeHorario.PorFecha) {
              final currentDetailForDate = currentGroup.detalles.firstWhere((d) => d.id == datos.idHorarioDetalle, orElse: () => HorarioDetalleVista(id: -1, grupoHorarioId: -1));
              final currentDate = currentDetailForDate.fecha;
              if (currentDate != null && _availableDates.contains(currentDate)) {
                  _onDateChanged(currentDate);
              }
          }
          
          final listToSearch = _availableHorarioDetalles.isNotEmpty ? _availableHorarioDetalles : currentGroup.detalles;
          final currentDetail = listToSearch.firstWhere((d) => d.id == datos.idHorarioDetalle, orElse: () => HorarioDetalleVista(id: -1, grupoHorarioId: -1));

          if (currentDetail.id != -1) {
            _selectedHorarioDetalle = currentDetail;
          }

        } catch (e) {
          _showSnackBar("No se pudo pre-seleccionar tu horario actual.", isError: true);
          _resetSelectionsAndMessages();
        }
      }
    });
  }

  String _determineAssetPath(String? urlImg, String? categoria, String? nombreActividad) {
    const baseAssetPath = 'assets/images/act/';
    const defaultImage = '${baseAssetPath}default_activity.png';
    
    if (urlImg != null && urlImg.isNotEmpty) {
      if (urlImg.startsWith('http')) return urlImg; 
      if (_existingActivityImageAssets.contains(urlImg)) return baseAssetPath + urlImg;
    }
    if (categoria?.toLowerCase() == 'talleres' && _existingActivityImageAssets.contains('Talleres.png')) {
      return '${baseAssetPath}Talleres.png';
    }
    if (nombreActividad != null && nombreActividad.isNotEmpty) {
      String imageNameFromName = '$nombreActividad.png';
      if (_existingActivityImageAssets.contains(imageNameFromName)) {
        return baseAssetPath + imageNameFromName;
      }
    }
    return defaultImage;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity.nombre),
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ),
      body: FutureBuilder<ActivityWithDetails>(
        future: _activityDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error al cargar detalles: ${snapshot.error}', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No hay detalles disponibles para esta actividad.'));
          }

          final details = snapshot.data!;
          final imagePath = _determineAssetPath(details.imagenUrl, details.nombreCategoria, details.nombreActividad);
          final bool isFinalizada = details.estado?.toLowerCase() == 'finalizada';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildActivityHeader(context, details, imagePath),
                const Divider(height: 32, thickness: 1),
                
                if (details.datosInscripcion != null && !_isModifyingEnrollment)
                  _buildCurrentEnrollmentSection(context, details, isFinalizada: isFinalizada)
                else if (isFinalizada)
                  _buildFinalizedActivityCard(context)
                else
                  _buildEnrollmentOrModificationSection(context, details),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityHeader(BuildContext context, ActivityWithDetails details, String imagePath) {
    final textTheme = Theme.of(context).textTheme;

    String? _formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return null;
      try {
        final parts = dateStr.split('-');
        if (parts.length == 3) return '${parts[2]}-${parts[1]}-${parts[0]}';
        return dateStr;
      } catch (e) {
        return dateStr;
      }
    }

    String? formatDateRange() {
      final fInicio = _formatDate(details.fechaInicio);
      final fFinal = _formatDate(details.fechaFinal);

      if (fInicio != null && fFinal != null) {
        return 'Del $fInicio al $fFinal';
      } else if (fInicio != null) {
        return 'Inicia el $fInicio';
      } else if (fFinal != null) {
        return 'Finaliza el $fFinal';
      }
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Hero(
            tag: 'activity_image_${widget.activity.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: imagePath.startsWith('http')
                  ? Image.network(
                      imagePath, height: 200, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 100),
                    )
                  : Image.asset(
                      imagePath, height: 200, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 100),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(details.nombreActividad, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        // --- SECCIÓN DE ESTADO DE APROBACIÓN ---
        if (details.estado?.toLowerCase() == 'finalizada' && details.datosInscripcion?.aprobado != null)
          _buildApprovalStatusCard(context, details.datosInscripcion!.aprobado!),
        
        _buildInfoRow(context, Icons.person_outline, 'Encargado', details.nombreEncargado),
        _buildInfoRow(context, Icons.star_outline, 'Créditos', details.creditos.toString()),
        _buildInfoRow(context, Icons.category_outlined, 'Categoría', details.nombreCategoria),
        _buildInfoRow(context, Icons.location_on_outlined, 'Instalación', details.instalacion),
        _buildInfoRow(context, Icons.flag_outlined, 'Estado', details.estado),
        _buildInfoRow(context, Icons.date_range_outlined, 'Periodo', formatDateRange()),
        const SizedBox(height: 16),
        Text(details.descripcion ?? 'No hay descripción disponible.', style: textTheme.bodyLarge),
        if (details.datosExtra != null && details.datosExtra!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildInfoCard(context, 'Información Adicional', details.datosExtra!),
        ]
      ],
    );
  }

  Widget _buildApprovalStatusCard(BuildContext context, bool isApproved) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color successColor = isDark ? Colors.green.shade200 : Colors.green.shade800;
    final Color successBgColor = isDark ? Colors.green.shade900.withOpacity(0.5) : Colors.green.shade100;
    final Color errorColor = isDark ? Colors.red.shade200 : Colors.red.shade800;
    final Color errorBgColor = isDark ? Colors.red.shade900.withOpacity(0.5) : Colors.red.shade100;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: isApproved ? successBgColor : errorBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isApproved ? successColor : errorColor, width: 1),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              isApproved ? Icons.check_circle_outline : Icons.highlight_off_outlined,
              color: isApproved ? successColor : errorColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isApproved ? 'Actividad Aprobada' : 'Actividad No Aprobada',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isApproved ? successColor : errorColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                     isApproved ? '¡Felicidades! Has completado y aprobado la actividad.' : 'Has completado la actividad, pero no fue aprobada.',
                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                       color: isApproved ? successColor : errorColor,
                     )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: '$label: ',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: value,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String content) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(content, style: textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentEnrollmentSection(BuildContext context, ActivityWithDetails details, {required bool isFinalizada}) {
    final textTheme = Theme.of(context).textTheme;
    final datosInscripcion = details.datosInscripcion!;
    
    // Usar try-catch es más seguro que 'firstWhere' con 'orElse' si los datos son inconsistentes.
    GrupoHorarioVista? grupoInscrito;
    HorarioDetalleVista? detalleInscrito;
    try {
      grupoInscrito = details.gruposHorarioVista.firstWhere((gh) => gh.grupoHorarioId == datosInscripcion.idHorario);
      detalleInscrito = grupoInscrito.detalles.firstWhere((d) => d.id == datosInscripcion.idHorarioDetalle);
    } catch (e) {
      return Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: No se pudo encontrar la información de tu inscripción actual.', style: TextStyle(color: Theme.of(context).colorScheme.onError)))
      );
    }
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ya estás inscrito:', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Grupo: ${grupoInscrito.descripcionAmigable}', style: textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text('Horario: ${detalleInscrito.descripcion}', style: textTheme.bodyLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0, runSpacing: 8.0, alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit_calendar), 
                  label: const Text('Modificar'),
                  onPressed: isFinalizada || _isLoadingDeletion ? null : () => _toggleModificationMode(true, details),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.cancel_outlined, color: Theme.of(context).colorScheme.onError),
                  label: Text('Cancelar', style: TextStyle(color: Theme.of(context).colorScheme.onError)),
                  onPressed: isFinalizada || _isLoadingModification || datosInscripcion.inscripcionId == null ? null : () => _confirmDeleteEnrollment(datosInscripcion.inscripcionId!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    disabledBackgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.5)
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFinalizedActivityCard(BuildContext context) {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Theme.of(context).textTheme.bodyLarge?.color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Esta actividad ya ha finalizado. No se permiten inscripciones o modificaciones.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrollmentOrModificationSection(BuildContext context, ActivityWithDetails details) {
    final textTheme = Theme.of(context).textTheme;
    final isLoading = _isLoadingEnrollment || _isLoadingModification;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isModifyingEnrollment ? 'Selecciona tu nuevo horario' : 'Inscribirse a la actividad',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Dropdown para Grupo de Horario
        DropdownButtonFormField<GrupoHorarioVista>(
          value: _selectedGrupoHorario,
          hint: const Text('1. Elige un grupo de horario'),
          isExpanded: true,
          items: details.gruposHorarioVista.map((grupo) {
            return DropdownMenuItem(value: grupo, child: Text(grupo.descripcionAmigable, overflow: TextOverflow.ellipsis));
          }).toList(),
          onChanged: isLoading ? null : _onGrupoHorarioChanged,
          decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16)),
        ),
        const SizedBox(height: 16),

        // Dropdown para Fechas (si aplica)
        if (_selectedGrupoHorario?.tipoDeHorario == TipoDeHorario.PorFecha)
          DropdownButtonFormField<String>(
            value: _selectedDateString,
            hint: const Text('2. Elige una fecha'),
            items: _availableDates.map((fecha) {
              return DropdownMenuItem(value: fecha, child: Text(fecha));
            }).toList(),
            onChanged: isLoading ? null : _onDateChanged,
            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16)),
          ),
          
        // Dropdown para Horario Específico
        if (_availableHorarioDetalles.isNotEmpty) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<HorarioDetalleVista>(
              value: _selectedHorarioDetalle,
              hint: Text(_selectedGrupoHorario?.tipoDeHorario == TipoDeHorario.PorFecha ? '3. Elige un horario' : '2. Elige un horario'),
              isExpanded: true,
              items: _availableHorarioDetalles.map((detalle) {
                return DropdownMenuItem(value: detalle, child: Text(detalle.descripcion, overflow: TextOverflow.ellipsis));
              }).toList(),
              onChanged: isLoading ? null : _onHorarioDetalleChanged,
              decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16)),
            ),
        ],

        const SizedBox(height: 24),
        Center(
          child: isLoading 
              ? const CircularProgressIndicator()
              : _buildActionButtons(context, details),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ActivityWithDetails details) {
    return Wrap(
      spacing: 8.0, runSpacing: 8.0, alignment: WrapAlignment.center,
      children: [
        if (_isModifyingEnrollment) ...[
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Guardar Cambios'),
            onPressed: details.datosInscripcion?.inscripcionId == null ? null : () => _updateEnrollment(details.datosInscripcion!.inscripcionId!, details.idActividad),
          ),
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => _toggleModificationMode(false, details),
          ),
        ] else ...[
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Inscribirme'),
            onPressed: () => _enrollToActivity(details.idActividad),
          ),
        ],
      ],
    );
  }
} 