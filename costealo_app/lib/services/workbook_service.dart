import 'api_client.dart';
import '../models/workbook.dart';

class WorkbookService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Workbook>> getAll() async {
    try {
      final response = await _apiClient.dio.get('/workbooks');
      return (response.data as List).map((e) => Workbook.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load workbooks: $e');
    }
  }

  Future<Workbook> getById(int id) async {
    try {
      final response = await _apiClient.dio.get('/workbooks/$id');
      return Workbook.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load workbook: $e');
    }
  }

  Future<void> create(Workbook workbook) async {
    try {
      await _apiClient.dio.post('/workbooks', data: {
        'name': workbook.name,
        'productionUnits': workbook.productionUnits,
        'sellingPrice': workbook.sellingPrice,
        'profitMargin': workbook.profitMargin,
        'status': workbook.status,
        'bob': workbook.bob,
        'items': workbook.items.map((e) => e.toJson()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to create workbook: $e');
    }
  }

  Future<void> update(int id, Workbook workbook) async {
    try {
      await _apiClient.dio.put('/workbooks/$id', data: {
        'name': workbook.name,
        'productionUnits': workbook.productionUnits,
        'sellingPrice': workbook.sellingPrice,
        'profitMargin': workbook.profitMargin,
        'status': workbook.status,
        'bob': workbook.bob,
        'items': workbook.items.map((e) => e.toJson()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to update workbook: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await _apiClient.dio.delete('/workbooks/$id');
    } catch (e) {
      throw Exception('Failed to delete workbook: $e');
    }
  }
}
