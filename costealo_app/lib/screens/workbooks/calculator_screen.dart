import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../services/workbook_service.dart';
import '../../services/database_service.dart';
import '../../models/workbook.dart';
import '../../models/database.dart';
import '../../widgets/sidebar.dart';
import '../../utils/ui_helpers.dart';

class CalculatorScreen extends StatefulWidget {
  final String? id; // Null if new

  const CalculatorScreen({super.key, this.id});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final WorkbookService _workbookService = WorkbookService();
  final DatabaseService _databaseService = DatabaseService();
  
  // State
  Workbook? _workbook;
  List<PriceDatabase> _databases = [];
  List<DatabaseItem> _databaseItems = [];
  bool _isLoading = true;
  Timer? _debounce;

  // Controllers
  final _nameController = TextEditingController();
  final _unitsController = TextEditingController(text: '1');
  final _bobController = TextEditingController();
  final _priceController = TextEditingController();
  final _marginController = TextEditingController(text: '20.0');

  // Calculations
  double _productionCost = 0;
  double _additionalCost = 0;
  double _operationalCost = 0;
  double _subtotal = 0;
  double _tax = 0;
  double _totalCost = 0;
  double _unitCost = 0;
  double _suggestedPrice = 0;
  double _actualMargin = 0;

  // SI Units
  final List<String> _siUnits = [
    'g', 'kg', 'mg', 'ton',
    'ml', 'l', 'cm³', 'm³',
    'mm', 'cm', 'm', 'km',
    '°C', 'K',
    's', 'min', 'h',
    'J', 'kJ', 'kcal',
    'mol', 'unidad'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _unitsController.dispose();
    _bobController.dispose();
    _priceController.dispose();
    _marginController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // Load databases for dropdown
      _databases = await _databaseService.getAll();

      if (widget.id != null && widget.id != 'new') {
        _workbook = await _workbookService.getById(int.parse(widget.id!));
        _nameController.text = _workbook!.name;
        _unitsController.text = _workbook!.productionUnits.toString();
        _bobController.text = _workbook!.bob ?? '';
        _priceController.text = _workbook!.sellingPrice.toString();
        _marginController.text = _workbook!.profitMargin.toString();
      } else {
        _workbook = Workbook(
          name: '',
          createdAt: DateTime.now(),
          items: [],
        );
      }

      _calculateCosts();
      
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        UIHelpers.showSnackBar(context, 'Error al cargar datos: $e', isError: true);
      }
    }
  }

  Future<void> _saveWorkbook({required bool isDraft}) async {
    // Validation
    if (_nameController.text.isEmpty) {
      UIHelpers.showSnackBar(context, 'Por favor ingresa un nombre para la planilla', isError: true);
      return;
    }
    if (_workbook!.items.isEmpty) {
      UIHelpers.showSnackBar(context, 'Agrega al menos un ingrediente', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Update workbook object from controllers
      _workbook!.name = _nameController.text;
      _workbook!.productionUnits = double.tryParse(_unitsController.text) ?? 1;
      _workbook!.bob = _bobController.text;
      _workbook!.sellingPrice = double.tryParse(_priceController.text) ?? 0;
      _workbook!.profitMargin = double.tryParse(_marginController.text) ?? 20;
      _workbook!.status = isDraft ? 'Draft' : 'Published';
      
      // Calculate final totals to ensure consistency
      // Note: In a real app, backend might recalculate, but we send what we have
      _calculateCosts(); 

      if (widget.id == null || widget.id == 'new') {
        await _workbookService.create(_workbook!);
      } else {
        await _workbookService.update(_workbook!);
      }

      if (mounted) {
        UIHelpers.showSnackBar(
          context, 
          isDraft ? 'Borrador guardado exitosamente' : 'Planilla publicada exitosamente'
        );
        context.go('/workbooks');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        UIHelpers.showSnackBar(context, 'Error al guardar: $e', isError: true);
      }
    }
  }

  // --- Calculation Logic ---

  void _calculateCosts() {
    if (_workbook == null) return;

    double prodUnits = double.tryParse(_unitsController.text) ?? 1;
    if (prodUnits <= 0) prodUnits = 1;

    double totalProd = 0;
    double totalAdd = 0;

    for (var item in _workbook!.items) {
      // Simplified cost calculation (quantity * 0.5 placeholder cost logic)
      // In real app, we'd fetch item price from DB and convert units
      double itemCost = item.quantity * 0.5; 
      item.calculatedCost = itemCost + item.additionalCost;
      
      totalProd += itemCost;
      totalAdd += item.additionalCost;
    }

    // Operational Cost (20%)
    double operational = totalProd * (AppConstants.defaultOperationalPercentage / 100);
    
    double subtotal = totalProd + totalAdd + operational;
    
    // Tax (16%)
    double tax = subtotal * (AppConstants.defaultTaxPercentage / 100);
    
    double total = subtotal + tax;
    double unit = total / prodUnits;
    
    // Suggested Price (Total Cost * 1.20)
    double suggested = total * 1.20;

    setState(() {
      _productionCost = totalProd;
      _additionalCost = totalAdd;
      _operationalCost = operational;
      _subtotal = subtotal;
      _tax = tax;
      _totalCost = total;
      _unitCost = unit;
      _suggestedPrice = suggested;
    });

    _updateActualMargin();
  }

  void _updateActualMargin() {
    double price = double.tryParse(_priceController.text) ?? 0;
    if (price > 0 && _totalCost > 0) {
      double margin = ((price - _totalCost) / price) * 100;
      setState(() => _actualMargin = margin);
    }
  }

  // Interdependent: Price -> Margin
  void _onPriceChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      double price = double.tryParse(val) ?? 0;
      if (price > 0 && _totalCost > 0) {
        double margin = ((price - _totalCost) / price) * 100;
        _marginController.text = margin.toStringAsFixed(1);
        _updateActualMargin();
      }
    });
  }

  // Interdependent: Margin -> Price
  void _onMarginChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      double margin = double.tryParse(val) ?? 0;
      if (margin > 0 && margin < 100 && _totalCost > 0) {
        double price = _totalCost / (1 - (margin / 100));
        _priceController.text = price.toStringAsFixed(2);
        _updateActualMargin();
      }
    });
  }

  void _debouncedCalculate() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _calculateCosts);
  }

  // --- UI Building ---

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1000;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: !isDesktop ? AppBar(title: const Text('Calculadora')) : null,
      drawer: !isDesktop ? const Drawer(child: Sidebar()) : null,
      body: Row(
        children: [
          if (isDesktop) const Sidebar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Content
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Form
                        _buildHeaderForm(),
                        const SizedBox(height: 24),
                        
                        // Ingredients Section
                        _buildIngredientsSection(),
                        
                        const SizedBox(height: 32),
                        
                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => context.go('/workbooks'),
                              child: const Text('Cancelar'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () => _saveWorkbook(isDraft: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                foregroundColor: Colors.black,
                              ),
                              child: const Text('Guardar Borrador'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () => _saveWorkbook(isDraft: false),
                              child: const Text('Publicar Planilla'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Summary Sidebar (Right Side)
                if (isDesktop)
                  Container(
                    width: 350,
                    color: AppTheme.verdePastel.withOpacity(0.3),
                    padding: const EdgeInsets.all(24),
                    child: _buildSummaryPanel(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Información General', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nombre de la planilla'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _unitsController,
                    decoration: const InputDecoration(labelText: 'Raciones'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => _debouncedCalculate(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bobController,
              decoration: const InputDecoration(labelText: 'BOB (Observaciones)'),
            ),
            const SizedBox(height: 24),
            
            // Interdependent Fields
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.rosaPastel,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Precio Venta Actual',
                        prefixText: 'BOB ',
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: _onPriceChanged,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _marginController,
                      decoration: const InputDecoration(
                        labelText: 'Margen (%)',
                        suffixText: '%',
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: _onMarginChanged,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ingredientes', style: Theme.of(context).textTheme.titleLarge),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _workbook?.items.add(WorkbookItem(
                        name: 'Nuevo Ingrediente',
                        quantity: 0,
                        unit: 'g',
                      ));
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lilaPrincipal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Database Selector Placeholder
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Seleccionar de Base de Datos'),
              items: _databases.map((db) => DropdownMenuItem(value: db.id, child: Text(db.name))).toList(),
              onChanged: (val) {
                // Load items from DB
              },
            ),
            
            const SizedBox(height: 24),
            
            // Items Table
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Producto')),
                  DataColumn(label: Text('Cantidad (SI)')),
                  DataColumn(label: Text('Costo Adicional')),
                  DataColumn(label: Text('Total')),
                  DataColumn(label: Text('')),
                ],
                rows: _workbook?.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(SizedBox(
                        width: 150,
                        child: TextFormField(
                          initialValue: item.name,
                          decoration: const InputDecoration(border: InputBorder.none),
                          onChanged: (val) => item.name = val,
                        ),
                      )),
                      DataCell(Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: TextFormField(
                              initialValue: item.quantity.toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(border: InputBorder.none),
                              onChanged: (val) {
                                item.quantity = double.tryParse(val) ?? 0;
                                _debouncedCalculate();
                              },
                            ),
                          ),
                          DropdownButton<String>(
                            value: _siUnits.contains(item.unit) ? item.unit : 'g',
                            items: _siUnits.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => item.unit = val);
                            },
                            underline: Container(),
                          ),
                        ],
                      )),
                      DataCell(SizedBox(
                        width: 80,
                        child: TextFormField(
                          initialValue: item.additionalCost.toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(border: InputBorder.none),
                          onChanged: (val) {
                            item.additionalCost = double.tryParse(val) ?? 0;
                            _debouncedCalculate();
                          },
                        ),
                      )),
                      DataCell(Text(
                        NumberFormat.currency(symbol: 'BOB ').format(item.calculatedCost),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataCell(IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _workbook?.items.removeAt(index);
                            _debouncedCalculate();
                          });
                        },
                      )),
                    ],
                  );
                }).toList() ?? [],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryPanel() {
    final currency = NumberFormat.currency(symbol: 'BOB ');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Resumen de Costos', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 32),
        
        _buildSummaryRow('Costo Producción', currency.format(_productionCost)),
        _buildSummaryRow('Costos Adicionales', currency.format(_additionalCost)),
        const Divider(height: 32),
        
        _buildSummaryRow('Costo Operacional (20%)', currency.format(_operationalCost), isHighlighted: true),
        _buildSummaryRow('Subtotal', currency.format(_subtotal)),
        _buildSummaryRow('Impuesto (16%)', currency.format(_tax), isHighlighted: true),
        
        const Divider(height: 32),
        
        _buildSummaryRow('COSTO TOTAL', currency.format(_totalCost), isBold: true, color: AppTheme.rosaProfundo),
        _buildSummaryRow('COSTO UNITARIO', currency.format(_unitCost), isBold: true, color: AppTheme.rosaCostealo),
        
        const SizedBox(height: 32),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.verdePrincipal,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.verdePrincipal.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'PRECIO RECOMENDADO',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                currency.format(_suggestedPrice),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '(Costo Total + 20%)',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Margen Real: ${_actualMargin.toStringAsFixed(1)}%',
            style: TextStyle(
              color: _actualMargin < 0 ? Colors.red : Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isHighlighted = false, Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: isHighlighted 
          ? BoxDecoration(
              color: AppTheme.verdePastel,
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Padding(
        padding: isHighlighted ? const EdgeInsets.symmetric(horizontal: 8) : EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isBold || isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: color ?? Colors.black87,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: isBold || isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: color ?? Colors.black87,
                fontSize: isBold ? 18 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
