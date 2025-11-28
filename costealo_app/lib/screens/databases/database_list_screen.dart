import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/database_service.dart';
import '../../models/database.dart';
import '../../widgets/sidebar.dart';
import 'widgets/create_database_dialog.dart';

class DatabaseListScreen extends StatefulWidget {
  const DatabaseListScreen({super.key});

  @override
  State<DatabaseListScreen> createState() => _DatabaseListScreenState();
}

class _DatabaseListScreenState extends State<DatabaseListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService();
  List<PriceDatabase> _databases = [];
  bool _isLoading = true;

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
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar bases de datos: $e')),
        );
      }
    }
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


// ... (inside the class)

                          ElevatedButton.icon(
                            onPressed: () async {
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Base de datos creada exitosamente')),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
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
                      ? const Center(child: CircularProgressIndicator())
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
    if (_databases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storage_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No tienes bases de datos aún',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _databases.length,
      itemBuilder: (context, index) {
        final db = _databases[index];
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
            title: Text(
              db.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${db.itemCount} productos'),
                Text(
                  'Creado: ${db.createdAt.toString().split(' ')[0]}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'view', child: Text('Ver detalles')),
                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                const PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: Colors.red))),
              ],
              onSelected: (value) {
                if (value == 'view') {
                  context.go('/databases/${db.id}');
                }
              },
            ),
            onTap: () => context.go('/databases/${db.id}'),
          ),
        );
      },
    );
  }
}
