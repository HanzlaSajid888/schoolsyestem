import 'api_service.dart';

class DashboardApi {
  static const String _endpoint = '/dashboard';

  static Future<Map<String, dynamic>> getSummary() async {
    final response = await ApiService.get('$_endpoint/summary');
    return response['data'];
  }
  static Future<List<dynamic>> getTrends({int months = 6}) async {
    final response = await ApiService.get('$_endpoint/trends?months=$months');
    return response['data'];
  }

  static Future<List<dynamic>> getEvents() async {
    final response = await ApiService.get('/events');
    return response['data'];
  }

  static Future<Map<String, dynamic>> addEvent(Map<String, dynamic> eventData) async {
    final response = await ApiService.post('/events', eventData);
    return response['data'];
  }

  static Future<void> deleteEvent(String id) async {
    await ApiService.delete('/events/$id');
  }
}
