import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../models/database.dart';

class AddItemDialog extends StatefulWidget {
  const AddItemDialog({super.key});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormBuilderState>();

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
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agregar Producto',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            FormBuilder(
              key: _formKey,
              child: Column(
                children: [
                  FormBuilderTextField(
                    name: 'product',
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Producto',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'price',
                          decoration: const InputDecoration(
                            labelText: 'Precio',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(),
                          ]),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FormBuilderDropdown<String>(
                          name: 'unit',
                          initialValue: 'kg',
                          decoration: const InputDecoration(
                            labelText: 'Unidad',
                            prefixIcon: Icon(Icons.scale),
                          ),
                          items: _unitCategories.values
                              .expand((e) => e)
                              .map((unit) => DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  ))
                              .toList(),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      final values = _formKey.currentState!.value;
                      final item = DatabaseItem(
                        name: values['product'],
                        price: double.parse(values['price']),
                        unit: values['unit'],
                      );
                      Navigator.pop(context, item);
                    }
                  },
                  child: const Text('Agregar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
