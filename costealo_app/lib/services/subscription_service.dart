import 'api_client.dart';
import '../models/subscription.dart';

class SubscriptionService {
  final ApiClient _apiClient = ApiClient();

  Future<Subscription> getCurrentSubscription() async {
    try {
      // TODO: Replace with actual API call when backend is ready
      // final response = await _apiClient.dio.get('/subscription/me');
      // return Subscription.fromJson(response.data);
      
      // Returning mock data for now to enable UI development
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network
      return Subscription.mock();
    } catch (e) {
      throw Exception('Failed to load subscription: $e');
    }
  }

  Future<bool> checkDatabaseLimit() async {
    final sub = await getCurrentSubscription();
    return sub.databaseUsage < sub.databaseLimit;
  }

  Future<bool> checkWorkbookLimit() async {
    final sub = await getCurrentSubscription();
    return sub.workbookUsage < sub.workbookLimit;
  }
}
