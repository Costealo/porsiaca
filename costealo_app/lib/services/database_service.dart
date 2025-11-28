import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'api_client.dart';
import '../models/database.dart';

class DatabaseService {
  final ApiClient _apiClient = ApiClient();

  Future<List<PriceDatabase>> getAll() async {
    try {
      final response = await _apiClient.dio.get('/databases');
      return (response.data as List).map((e) => PriceDatabase.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load databases: $e');
    }
  }

  Future<PriceDatabase> getById(int id) async {
    try {
      final response = await _apiClient.dio.get('/databases/$id');
      return PriceDatabase.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load database: $e');
    }
  }

  Future<List<DatabaseItem>> getItems(int databaseId) async {
    try {
      final response = await _apiClient.dio.get('/databases/$databaseId/items');
      return (response.data as List).map((e) => DatabaseItem.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load items: $e');
    }
  }

  Future<int> create(String name, {String? bob}) async {
    try {
      final response = await _apiClient.dio.post('/databases', data: {
        'name': name,
        'bob': bob,
      });
      return response.data['id'];
    } catch (e) {
      throw Exception('Failed to create database: $e');
    }
  }

  Future<void> updateItem(int databaseId, DatabaseItem item) async {
    try {
      if (item.id == null) return;
      await _apiClient.dio.put('/databases/$databaseId/items/${item.id}', data: item.toJson());
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  Future<void> deleteItem(int databaseId, int itemId) async {
    try {
      await _apiClient.dio.delete('/databases/$databaseId/items/$itemId');
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  Future<void> update(int id, {String? name, String? bob}) async {
    try {
      var bytes;
      if (file is PlatformFile) {
        bytes = file.bytes;
        // If bytes are null (e.g. on mobile sometimes), we might need to read from path
        // But for web (which seems to be the target here), bytes should be available if withData: true was used
      }

      if (bytes == null) {
        throw Exception('No file content found');
      }

      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        // Skip empty tables
        if (excel.tables[table]?.maxRows == 0) continue;

        // Iterate rows, skipping header (index 0)
        for (var row in excel.tables[table]!.rows.skip(1)) {
          if (row.isEmpty) continue;

          // Assume columns: Name (0), Price (1), Unit (2)
          // Adjust index based on your Excel structure
          
          // Helper to safely get cell value
          String getValue(Data? cell) {
            return cell?.value?.toString() ?? '';
          }

          final name = getValue(row[0]);
          if (name.isEmpty) continue; // Skip empty names

          final priceStr = getValue(row.length > 1 ? row[1] : null);
          final price = double.tryParse(priceStr.replaceAll(',', '.')) ?? 0.0;

          final unit = getValue(row.length > 2 ? row[2] : null);

          final item = DatabaseItem(
            name: name,
            price: price,
            unit: unit.isEmpty ? 'unidad' : unit,
          );

          await createItem(databaseId, item);
        }
      }
    } catch (e) {
      throw Exception('Failed to import Excel: $e');
    }
  }

  Future<void> update(int id, {String? name, String? bob}) async {
    try {
      await _apiClient.dio.put('/databases/$id', data: {
        if (name != null) 'name': name,
        if (bob != null) 'bob': bob,
      });
    } catch (e) {
      throw Exception('Failed to update database: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await _apiClient.dio.delete('/databases/$id');
    } catch (e) {
      throw Exception('Failed to delete database: $e');
    }
  }
}
