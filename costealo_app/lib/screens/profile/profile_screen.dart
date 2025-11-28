import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/subscription_service.dart';
import '../../models/subscription.dart';
import '../../widgets/sidebar.dart';
import '../../utils/ui_helpers.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  final _formKey = GlobalKey<FormBuilderState>();
  
  Subscription? _subscription;
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    try {
      final sub = await _subscriptionService.getCurrentSubscription();
      if (mounted) {
        setState(() {
          _subscription = sub;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Silent error for subscription, just don't show data
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: !isDesktop ? AppBar(title: const Text('Perfil')) : null,
      drawer: !isDesktop ? const Drawer(child: Sidebar()) : null,
      body: Row(
        children: [
          if (isDesktop) const Sidebar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mi Perfil',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      if (!_isEditing)
                        ElevatedButton.icon(
                          onPressed: () => setState(() => _isEditing = true),
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar Perfil'),
                        )
                      else
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => setState(() => _isEditing = false),
                              child: const Text('Cancelar'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Implement save logic
                                if (_formKey.currentState?.saveAndValidate() ?? false) {
                                  UIHelpers.showSnackBar(context, 'Perfil actualizado (Simulado)');
                                  setState(() => _isEditing = false);
                                }
                              },
                              icon: const Icon(Icons.save),
                              label: const Text('Guardar'),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // User Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: FormBuilder(
                        key: _formKey,
                        initialValue: {
                          'name': user?.name,
                          'organization': user?.organization,
                        },
                        enabled: _isEditing,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CircleAvatar(
                                  radius: 40,
                                  backgroundColor: AppTheme.verdePastel,
                                  child: Icon(Icons.person, size: 40, color: AppTheme.verdeOscuro),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (_isEditing) ...[
                                        FormBuilderTextField(
                                          name: 'name',
                                          decoration: const InputDecoration(labelText: 'Nombre Completo'),
                                          validator: FormBuilderValidators.required(),
                                        ),
                                        const SizedBox(height: 16),
                                        FormBuilderTextField(
                                          name: 'organization',
                                          decoration: const InputDecoration(labelText: 'Organización / Empresa'),
                                        ),
                                      ] else ...[
                                        Text(
                                          user?.name ?? 'Usuario',
                                          style: Theme.of(context).textTheme.headlineSmall,
                                        ),
                                        Text(
                                          user?.email ?? 'correo@ejemplo.com',
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.lilaPastel,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            user?.organization ?? 'Organización',
                                            style: const TextStyle(
                                              color: AppTheme.lilaPrincipal,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            const Divider(),
                            const SizedBox(height: 24),
                            
                            // Subscription Usage
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Suscripción', style: Theme.of(context).textTheme.titleLarge),
                                if (_subscription != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.verdePrincipal,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _subscription!.planName,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            if (_isLoading)
                              const Center(child: CircularProgressIndicator())
                            else if (_subscription != null) ...[
                              _buildUsageBar(
                                context, 
                                'Bases de Datos', 
                                _subscription!.databaseUsage, 
                                _subscription!.databaseLimit, 
                                AppTheme.verdePrincipal
                              ),
                              const SizedBox(height: 16),
                              _buildUsageBar(
                                context, 
                                'Planillas', 
                                _subscription!.workbookUsage, 
                                _subscription!.workbookLimit, 
                                AppTheme.rosaProfundo
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    UIHelpers.showSnackBar(context, 'Función de Upgrade próximamente');
                                  },
                                  icon: const Icon(Icons.star_outline),
                                  label: const Text('Mejorar Plan'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // Payment Method Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Método de Pago', style: Theme.of(context).textTheme.titleLarge),
                              TextButton(
                                onPressed: () {
                                  UIHelpers.showSnackBar(context, 'Cambiar método de pago (Simulado)');
                                },
                                child: const Text('Cambiar'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.credit_card, size: 32, color: Colors.grey),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '•••• •••• •••• 4242',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Vence: 12/25',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Titular', style: TextStyle(color: Colors.grey[600])),
                              Text(user?.name ?? 'Usuario', style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Actions
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.lock_outline),
                          title: const Text('Cambiar contraseña'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _showChangePasswordDialog,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
                          onTap: () {
                            authProvider.logout();
                            context.go('/login');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageBar(BuildContext context, String label, int current, int max, Color color) {
    final percentage = (current / max).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('$current / $max', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[200],
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Contraseña Actual'),
            ),
            const SizedBox(height: 16),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Nueva Contraseña'),
            ),
            const SizedBox(height: 16),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Confirmar Nueva Contraseña'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              UIHelpers.showSnackBar(context, 'Contraseña actualizada (Simulado)');
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}
