import '../../models/invoice_model.dart';
import 'api_service.dart';

class InvoiceApi {
  static const String _endpoint = '/invoices';

  static Future<List<Invoice>> getInvoices({String? billingMonth, String? status}) async {
    String url = _endpoint;
    List<String> queryParams = [];
    if (billingMonth != null && billingMonth.isNotEmpty) queryParams.add('billingMonth=$billingMonth');
    if (status != null && status.isNotEmpty) queryParams.add('status=$status');
    
    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    final response = await ApiService.get(url);
    if (response['data'] != null) {
      final List<dynamic> data = response['data']; 
      return data.map((json) => Invoice.fromJson(json)).toList();
    }
    return [];
  }

  static Future<void> generateBatchInvoices(String billingMonth) async {
    await ApiService.post('$_endpoint/batch', {'billingMonth': billingMonth});
  }

  static Future<void> markAsPaid(String id) async {
    await ApiService.put('$_endpoint/$id/pay');
  }
}
