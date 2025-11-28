import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/common/stats_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: !isDesktop
          ? AppBar(
              title: const Text('Dashboard'),
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
              titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            )
          : null,
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
                  // Header
                  Text(
                    'Hola, Usuario 👋',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aquí tienes un resumen de tu actividad',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.grisMedio,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Stats Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final crossAxisCount = width > 1000 ? 3 : (width > 600 ? 2 : 1);
                      
                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: const [
                          StatsCard(
                            title: 'Bases de Datos',
                            value: '3',
                            icon: Icons.storage,
                            color: AppTheme.verdePrincipal,
                          ),
                          StatsCard(
                            title: 'Planillas',
                            value: '12',
                            icon: Icons.description,
                            color: AppTheme.rosaProfundo,
                          ),
                          StatsCard(
                            title: 'Suscripción',
                            value: 'Gratis',
                            icon: Icons.star,
                            color: AppTheme.lilaPrincipal,
                          ),
                        ],
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Sections
                  _buildSectionHeader(context, 'Borradores Recientes', Icons.edit_note),
                  const SizedBox(height: 16),
                  _buildEmptyState(context, 'No tienes borradores pendientes'),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionHeader(context, 'Planillas Publicadas', Icons.check_circle_outline),
                  const SizedBox(height: 16),
                  _buildEmptyState(context, 'No has publicado planillas aún'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.grisOscuro),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
