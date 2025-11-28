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

  Future<void> create(String name, {String? bob}) async {
    try {
      await _apiClient.dio.post('/databases', data: {
        'name': name,
        'bob': bob,
      });
    } catch (e) {
      throw Exception('Failed to create database: $e');
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
