import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/database_service.dart';
import '../../services/subscription_service.dart';
import '../../models/database.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/custom_empty_state.dart';
import '../../utils/ui_helpers.dart';
import 'widgets/create_database_dialog.dart';

class DatabaseListScreen extends StatefulWidget {
  const DatabaseListScreen({super.key});

  @override
  State<DatabaseListScreen> createState() => _DatabaseListScreenState();
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/database_service.dart';
import '../../models/database.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/custom_empty_state.dart';
import 'widgets/create_database_dialog.dart';
import '../../utils/ui_helpers.dart'; // Assuming UIHelpers is in this path

class DatabaseListScreen extends StatefulWidget {
  const DatabaseListScreen({super.key});

  @override
  State<DatabaseListScreen> createState() => _DatabaseListScreenState();
}

class _DatabaseListScreenState extends State<DatabaseListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService();
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<PriceDatabase> _databases = [];
  List<PriceDatabase> _filteredDatabases = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _statusFilter = 'all'; // 'all', 'active', 'draft', 'archived'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDatabases();
  }

  Future<void> _loadDatabases() async {
    try {
      final dbs = await _databaseService.getAll();
      if (mounted) {
        setState(() {
          _databases = dbs;
          _filterDatabases();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        UIHelpers.showSnackBar(context, 'Error al cargar bases de datos: $e', isError: true);
      }
    }
  }

  void _filterDatabases() {
    setState(() {
      _filteredDatabases = _databases.where((db) {
        final matchesSearch = db.name.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesStatus = _statusFilter == 'all' || db.status == _statusFilter;
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: !isDesktop ? AppBar(title: const Text('Bases de Datos')) : null,
      drawer: !isDesktop ? const Drawer(child: Sidebar()) : null,
      body: Row(
        children: [
          if (isDesktop) const Sidebar(),
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Bases de Datos',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              // Check subscription limit before creating
                              final canCreate = await _subscriptionService.checkDatabaseLimit();
                              if (!canCreate && mounted) {
                                UIHelpers.showSnackBar(
                                  context, 
                                  'Has alcanzado el límite de bases de datos de tu plan. Actualiza tu suscripción para crear más.',
                                  isError: true
                                );
                                return;
                              }

                              final result = await showDialog<Map<String, dynamic>>(
                                context: context,
                                builder: (context) => const CreateDatabaseDialog(),
                              );

                              if (result != null) {
                                setState(() => _isLoading = true);
                                try {
                                  // Create DB
                                  final dbId = await _databaseService.create(
                                    result['name'],
                                    bob: result['bob'],
                                  );
                                  
                                  // Import Excel if selected
                                  if (result['file'] != null) {
                                    await _databaseService.importFromExcel(
                                      dbId, 
                                      result['file'],
                                    );
                                  }
                                  
                                  await _loadDatabases();
                                  
                                  if (mounted) {
                                    UIHelpers.showSnackBar(context, 'Base de datos creada exitosamente');
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    UIHelpers.showSnackBar(context, 'Error: $e', isError: true);
                                  }
                                } finally {
                                  if (mounted) setState(() => _isLoading = false);
                                }
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Nueva Base de Datos'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Search and Filter Bar
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Buscar base de datos...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              ),
                              onChanged: (value) {
                                _searchQuery = value;
                                _filterDatabases();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          DropdownButtonHideUnderline(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                value: _statusFilter,
                                items: const [
                                  DropdownMenuItem(value: 'all', child: Text('Todos los estados')),
                                  DropdownMenuItem(value: 'active', child: Text('Activos')),
                                  DropdownMenuItem(value: 'draft', child: Text('Borradores')),
                                  DropdownMenuItem(value: 'archived', child: Text('Archivados')),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    _statusFilter = value;
                                    _filterDatabases();
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      TabBar(
                        controller: _tabController,
                        labelColor: AppTheme.verdePrincipal,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: AppTheme.verdePrincipal,
                        tabs: const [
                          Tab(text: 'Mis Bases de Datos'),
                          Tab(text: 'Más Recientes'),
                        ],
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: _isLoading
                      ? const LoadingIndicator(message: 'Cargando bases de datos...')
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildDatabaseList(),
                            _buildDatabaseList(), // Placeholder for recent
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatabaseList() {
    if (_filteredDatabases.isEmpty) {
      return CustomEmptyState(
        message: _searchQuery.isEmpty 
            ? 'No tienes bases de datos aún' 
            : 'No se encontraron resultados',
        icon: Icons.storage_outlined,
        buttonText: _searchQuery.isEmpty ? 'Crear Base de Datos' : null,
        onButtonPressed: _searchQuery.isEmpty 
            ? () async {
                final result = await showDialog<Map<String, dynamic>>(
                  context: context,
                  builder: (context) => const CreateDatabaseDialog(),
                );
                // Logic handled in main button
              }
            : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _filteredDatabases.length,
      itemBuilder: (context, index) {
        final db = _filteredDatabases[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.verdePastel,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.table_chart, color: AppTheme.verdeOscuro),
            ),
            title: Row(
              children: [
                Text(
                  db.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(db.status),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('${db.itemCount} productos'),
                    const SizedBox(width: 16),
                    Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('Creado: ${db.createdAt.toString().split(' ')[0]}'),
                  ],
                ),
                if (db.lastRefreshedAt != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.refresh, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Actualizado: ${db.lastRefreshedAt.toString().split(' ')[0]}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'view', child: Text('Ver detalles')),
                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                if (db.sourceUrl != null)
                  const PopupMenuItem(value: 'refresh', child: Text('Actualizar datos')),
                const PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: Colors.red))),
              ],
              onSelected: (value) {
                if (value == 'view') {
                  context.go('/databases/${db.id}');
                } else if (value == 'refresh') {
                  UIHelpers.showSnackBar(context, 'Actualizando desde fuente externa...');
                } else if (value == 'delete') {
                  // TODO: Implement delete
                  UIHelpers.showSnackBar(context, 'Función eliminar pendiente');
                }
              },
            ),
            onTap: () => context.go('/databases/${db.id}'),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'active':
        color = Colors.green;
        label = 'Activo';
        break;
      case 'draft':
        color = Colors.orange;
        label = 'Borrador';
        break;
      case 'archived':
        color = Colors.grey;
        label = 'Archivado';
        break;
      default:
        color = Colors.blue;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
