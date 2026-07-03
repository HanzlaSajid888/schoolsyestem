import '../../models/student_model.dart';
import 'api_service.dart';

class StudentApi {
  static const String _endpoint = '/students';

  static Future<List<Student>> getStudents({String? query, String? classFilter}) async {
    String url = _endpoint;
    List<String> queryParams = [];
    if (query != null && query.isNotEmpty) queryParams.add('q=$query');
    if (classFilter != null && classFilter.isNotEmpty) queryParams.add('grade=$classFilter');
    
    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    final response = await ApiService.get(url);
    if (response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => Student.fromJson(json)).toList();
    }
    return [];
  }

  static Future<Student> addStudent(Student student) async {
    final response = await ApiService.post(_endpoint, student.toJson());
    return Student.fromJson(response['data']);
  }

  static Future<Student> updateStudent(String id, Student student) async {
    final response = await ApiService.put('$_endpoint/$id', student.toJson());
    return Student.fromJson(response['data']);
  }

  static Future<void> deleteStudent(String id) async {
    await ApiService.delete('$_endpoint/$id');
  }
}
