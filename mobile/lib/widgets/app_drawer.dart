import 'package:flutter/material.dart';
import 'package:mobile/models/user_model.dart';
import 'package:mobile/notifiers/filter_notifier.dart';
import 'package:mobile/notifiers/theme_notifier.dart';
import 'package:mobile/screens/activities/activity_list_screen.dart';
import 'package:mobile/screens/history/history_screen.dart';
import 'package:mobile/screens/auth/login_screen.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;
    final filterNotifier = Provider.of<FilterNotifier>(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          if (currentUser != null)
            UserAccountsDrawerHeader(
              accountName: Text((currentUser.nombre?.isNotEmpty ?? false) ? currentUser.nombre! : 'Usuario'),
              accountEmail: Text(currentUser.matriculaRfc ?? 'Sin matrícula'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  ((currentUser.nombre?.isNotEmpty ?? false) ? currentUser.nombre![0].toUpperCase() : 'U'),
                  style: const TextStyle(fontSize: 40.0),
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            )
          else
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'CreditTEC',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Lista de Actividades'),
            onTap: () {
              Navigator.pop(context); // Cerrar el drawer
              // Navegar a ActivityListScreen, asegurándose de no apilarla si ya está visible
              // O simplemente cerrar si ya estamos allí.
              // Por ahora, una navegación simple. Considerar Navigator.pushReplacement si es necesario.
              if (ModalRoute.of(context)?.settings.name != '/activity_list') {
                 Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ActivityListScreen(),
                        settings: const RouteSettings(name: '/activity_list'),
                    )
                 );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Historial de Actividades'),
            onTap: () {
              Navigator.pop(context); // Cerrar el drawer
               if (ModalRoute.of(context)?.settings.name != '/history') {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HistoryScreen(),
                        settings: const RouteSettings(name: '/history'),
                    )
                );
              }
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Excluir inscritas/finalizadas'),
            trailing: Switch(
              value: filterNotifier.excludeEnrolledOrFinished,
              onChanged: (bool value) {
                filterNotifier.toggleExcludeEnrolledOrFinished();
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Modo Noche'),
            trailing: Switch(
              value: themeNotifier.isDarkMode,
              onChanged: (bool value) {
                themeNotifier.toggleTheme();
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: () async {
              Navigator.pop(context); // Cerrar el drawer
              await authService.logout();
              // Asegurarse de que el usuario es redirigido a LoginScreen
              // Navigator.pushAndRemoveUntil previene volver a la pantalla anterior con el botón de retroceso
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false, // Elimina todas las rutas anteriores
              );
            },
          ),
        ],
      ),
    );
  }
} 