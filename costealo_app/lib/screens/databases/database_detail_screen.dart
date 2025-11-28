import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/database_service.dart';
import '../../models/database.dart';
import '../../widgets/sidebar.dart';

class DatabaseDetailScreen extends StatefulWidget {
  final String id;

  const DatabaseDetailScreen({super.key, required this.id});

  @override
  State<DatabaseDetailScreen> createState() => _DatabaseDetailScreenState();
}

class _DatabaseDetailScreenState extends State<DatabaseDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();
  PriceDatabase? _database;
  List<DatabaseItem> _items = [];
  bool _isLoading = true;
  
  // Unit Categories
  final Map<String, List<String>> _unitCategories = {
    'Masa': ['g', 'kg', 'mg', 'ton', 'lb', 'oz'],
    'Volumen': ['ml', 'l', 'cm³', 'm³', 'gal'],
    'Longitud': ['mm', 'cm', 'm', 'km', 'in'],
    'Temperatura': ['°C', 'K', '°F'],
    'Tiempo': ['s', 'min', 'h'],
    'Energía': ['J', 'kJ', 'kcal'],
    'Cantidad': ['unidad', 'docena', 'mol'],
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final dbId = int.parse(widget.id);
      final db = await _databaseService.getById(dbId);
      final items = await _databaseService.getItems(dbId);
      
      if (mounted) {
        setState(() {
          _database = db;
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _detectCategory(String unit) {
    for (var entry in _unitCategories.entries) {
      if (entry.value.contains(unit)) return entry.key;
    }
    return 'Cantidad';
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: !isDesktop ? AppBar(title: Text(_database?.name ?? 'Detalle')) : null,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => context.go('/databases'),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _database?.name ?? '',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const Spacer(),
                          if (_database?.sourceUrl != null)
                            ElevatedButton.icon(
                              onPressed: () {
                                // Refresh logic
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Actualizar desde URL'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.lilaPrincipal,
                              ),
                            ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Publish logic
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Publicar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // BOB Field
                      TextField(
                        controller: TextEditingController(text: _database?.bob),
                        decoration: const InputDecoration(
                          labelText: 'BOB (Observaciones)',
                          prefixIcon: Icon(Icons.note_alt_outlined),
                        ),
                        onSubmitted: (value) {
                          // Save BOB
                        },
                      ),
                    ],
                  ),
                ),

                // Items Table
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Card(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('#')),
                          DataColumn(label: Text('Producto')),
                          DataColumn(label: Text('Precio (BOB)')),
                          DataColumn(label: Text('Unidad')),
                          DataColumn(label: Text('Acciones')),
                        ],
                        rows: _items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final category = _detectCategory(item.unit);
                          
                          return DataRow(
                            cells: [
                              DataCell(Text('${index + 1}')),
                              DataCell(
                                TextFormField(
                                  initialValue: item.name,
                                  decoration: const InputDecoration(border: InputBorder.none),
                                  onChanged: (val) => item.name = val,
                                ),
                              ),
                              DataCell(
                                TextFormField(
                                  initialValue: item.price.toString(),
                                  decoration: const InputDecoration(border: InputBorder.none),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) => item.price = double.tryParse(val) ?? 0,
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Category Dropdown
                                    DropdownButton<String>(
                                      value: category,
                                      items: _unitCategories.keys.map((cat) {
                                        return DropdownMenuItem(value: cat, child: Text(cat));
                                      }).toList(),
                                      onChanged: (newCat) {
                                        setState(() {
                                          if (newCat != null) {
                                            item.unit = _unitCategories[newCat]!.first;
                                          }
                                        });
                                      },
                                      underline: Container(),
                                    ),
                                    const SizedBox(width: 8),
                                    // Unit Dropdown
                                    DropdownButton<String>(
                                      value: item.unit,
                                      items: _unitCategories[category]?.map((unit) {
                                        return DropdownMenuItem(value: unit, child: Text(unit));
                                      }).toList(),
                                      onChanged: (newUnit) {
                                        setState(() {
                                          if (newUnit != null) item.unit = newUnit;
                                        });
                                      },
                                      underline: Container(),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.delete, color: AppTheme.rosaProfundo),
                                  onPressed: () {
                                    setState(() {
                                      _items.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _items.add(DatabaseItem(name: 'Nuevo Producto', price: 0, unit: 'kg'));
          });
        },
        backgroundColor: AppTheme.verdePrincipal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
