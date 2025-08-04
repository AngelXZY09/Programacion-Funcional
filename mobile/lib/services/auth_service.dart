import 'dart:convert'; // Para json.decode y json.encode
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http; // Paquete HTTP
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Almacenamiento seguro
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/models/user_model.dart'; // Actualizado
import 'package:mobile/models/register_dto.dart'; // Actualizado
import 'package:http/io_client.dart';
import '../utils_funcional.dart';

// import 'activity_service.dart'; // No se usa actualmente

// Función auxiliar para crear un HttpClient que acepte certificados autofirmados (SOLO PARA DESARROLLO)
http.Client _createDevelopmentHttpClient() {
  final httpClient = HttpClient()
    ..badCertificateCallback =
        (X509Certificate cert, String host, int port) => true; // Acepta todos los certificados
  return IOClient(httpClient);
}

class AuthService with ChangeNotifier {
  // URL base de tu API (ajusta según sea necesario)
  static const String _baseUrl = 'https://192.168.100.90:5001/api';
  static const String _tokenKey = 'auth_token';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  // Usar el cliente HTTP de desarrollo si estamos en modo debug (o si una variable global lo indica)
  // En producción, deberías usar http.Client() directamente o un cliente configurado para producción.
  final http.Client _httpClient = kDebugMode ? _createDevelopmentHttpClient() : http.Client();

  User? _currentUser;
  bool _isAuthenticated = false;
  String? _token;
  bool _isInitialized = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token; // Podría ser útil para interceptores HTTP
  bool get isInitialized => _isInitialized; // Para saber si la carga inicial de estado ya ocurrió

  Future<void> initializeAuthState() async {
    if (_isInitialized && _isAuthenticated) {
      print('AuthService.initializeAuthState: Ya inicializado y autenticado. Retornando.');
      return;
    }
    if (_isInitialized) {
        print('AuthService.initializeAuthState: Ya inicializado (pero no autenticado). Retornando.');
        return;
    }

    print('AuthService.initializeAuthState: Iniciando proceso de inicialización...');
    try {
      final storedToken = await _secureStorage.read(key: _tokenKey);
      if (storedToken != null) {
        if (JwtDecoder.isExpired(storedToken)) {
          print('AuthService.initializeAuthState: Token almacenado expirado.');
          await _clearAuthData();
        } else {
          final bool processed = await _processToken(storedToken);
          if (!processed) {
            print('AuthService.initializeAuthState: _processToken falló.');
          }
        }
      } else {
        print('AuthService.initializeAuthState: No hay token almacenado.');
        _isAuthenticated = false;
        _currentUser = null;
        _token = null;
      }
    } catch (e) {
      print('AuthService.initializeAuthState: Error durante la inicialización: $e');
      await _clearAuthData();
    }
    
    _isInitialized = true;
    print('AuthService.initializeAuthState: Proceso finalizado. isInitialized=true, isAuthenticated=$_isAuthenticated. Notificando...');
    notifyListeners();
  }

  Future<bool> _processToken(String token) async {
    try {
      _token = token;
      await _secureStorage.write(key: _tokenKey, value: token);

      Map<String, dynamic> claims = JwtDecoder.decode(token);
      _currentUser = User.fromClaims(claims);
      _isAuthenticated = true;
      print('AuthService: Usuario autenticado desde token: ${_currentUser?.email}');
      return true;
    } catch (e) {
      print('AuthService: Error al procesar token: $e');
      await _clearAuthData();
      return false;
    }
  }

  Future<void> _clearAuthData() async {
    _token = null;
    _currentUser = null;
    _isAuthenticated = false;
    _isInitialized = false;
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (e) {
      print('AuthService: Error al borrar token del almacenamiento seguro: $e');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/Auth/login');
    try {
      print('AuthService: Intentando login en $url con Email: $email');
      final response = await _httpClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'UserName': email, 'Password': password}),
      );

      print('AuthService: Respuesta de login - Status: ${response.statusCode}');

      final taskEitherResponse = processLoginResponseFunc(response.statusCode, response.body);

      // taskEitherResponse nunca será null, por lo que eliminamos esta verificación

      final resultTask = taskEitherResponse.flatMap((token) {
        return TaskEither.tryCatch(
          () async {
            final bool processed = await _processToken(token);
            if (!processed) {
              throw Exception('Error al procesar el token de autenticación.');
            }
            return true; // Éxito en el procesamiento
          },
          (error, stackTrace) => error.toString(),
        );
      });

      final finalResult = await resultTask.run();
      return finalResult.fold(
        (errorMessage) {
          // Caso de error (Left) de cualquier paso
          return {'success': false, 'message': errorMessage};
        },
        (_) {
          // Caso de éxito (Right) final
          _isInitialized = true;
          notifyListeners();
          return {'success': true};
        },
      );
    } catch (e) {
      print('AuthService: Excepción durante el login: $e');
      await _clearAuthData();
      notifyListeners();
      return {'success': false, 'message': 'Excepción durante el login: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> register(RegisterDto registerDto) async {
    final url = Uri.parse('$_baseUrl/Auth/register');
    try {
      print('AuthService (Register): Intentando registro en $url con datos: ${registerDto.toJson()}');
      final response = await _httpClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(registerDto.toJson()),
      );
      print('AuthService (Register): Status ${response.statusCode}');

      // Usar la función funcional para procesar la respuesta
      final taskEitherResponse = processRegisterResponseFunc(response.statusCode, response.body);
      final result = await taskEitherResponse.run();
      
      return result.fold(
        (errorMessage) => {'success': false, 'message': errorMessage},
        (successMessage) => {'success': true, 'message': successMessage},
      );
    } catch (e) {
      print('AuthService (Register): Exception $e');
      return {'success': false, 'message': 'Excepción durante el registro: ${e.toString()}'};
    }
  }

  Future<void> logout() async {
    print('AuthService: Cerrando sesión...');
    await _clearAuthData();
    notifyListeners();
    print('AuthService: Sesión cerrada.');
  }

  Future<void> forceLogout() async {
    print('AuthService: Forzando cierre de sesión debido a error de autorización o token expirado.');
    await _clearAuthData();
    notifyListeners();
  }
} 