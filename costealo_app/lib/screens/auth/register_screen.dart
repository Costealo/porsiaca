import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Crear Cuenta',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.verdePrincipal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Únete a Costealo hoy',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.grisMedio,
                  ),
                ),
                const SizedBox(height: 48),

                FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        name: 'name',
                        decoration: const InputDecoration(
                          labelText: 'Nombre completo',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'organization',
                        decoration: const InputDecoration(
                          labelText: 'Organización / Empresa',
                          prefixIcon: Icon(Icons.business_outlined),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'email',
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.email(),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'password',
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(6),
                        ]),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                if (authProvider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      authProvider.error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),

                ElevatedButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState?.saveAndValidate() ?? false) {
                            final values = _formKey.currentState!.value;
                            await authProvider.register(
                              values['name'],
                              values['email'],
                              values['password'],
                              values['organization'],
                            );
                            if (authProvider.isAuthenticated && mounted) {
                              context.go('/dashboard');
                            }
                          }
                        },
                  child: authProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Registrarse'),
                ),
                
                const SizedBox(height: 16),
                
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: RichText(
                    text: TextSpan(
                      text: '¿Ya tienes cuenta? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: 'Inicia sesión',
                          style: TextStyle(
                            color: AppTheme.verdePrincipal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
