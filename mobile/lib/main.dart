import 'package:flutter/material.dart';
import 'package:mobile/screens/auth/login_screen.dart';
import 'package:mobile/screens/activities/activity_list_screen.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/activity_service.dart';
import 'package:mobile/notifiers/filter_notifier.dart';
import 'package:mobile/notifiers/theme_notifier.dart';
import 'package:provider/provider.dart'; // Importar provider

void main() {
  runApp(const MyAppInitializer());
}

// Widget para inicializar AuthService y proveerlo
class MyAppInitializer extends StatelessWidget {
  const MyAppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        Provider(create: (context) => ActivityService(authService: context.read<AuthService>())),
        ChangeNotifierProvider(create: (context) => FilterNotifier()),
        ChangeNotifierProvider(create: (context) => ThemeNotifier()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final Color customPrimaryColor = const Color(0xFF155F82); // NUESTRO COLOR PRIMARIO
    final Color customPrimaryVariantLight = const Color(0xFF1E88A8); // Una variante más clara para botones hover/etc. o elementos secundarios
    final Color customPrimaryVariantDark = const Color(0xFF0D3F5B); // Una variante más oscura

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CreditTEC Mobile',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: customPrimaryColor, // Usar el color primario
        // primarySwatch: Colors.blue, // Podemos comentar o crear un MaterialColor si es necesario
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          backgroundColor: customPrimaryColor, // Color para AppBar
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white), // Asegurar iconos blancos en AppBar
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500), // Estilo de título AppBar
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: Colors.white, // Fondo de tarjeta explícitamente blanco en modo claro
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: customPrimaryColor, width: 2.0),
          ),
          filled: true,
          fillColor: customPrimaryColor.withOpacity(0.05), // Un relleno sutil basado en el primario
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: customPrimaryColor, // Color para botones elevados
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: customPrimaryColor, // Color para texto de TextButton
          )
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return customPrimaryColor;
            }
            return null; // Usa el color por defecto del tema para el estado no seleccionado
          }),
          trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return customPrimaryColor.withOpacity(0.5);
            }
            return null;
          }),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black.withOpacity(0.87)),
          bodyMedium: TextStyle(color: Colors.black.withOpacity(0.87)), // Color principal para texto
          bodySmall: TextStyle(color: Colors.black.withOpacity(0.60)), // Para texto secundario/hints
          titleLarge: TextStyle(color: Colors.black.withOpacity(0.87), fontWeight: FontWeight.w500),
          titleMedium: TextStyle(color: Colors.black.withOpacity(0.87), fontWeight: FontWeight.w500), // Para títulos de Card, etc.
          titleSmall: TextStyle(color: Colors.black.withOpacity(0.87), fontWeight: FontWeight.w500),
          labelLarge: TextStyle(color: customPrimaryColor, fontWeight: FontWeight.w500), // Para texto de botones que no sean ElevatedButton
          displayLarge: TextStyle(color: Colors.black.withOpacity(0.87)),
          displayMedium: TextStyle(color: Colors.black.withOpacity(0.87)),
          displaySmall: TextStyle(color: Colors.black.withOpacity(0.87)),
          headlineMedium: TextStyle(color: Colors.black.withOpacity(0.87)),
          headlineSmall: TextStyle(color: Colors.black.withOpacity(0.87)),
        ),
        iconTheme: IconThemeData( // Tema de iconos por defecto para modo claro
          color: Colors.black.withOpacity(0.70),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: customPrimaryColor, // Usar el color primario también en modo oscuro
        // primarySwatch: Colors.teal, // Comentamos o ajustamos
        scaffoldBackgroundColor: Colors.grey[850], // Fondo oscuro
        appBarTheme: AppBarTheme(
          backgroundColor: customPrimaryVariantDark, // Un tono más oscuro del primario para AppBar en modo oscuro
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 3,
          color: Colors.grey[800], // Color de las tarjetas
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: customPrimaryVariantLight, width: 2.0), // Un tono más claro para el borde enfocado
          ),
          filled: true,
          fillColor: customPrimaryColor.withOpacity(0.1), // Relleno sutil, un poco más opaco que en light
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: customPrimaryColor, // Botones elevados con el color primario
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: customPrimaryVariantLight, // Un tono más claro para texto de TextButton
          )
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return customPrimaryVariantLight; // Un tono más claro para el switch en dark mode
            }
            return Colors.grey[600];
          }),
          trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return customPrimaryVariantLight.withOpacity(0.5);
            }
            return Colors.grey[700];
          }),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: themeNotifier.themeMode,
      home: const AuthWrapper(),
    );
  }
}

// Widget que decide qué pantalla mostrar basado en el estado de autenticación
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<void> _initializeAuthFuture;

  @override
  void initState() {
    super.initState();
    // Llamar a initializeAuthState una vez cuando el AuthService esté disponible.
    // Provider.of con listen:false es seguro en initState si es para llamar a un método y no para reconstruir.
    _initializeAuthFuture = Provider.of<AuthService>(context, listen: false).initializeAuthState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeAuthFuture,
      builder: (context, snapshot) {
        final authService = Provider.of<AuthService>(context);
        
        // LOGGING DETALLADO:
        print('[AuthWrapper] Build triggered.');
        print('[AuthWrapper] Snapshot connectionState: ${snapshot.connectionState}');
        print('[AuthWrapper] AuthService isInitialized: ${authService.isInitialized}');
        print('[AuthWrapper] AuthService isAuthenticated: ${authService.isAuthenticated}');

        // Condición para mostrar el loader:
        // 1. El future de inicialización inicial aún no ha completado (snapshot.connectionState == ConnectionState.waiting)
        // 2. O, si el servicio de autenticación se marca a sí mismo como no inicializado (authService.isInitialized == false)
        //    Esto puede ocurrir después de un logout, donde _isInitialized se pone a false.
        if (snapshot.connectionState == ConnectionState.waiting || !authService.isInitialized) {
          print('[AuthWrapper] Decision: Show Loader. (Reason: initial future waiting OR authService not initialized)');
          
          // Si el future inicial ya completó (no está en waiting) pero authService no está inicializado
          // (típicamente después de un logout), necesitamos asegurarnos de que initializeAuthState se llame de nuevo.
          if (snapshot.connectionState != ConnectionState.waiting && !authService.isInitialized) {
            print('[AuthWrapper] Detected state: Initial future completed, but authService is not initialized (post-logout). Triggering re-initialization.');
            // Usamos addPostFrameCallback para evitar llamar a setState o cambiar el estado durante un build.
            // Esto llamará a initializeAuthState después de que el frame actual se complete.
            // AuthService.initializeAuthState tiene una guarda para no ejecutarse si ya está _isInitialized = true,
            // pero aquí sabemos que _isInitialized es false.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Volver a verificar el estado antes de llamar para ser extra cuidadoso
              final currentAuthService = Provider.of<AuthService>(context, listen: false);
              if (!currentAuthService.isInitialized) {
                print('[AuthWrapper] PostFrameCallback: Calling initializeAuthState().');
                currentAuthService.initializeAuthState();
              }
            });
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        

        print('[AuthWrapper] Decision: Initial future completed AND authService IS initialized.');

        if (authService.isAuthenticated) {
          print('[AuthWrapper] Decision: Show ActivityListScreen (isAuthenticated is true).');
          return const ActivityListScreen();
        } else {
          print('[AuthWrapper] Decision: Show LoginScreen (isAuthenticated is false).');
          return const LoginScreen();
        }
      },
    );
  }
}
