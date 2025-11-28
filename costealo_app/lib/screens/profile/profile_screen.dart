import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/sidebar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                  Text(
                    'Mi Perfil',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 32),
                  
                  // User Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 40,
                                backgroundColor: AppTheme.verdePastel,
                                child: Icon(Icons.person, size: 40, color: AppTheme.verdeOscuro),
                              ),
                              const SizedBox(width: 24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.name ?? 'Usuario',
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                  Text(
                                    user?.email ?? 'correo@ejemplo.com',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 4),
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
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          const Divider(),
                          const SizedBox(height: 24),
                          
                          // Subscription Usage
                          Text('Suscripción', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 16),
                          _buildUsageBar(context, 'Bases de Datos', 3, 5, AppTheme.verdePrincipal),
                          const SizedBox(height: 16),
                          _buildUsageBar(context, 'Planillas', 12, 20, AppTheme.rosaProfundo),
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
                          onTap: () {},
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
    final percentage = current / max;
    
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
}
