import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../../config/theme.dart';

class CreateDatabaseDialog extends StatefulWidget {
  const CreateDatabaseDialog({super.key});

  @override
  State<CreateDatabaseDialog> createState() => _CreateDatabaseDialogState();
}

class _CreateDatabaseDialogState extends State<CreateDatabaseDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  PlatformFile? _selectedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true, // Important for web/memory access
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva Base de Datos'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: FormBuilder(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormBuilderTextField(
                  name: 'name',
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la Base de Datos',
                    hintText: 'Ej. Proveedor A, Mercado Central',
                    prefixIcon: Icon(Icons.storage_outlined),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'bob',
                  decoration: const InputDecoration(
                    labelText: 'BOB (Observaciones)',
                    hintText: 'Notas adicionales...',
                    prefixIcon: Icon(Icons.note_alt_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Excel Import Section
                Text('Importar desde Excel (Opcional)', 
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.grisOscuro,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[50],
                  ),
                  child: Column(
                    children: [
                      if (_selectedFile != null) ...[
                        Row(
                          children: [
                            const Icon(Icons.description, color: AppTheme.verdePrincipal),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedFile!.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () => setState(() => _selectedFile = null),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.upload_file),
                          label: Text(_selectedFile == null ? 'Seleccionar Archivo' : 'Cambiar Archivo'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.verdeOscuro,
                            side: const BorderSide(color: AppTheme.verdeOscuro),
                          ),
                        ),
                      ),
                      if (_selectedFile == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Soporta .xlsx y .xls',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.saveAndValidate() ?? false) {
              final values = _formKey.currentState!.value;
              Navigator.of(context).pop({
                'name': values['name'],
                'bob': values['bob'],
                'file': _selectedFile,
              });
            }
          },
          child: const Text('Crear'),
        ),
      ],
    );
  }
}
