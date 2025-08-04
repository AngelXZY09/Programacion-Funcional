import 'package:flutter/material.dart';
import 'package:mobile/screens/auth/register_screen.dart'; // Importar RegisterScreen
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/utils_funcional.dart';
import 'package:provider/provider.dart'; // Asegúrate de que Provider esté importado

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Funciones de validación funcionales usando Either
  String? _validateRequiredField(String? value, String fieldName) {
    return validateRequiredFieldFunc(value, fieldName).fold(
      (error) => error,
      (value) => null,
    );
  }

  String? _validateEmail(String? email) {
    return validateEmailFunc(email).fold(
      (error) => error,
      (email) => null,
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final result = await authService.login(
      _emailController.text,
      _passwordController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      if (!result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Error en el login: Verifica tus credenciales.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Si es exitoso, AuthWrapper se encarga de la navegación.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión - CreditTEC'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Image.asset(
                    'assets/images/logos/Mapaches.png',
                    height: 120,
                    errorBuilder: (context, error, stackTrace) {
                        print("Error al cargar el logo Mapaches.png: $error");
                        return const Icon(Icons.school, size: 80);
                    },
                  ),
                ),
                Text(
                  'Bienvenido',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Correo Electrónico / Usuario', prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  validator: (value) => _validateRequiredField(value, 'correo o usuario'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock)),
                  obscureText: true,
                  enabled: !_isLoading,
                  validator: (value) => _validateRequiredField(value, 'contraseña'),
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: const Text('Iniciar Sesión'),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isLoading ? null : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text('¿No tienes cuenta? Regístrate aquí'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 