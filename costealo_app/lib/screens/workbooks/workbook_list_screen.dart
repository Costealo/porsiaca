import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/workbook_service.dart';
import '../../models/workbook.dart';
import '../../widgets/sidebar.dart';

class WorkbookListScreen extends StatefulWidget {
  const WorkbookListScreen({super.key});

  @override
  State<WorkbookListScreen> createState() => _WorkbookListScreenState();
}

class _WorkbookListScreenState extends State<WorkbookListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final WorkbookService _workbookService = WorkbookService();
  List<Workbook> _workbooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadWorkbooks();
  }

  Future<void> _loadWorkbooks() async {
    try {
      final wbs = await _workbookService.getAll();
      if (mounted) {
        setState(() {
          _workbooks = wbs;
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

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: !isDesktop ? AppBar(title: const Text('Planillas')) : null,
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
                            'Planillas de Costos',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          ElevatedButton.icon(
                            onPressed: () => context.go('/workbooks/new'),
                            icon: const Icon(Icons.add),
                            label: const Text('Nueva Planilla'),
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
                          Tab(text: 'Todas'),
                          Tab(text: 'Borradores'),
                          Tab(text: 'Publicadas'),
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
                            _buildWorkbookList(_workbooks),
                            _buildWorkbookList(_workbooks.where((w) => w.status == 'Draft').toList()),
                            _buildWorkbookList(_workbooks.where((w) => w.status == 'Published').toList()),
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

  Widget _buildWorkbookList(List<Workbook> workbooks) {
    if (workbooks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No hay planillas en esta sección',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: workbooks.length,
      itemBuilder: (context, index) {
        final wb = workbooks[index];
        return Card(
          child: InkWell(
            onTap: () => context.go('/workbooks/${wb.id}'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: wb.status == 'Published' 
                              ? AppTheme.verdePastel 
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          wb.status == 'Published' ? 'Publicado' : 'Borrador',
                          style: TextStyle(
                            fontSize: 12,
                            color: wb.status == 'Published' 
                                ? AppTheme.verdeOscuro 
                                : Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Editar')),
                          const PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    wb.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Precio Venta',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                          Text(
                            'BOB ${wb.sellingPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.verdePrincipal,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Margen',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                          Text(
                            '${wb.profitMargin}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
