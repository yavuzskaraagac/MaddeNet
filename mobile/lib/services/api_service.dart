import 'package:dio/dio.dart';

class ApiService {
  static const _baseUrl = 'http://10.0.2.2:8000'; // Android emülatör → localhost

  final _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    headers: {'Content-Type': 'application/json'},
  ));

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await _dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<Map<String, dynamic>> register(String fullName, String email, String password) async {
    try {
      final res = await _dio.post('/api/auth/register', data: {
        'full_name': fullName,
        'email': email,
        'password': password,
      });
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<Map<String, dynamic>> uploadDocument(String filePath, String contractType, String token) async {
    setToken(token);
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'contract_type': contractType,
      });
      final res = await _dio.post('/api/documents/upload', data: formData);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<Map<String, dynamic>> getAnalysis(String analysisId, String token) async {
    setToken(token);
    try {
      final res = await _dio.get('/api/analyses/$analysisId');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<List<dynamic>> getAnalyses(String token) async {
    setToken(token);
    try {
      final res = await _dio.get('/api/analyses');
      return res.data as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<List<dynamic>> getDocuments(String token) async {
    setToken(token);
    try {
      final res = await _dio.get('/api/documents');
      return res.data as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<void> deleteDocument(String documentId, String token) async {
    setToken(token);
    try {
      await _dio.delete('/api/documents/$documentId');
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<Map<String, dynamic>> getProfile(String token) async {
    setToken(token);
    try {
      final res = await _dio.get('/api/users/me');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<void> changePassword(String currentPw, String newPw, String token) async {
    setToken(token);
    try {
      await _dio.post('/api/users/change-password', data: {
        'current_password': currentPw,
        'new_password': newPw,
      });
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<void> deleteAccount(String email, String token) async {
    setToken(token);
    try {
      await _dio.delete('/api/users/me', data: {'email': email});
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data.containsKey('detail')) {
      return data['detail'].toString();
    }
    return e.message ?? 'Bir hata oluştu';
  }
}
