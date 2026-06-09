import 'package:dio/dio.dart';

class ApiService {
  static const _baseUrl = 'http://10.0.2.2:8000';

  final _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 180),
    headers: {'Content-Type': 'application/json'},
  ));

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }

  Future<Map<String, dynamic>> uploadDocument(String filePath, String token) async {
    setToken(token);
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final res = await _dio.post(
        '/api/documents/upload',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<Map<String, dynamic>> startAnalysis(String documentId, String contractTypeCode, String token) async {
    setToken(token);
    try {
      final res = await _dio.post('/api/analyses', data: {
        'belge_id': documentId,
        'sozlesme_turu': contractTypeCode,
      });
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

  Future<Map<String, dynamic>> getAnalyses(String token) async {
    setToken(token);
    try {
      final res = await _dio.get('/api/analyses');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<Map<String, dynamic>> getDocuments(String token) async {
    setToken(token);
    try {
      final res = await _dio.get('/api/documents');
      return res.data as Map<String, dynamic>;
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

  Future<void> deleteAnalysis(String analysisId, String token) async {
    setToken(token);
    try {
      await _dio.delete('/api/analyses/$analysisId');
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<Map<String, dynamic>> getDownloadUrl(String documentId, String token) async {
    setToken(token);
    try {
      final res = await _dio.get('/api/documents/$documentId/download');
      return res.data as Map<String, dynamic>;
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

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data.containsKey('detail')) {
      return data['detail'].toString();
    }
    return e.message ?? 'Bir hata oluştu';
  }
}
