import 'package:flutter/material.dart';
import 'package:mobile/models/register_dto.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/utils_funcional.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  // Por ahora, el rol se hardcodea o se selecciona de una lista simple.
  // En tu API, el rol es un string. Asegúrate de que coincida con los roles válidos en tu backend.
  String _selectedRole = 'Estudiante'; // Rol por defecto, o el más común.
  // Lista de roles disponibles. Idealmente, esto podría venir de la API o ser una constante bien definida.
  final List<String> _roles = ['Estudiante', 'Encargado']; // Ajusta según tus roles

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nombreController.dispose();
    _matriculaController.dispose();
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

  String? _validatePassword(String? password) {
    return validatePasswordFunc(password).fold(
      (error) => error,
      (password) => null,
    );
  }

  String? _validatePasswordConfirmation(String? confirmation) {
    return validatePasswordConfirmationFunc(confirmation, _passwordController.text).fold(
      (error) => error,
      (confirmation) => null,
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final dto = RegisterDto(
      email: _emailController.text,
      password: _passwordController.text,
      nombre: _nombreController.text,
      matricula: _matriculaController.text,
      role: _selectedRole,
    );

    final result = await authService.register(dto);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? (result['success'] ? 'Registro exitoso' : 'Error desconocido')),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );

      if (result['success']) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Nuevo Usuario'),
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
                    height: 100,
                    errorBuilder: (context, error, stackTrace) {
                        print("Error al cargar el logo Mapaches.png en RegisterScreen: $error");
                        return const Icon(Icons.school, size: 60);
                    },
                  ),
                ),
                Text(
                  'Crear Cuenta en CreditTEC',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre Completo', prefixIcon: Icon(Icons.person)),
                  enabled: !_isLoading,
                  validator: (value) => _validateRequiredField(value, 'nombre completo'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _matriculaController,
                  decoration: const InputDecoration(labelText: 'Matrícula / RFC', prefixIcon: Icon(Icons.badge)),
                  enabled: !_isLoading,
                  validator: (value) => _validateRequiredField(value, 'matrícula o RFC'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Correo Electrónico', prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  validator: (value) => _validateEmail(value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Rol', prefixIcon: Icon(Icons.manage_accounts)),
                  items: _roles.map((String role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: _isLoading ? null : (String? newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                  validator: (value) => value == null ? 'Selecciona un rol' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock)),
                  obscureText: true,
                  enabled: !_isLoading,
                  validator: (value) => _validatePassword(value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(labelText: 'Confirmar Contraseña', prefixIcon: Icon(Icons.lock_outline)),
                  obscureText: true,
                  enabled: !_isLoading,
                  validator: (value) => _validatePasswordConfirmation(value),
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _register,
                        child: const Text('Registrarme'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 