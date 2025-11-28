
import 'api_client.dart';
import 'storage_service.dart';
import '../models/user.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storageService = StorageService();

  Future<User> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      // El backend devuelve directamente el token como string
      final token = response.data.toString();
      
      // Guardar el token
      await _storageService.saveToken(token);
      
      // Crear un usuario básico con el email
      // TODO: Hacer una llamada a /api/users/me para obtener los datos completos del usuario
      final user = User(
        id: email, // Temporal, usar email como id
        email: email,
        name: email.split('@')[0], // Extraer nombre del email temporalmente
        organization: '',
      );
      
      return user;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<User> register(String name, String email, String password, String organization) async {
    try {
      final response = await _apiClient.dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'organization': organization,
      });

      final token = response.data['token']?.toString() ?? '';
      final user = User.fromJson(response.data['user']);

      await _storageService.saveToken(token);
      return user;
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  Future<void> logout() async {
    await _storageService.clearToken();
  }
}
